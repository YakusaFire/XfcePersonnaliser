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
# retrouvent leurs voisins par leur propre chemin)
for f in $(git ls-files --cached --others --exclude-standard bin); do
    ln -s "../share/$NOM/$f" "$RACINE/usr/bin/$(basename "$f")"
done
ln -s "../share/$NOM/bureau-reglages.py" "$RACINE/usr/bin/bureau-reglages"

# Entrée du menu (même modèle qu'installer.sh), documentation
sed "s|@EXEC@|bureau-reglages|" config/bureau-reglages.desktop > "$RACINE/usr/share/applications/bureau-reglages.desktop"
install -m 644 README.md portabilite.md "$RACINE/usr/share/doc/$NOM/"
cat > "$RACINE/usr/share/doc/$NOM/copyright" <<EOF
XfcePersonnaliser — personnalisation du bureau XFCE
Source : https://github.com/YakusaFire/XfcePersonnaliser

Copyright $(git log -1 --format=%cd --date=format:%Y) ${DEBFULLNAME:-$(git config user.name)}

Aucune licence n'est encore choisie pour ce projet : tous droits réservés à son auteur.
EOF
chmod 644 "$RACINE/usr/share/applications/bureau-reglages.desktop" "$RACINE/usr/share/doc/$NOM/copyright"

cat > "$RACINE/DEBIAN/control" <<EOF
Package: $NOM
Version: $VERSION
Section: x11
Priority: optional
Architecture: all
Maintainer: $MAINTENEUR
Installed-Size: $(du -sk "$RACINE/usr" | cut -f1)
Depends: python3, python3-gi, python3-gi-cairo, python3-cairo, gir1.2-gtk-3.0, xfconf, xfwm4,
 xfdesktop4, xfce4-panel, xfce4-settings, x11-utils, x11-xserver-utils, procps, libx11-6, libxext6
Recommends: picom (>= 12), mpv, ffmpeg, xdg-utils, exo-utils, papirus-icon-theme, fonts-inter
Suggests: compiz-core, compiz-gnome, compiz-plugins, compizconfig-settings-manager, marco-common,
 lightdm, lightdm-gtk-greeter, pkexec
Homepage: https://github.com/YakusaFire/XfcePersonnaliser
Description: personnalisation du bureau XFCE : profils, effets, fond animé
 Interface GTK « Personnalisation du bureau » et commandes pour XFCE sous X11 :
 profils d'apparence complets, effets de fenêtres avec picom (ombres, coins
 arrondis, animations) ou Compiz (effet Génie), fond d'écran animé derrière les
 icônes du bureau, et style Catppuccin Mocha pour l'écran de connexion LightDM.
 .
 Ce qui manque (picom, mpv, Compiz, LightDM…) est grisé dans l'interface, avec
 la commande pour l'installer.
EOF

DEB="$SORTIE/${NOM}_${VERSION}_all.deb"
dpkg-deb --root-owner-group -Zxz --build "$RACINE" "$DEB" >/dev/null
rm -rf "$RACINE"
echo "Paquet construit : ${DEB#"$ICI"/}"
echo "Installer : sudo apt install ./${DEB#"$ICI"/}"
