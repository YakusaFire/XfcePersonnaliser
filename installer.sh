#!/bin/bash
# Installe les commandes du projet dans ~/.local/bin (liens vers ce dossier)
# et l'entrée « Personnalisation du bureau » dans le menu d'XFCE.
# À relancer si le dossier du projet est déplacé.
set -euo pipefail

ICI=$(cd "$(dirname "$0")" && pwd)
BIN="$HOME/.local/bin"
MENU="$HOME/.local/share/applications"
mkdir -p "$BIN" "$MENU" "$ICI/fonds" "$ICI/fonds-animes"

# Un vrai fichier déjà présent est gardé de côté plutôt qu'écrasé
lier() {
    local cible="$BIN/$2"
    if [ -e "$cible" ] && [ ! -L "$cible" ]; then
        mv "$cible" "$cible.avant-installation"
        echo "Ancien $2 gardé dans $cible.avant-installation"
    fi
    ln -sfn "$1" "$cible"
}

chmod +x "$ICI/bureau-reglages.py" "$ICI/greeter-catppuccin.sh"
for f in "$ICI"/bin/*; do
    [ -f "$f" ] || continue  # pas les dossiers (ex. __pycache__ laissé par Python)
    chmod +x "$f"
    lier "$f" "$(basename "$f")"
done
lier "$ICI/bureau-reglages.py" bureau-reglages

cat > "$MENU/bureau-reglages.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Personnalisation du bureau
Comment=Profils, thème, fond d'écran, effets et écran de connexion
Exec=$BIN/bureau-reglages
Icon=preferences-desktop-theme
Terminal=false
Categories=Settings;DesktopSettings;X-XFCE-SettingsDialog;X-XFCE-PersonalSettings;
Keywords=thème;profil;catppuccin;picom;compiz;fond;wallpaper;
StartupNotify=true
EOF

# Réglages de départ (picom, Alt+Tab, démarrage automatique) qui manquent encore
"$ICI/bin/bureau-modeles"

echo "Commandes installées dans $BIN : $(cd "$ICI/bin" && echo *) bureau-reglages"
echo "Entrée du menu : Paramètres → Personnalisation du bureau"
