#!/bin/bash
# Installe les commandes du projet dans ~/.local/bin (liens vers ce dossier), leurs pages de
# manuel et l'entrée « Personnalisation du bureau » dans le menu d'XFCE.
# À relancer si le dossier du projet est déplacé.
set -euo pipefail

ICI=$(cd "$(dirname "$0")" && pwd)
BIN="$HOME/.local/bin"
# man cherche les pages à côté de chaque dossier du PATH : ~/.local/bin → ~/.local/share/man
MAN="$HOME/.local/share/man/man1"
MENU="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$BIN" "$MAN" "$MENU" "$ICI/fonds" "$ICI/fonds-animes"

# lier SOURCE NOM [DOSSIER] : un vrai fichier déjà présent est gardé de côté plutôt qu'écrasé
lier() {
    local cible="${3:-$BIN}/$2"
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
for p in "$ICI"/man/*.1; do lier "$p" "$(basename "$p")" "$MAN"; done

# Entrée du menu : modèle commun avec le paquet Debian (construire-deb.sh), avec le chemin du lien
EXEC="$BIN/bureau-reglages"
sed "s|@EXEC@|${EXEC//&/\\&}|" "$ICI/config/bureau-reglages.desktop" > "$MENU/bureau-reglages.desktop"

# Réglages de départ (picom, Alt+Tab, démarrage automatique) qui manquent encore
"$ICI/bin/bureau-modeles"

echo "Commandes installées dans $BIN : $(cd "$ICI/bin" && echo *) bureau-reglages"
echo "Pages de manuel : $(cd "$ICI/man" && echo *.1 | sed 's/\.1//g') (man fond-anime…)"
echo "Entrée du menu : Paramètres → Personnalisation du bureau"
