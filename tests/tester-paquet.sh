#!/bin/bash
# tests/tester-paquet.sh : construit le paquet Debian et le teste dans un Debian 13 neuf
# (conteneur Docker), sans toucher au système : installation, commandes, premier lancement
# de l'interface (Xvfb), profils sans panneau lancé, écran de connexion, désinstallation.
#   tests/tester-paquet.sh             teste (l'image d'essai est préparée la première fois)
#   tests/tester-paquet.sh --refaire   prépare de nouveau l'image (nouvelles dépendances…)
#
# Préparation de l'image xfce-personnaliser-essai:base : télécharge debian:trixie (~50 Mo) et
# les dépendances du paquet (~110 Mo, gardées dans le volume Docker xfce-personnaliser-apt).
# Le test lui-même tourne sans réseau. Tout supprimer :
#   docker rmi xfce-personnaliser-essai:base debian:trixie; docker volume rm xfce-personnaliser-apt
set -euo pipefail
ICI=$(cd "$(dirname "$0")" && pwd)
PROJET=$(dirname "$ICI")
IMAGE=xfce-personnaliser-essai:base

rm -rf "$PROJET/paquet"
# sed lit tout : « head -1 » fermerait le tube avant la seconde ligne, et avec pipefail le
# script s'arrêterait au hasard (code 141, SIGPIPE)
"$PROJET/construire-deb.sh" | sed -n 1p

if [ "${1:-}" = --refaire ] || ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "Préparation de l'image d'essai (téléchargements la première fois)…"
    docker rmi "$IMAGE" >/dev/null 2>&1 || true
    docker rm -f preparation-xfce-personnaliser >/dev/null 2>&1 || true
    # Dépendances du paquet (sans les recommandés) + Xvfb, D-Bus et l'écran de connexion
    # pour les essais ; le paquet est retiré ensuite : chaque test installe le nouveau
    docker run --name preparation-xfce-personnaliser \
        -v xfce-personnaliser-apt:/var/cache/apt/archives -v "$PROJET/paquet:/paquet:ro" \
        debian:trixie bash -c '
            rm -f /etc/apt/apt.conf.d/docker-clean
            apt-get update -qq &&
            DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                /paquet/*.deb xvfb xauth dbus-x11 lightdm-gtk-greeter >/tmp/apt.log 2>&1 ||
                { tail -20 /tmp/apt.log; exit 1; }
            grep "^Need to get" /tmp/apt.log
            dpkg -r xfce-personnaliser >/dev/null && useradd -m essai && apt-get clean'
    docker commit preparation-xfce-personnaliser "$IMAGE" >/dev/null
    docker rm preparation-xfce-personnaliser >/dev/null
fi

docker run --rm --network none -v "$PROJET/paquet:/paquet:ro" -v "$ICI/conteneur:/tests:ro" \
    "$IMAGE" bash /tests/scenario.sh 2>&1 |
    grep -vE "dbus-daemon\[|dbind-WARNING|xfconfd-WARNING|^$"
