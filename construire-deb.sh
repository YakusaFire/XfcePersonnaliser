#!/bin/bash
# construire-deb.sh : fabrique le paquet Debian du projet, sans droits root.
#   ./construire-deb.sh              -> paquet/xfce-personnaliser_<version>_all.deb
#   VERSION=0.2.0 ./construire-deb.sh
# Version par défaut : 0.1.0+git<date du dernier commit>.<commit> (.modifie si des fichiers
# ne sont pas encore commités). Mainteneur : $DEBFULLNAME <$DEBEMAIL>, sinon l'identité git.
#
# Le paquet installe le projet dans /usr/share/xfce-personnaliser/ (interface, bin/, config/,
# script de l'écran de connexion, mémo), des liens dans /usr/bin et l'entrée du menu. Les
# réglages restent propres à chaque utilisateur (~/.config) : bureau-modeles les met en place
# au premier lancement de l'interface. Les images et vidéos ajoutées vont dans
# ~/.local/share/bureau-reglages/ (le dossier du logiciel est en lecture seule).
#   sudo apt install ./paquet/xfce-personnaliser_<version>_all.deb   installe avec les dépendances
#   sudo apt remove xfce-personnaliser                                  désinstalle
set -euo pipefail
umask 022  # dossiers du paquet en 755, quel que soit le umask de la session
ICI=$(cd "$(dirname "$0")" && pwd)
NOM=xfce-personnaliser
cd "$ICI"

if [ -z "${VERSION:-}" ]; then
    VERSION="0.1.0+git$(git log -1 --format=%cd --date=format:%Y%m%d).$(git rev-parse --short HEAD)"
    [ -z "$(git status --porcelain)" ] || VERSION="$VERSION.modifie"
fi
MAINTENEUR="${DEBFULLNAME:-$(git config user.name)} <${DEBEMAIL:-$(git config user.email)}>"

SORTIE="$ICI/paquet"
RACINE="$SORTIE/racine"
DOSSIER=/usr/share/$NOM
rm -rf "$RACINE"
mkdir -p "$RACINE/DEBIAN" "$RACINE$DOSSIER" "$RACINE/usr/bin" "$RACINE/usr/share/applications" \
         "$RACINE/usr/share/doc/$NOM"

# Fichiers du dépôt, sauf ceux ignorés par git : ni fonds/, ni fonds-animes/, ni CLAUDE.md, ni __pycache__
for f in bureau-reglages.py greeter-catppuccin.sh commandes-bureau.md $(git ls-files --cached --others --exclude-standard bin config); do
    if [ -x "$f" ]; then mode=755; else mode=644; fi
    install -D -m "$mode" "$f" "$RACINE$DOSSIER/$f"
done

# Commandes dans /usr/bin : liens relatifs vers le dossier du logiciel (les scripts y
# retrouvent leurs voisins par leur propre chemin). Sauf les deux commandes internes, que seul
# fond-anime lance, par leur chemin : elles n'ont pas de page de manuel
for f in $(git ls-files --cached --others --exclude-standard bin); do
    case "$(basename "$f")" in fond-anime-video|fond-anime-icones) continue ;; esac
    ln -s "../share/$NOM/$f" "$RACINE/usr/bin/$(basename "$f")"
done
ln -s "../share/$NOM/bureau-reglages.py" "$RACINE/usr/bin/bureau-reglages"

# Entrée du menu (même modèle qu'installer.sh), documentation
sed "s|@EXEC@|bureau-reglages|" config/bureau-reglages.desktop > "$RACINE/usr/share/applications/bureau-reglages.desktop"
install -m 644 README.md portabilite.md "$RACINE/usr/share/doc/$NOM/"

