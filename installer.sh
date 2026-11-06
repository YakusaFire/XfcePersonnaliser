#!/bin/bash
# Installe les commandes du projet dans ~/.local/bin (liens vers ce dossier)
# et l'entrée « Personnalisation du bureau » dans le menu d'XFCE.
# À relancer si le dossier du projet est déplacé.
set -euo pipefail

ICI=$(cd "$(dirname "$0")" && pwd)
BIN="$HOME/.local/bin"
MENU="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
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

# Entrée du menu : modèle commun avec le paquet Debian (construire-deb.sh), avec le chemin du lien
EXEC="$BIN/bureau-reglages"
sed "s|@EXEC@|${EXEC//&/\\&}|" "$ICI/config/bureau-reglages.desktop" > "$MENU/bureau-reglages.desktop"

# Réglages de départ (picom, Alt+Tab, démarrage automatique) qui manquent encore
"$ICI/bin/bureau-modeles"

echo "Commandes installées dans $BIN : $(cd "$ICI/bin" && echo *) bureau-reglages"
echo "Entrée du menu : Paramètres → Personnalisation du bureau"