# Pages de manuel des commandes principales, en français comme le logiciel, dans le dossier par
# défaut (man1) : sans traduction, « man fond-anime » doit les trouver quelle que soit la langue
mkdir -p "$RACINE/usr/share/man/man1"
for p in man/*.1; do
    gzip -9n < "$p" > "$RACINE/usr/share/man/man1/$(basename "$p").gz"
    chmod 644 "$RACINE/usr/share/man/man1/$(basename "$p").gz"
done
# Licence au format lisible par les outils de Debian (DEP-5). Le texte de la GPL n'est pas mis
# dans le paquet : Debian le fournit dans /usr/share/common-licenses. Avis d'usage de la FSF,
# en anglais : seule la version anglaise de la GPL fait foi.
cat > "$RACINE/usr/share/doc/$NOM/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: XfcePersonnaliser
Source: https://github.com/YakusaFire/XfcePersonnaliser

Files: *
Copyright: $(git log -1 --format=%cd --date=format:%Y) ${DEBFULLNAME:-$(git config user.name)}
License: GPL-3+
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 .
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 .
 On Debian systems, the complete text of the GNU General Public License
 version 3 can be found in "/usr/share/common-licenses/GPL-3".
EOF

# Journal des versions, exigé par Debian (paquet natif : changelog.gz, compressé au maximum et sans
# date dans l'en-tête gzip). Une seule entrée, pour la version construite : l'historique détaillé
# est celui de git. Date du dernier commit, pour qu'une même version donne le même paquet.
gzip -9n > "$RACINE/usr/share/doc/$NOM/changelog.gz" <<EOF
$NOM ($VERSION) unstable; urgency=medium

  * Construit depuis le commit $(git rev-parse --short HEAD) du dépôt
    https://github.com/YakusaFire/XfcePersonnaliser (historique : git log).

 -- $MAINTENEUR  $(date -R -d "@$(git log -1 --format=%ct)")
EOF

# Exception déclarée à lintian : le mémo n'est pas dans /usr/share/doc parce que l'interface
# l'ouvre depuis son propre dossier, et dpkg peut exclure /usr/share/doc (systèmes minimaux)
mkdir -p "$RACINE/usr/share/lintian/overrides"
cat > "$RACINE/usr/share/lintian/overrides/$NOM" <<EOF
# Ouvert par l'interface « Personnalisation du bureau » (MEMO dans bureau-reglages.py)
$NOM: package-contains-documentation-outside-usr-share-doc [usr/share/$NOM/commandes-bureau.md]
# Pages de manuel en français : le correcteur d'orthographe de lintian est anglais
$NOM: typo-in-manual-page * [usr/share/man/man1/*]
EOF
chmod 644 "$RACINE/usr/share/applications/bureau-reglages.desktop" "$RACINE/usr/share/doc/$NOM/copyright" \
    "$RACINE/usr/share/doc/$NOM/changelog.gz" "$RACINE/usr/share/lintian/overrides/$NOM"

# Champs de dépendances : une seule ligne dans le fichier de contrôle d'un paquet binaire
liste() { local r; r=$(printf '%s, ' "$@"); echo "${r%, }"; }
DEPENDS=$(liste python3 python3-gi python3-gi-cairo python3-cairo gir1.2-gtk-3.0 xfconf xfwm4 \
    xfdesktop4 xfce4-panel xfce4-settings x11-utils x11-xserver-utils procps libx11-6 libxext6)
RECOMMANDE=$(liste "picom (>= 12)" mpv ffmpeg mesa-utils xdg-utils exo-utils papirus-icon-theme \
    fonts-inter gnome-themes-extra)
SUGGERE=$(liste compiz-core compiz-gnome compiz-plugins compizconfig-settings-manager marco-common \
    lightdm lightdm-gtk-greeter pkexec)

cat > "$RACINE/DEBIAN/control" <<EOF
Package: $NOM
Version: $VERSION
Section: x11
Priority: optional
Architecture: all
Maintainer: $MAINTENEUR
Installed-Size: $(du -sk "$RACINE/usr" | cut -f1)
Depends: $DEPENDS
Recommends: $RECOMMANDE
Suggests: $SUGGERE
Homepage: https://github.com/YakusaFire/XfcePersonnaliser
Description: personnalisation du bureau Xfce : profils, effets, fond animé
 Interface GTK « Personnalisation du bureau » et commandes pour Xfce sous X11 :
 profils d'apparence complets, effets de fenêtres avec picom (ombres, coins
 arrondis, animations) ou Compiz (effet Génie), fond d'écran animé derrière les
 icônes du bureau, et style Catppuccin Mocha pour l'écran de connexion LightDM.
 .
 Ce qui manque (picom, mpv, Compiz, LightDM…) est grisé dans l'interface, avec
 la commande pour l'installer.
EOF

# Sommes de contrôle des fichiers installés (dpkg --verify, debsums)
(cd "$RACINE" && find usr -type f -print0 | sort -z | xargs -0 md5sum) > "$RACINE/DEBIAN/md5sums"
chmod 644 "$RACINE/DEBIAN/md5sums"

DEB="$SORTIE/${NOM}_${VERSION}_all.deb"
dpkg-deb --root-owner-group -Zxz --build "$RACINE" "$DEB" >/dev/null
rm -rf "$RACINE"
echo "Paquet construit : ${DEB#"$ICI"/}"
echo "Installer : sudo apt install ./${DEB#"$ICI"/}"
