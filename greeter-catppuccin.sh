#!/bin/bash
# Applique le style Catppuccin Mocha à l'écran de connexion LightDM (lightdm-gtk-greeter).
# Usage : sudo ./greeter-catppuccin.sh          -> installe
#         sudo ./greeter-catppuccin.sh restore  -> remet la config d'origine
set -e

[ "$(id -u)" -eq 0 ] || { echo "Lance ce script avec sudo."; exit 1; }

# Utilisateur qui a lancé sudo (terminal) ou pkexec (bureau-reglages)
U_NAME=${SUDO_USER:-}
[ -z "$U_NAME" ] && [ -n "${PKEXEC_UID:-}" ] && U_NAME=$(id -nu "$PKEXEC_UID")
[ -n "$U_NAME" ] || { echo "Lance ce script avec sudo ou pkexec depuis ta session."; exit 1; }
U_HOME=$(getent passwd "$U_NAME" | cut -d: -f6)
CONF=/etc/lightdm/lightdm-gtk-greeter.conf
BACKUP=$CONF.avant-catppuccin

GTK_THEME=catppuccin-mocha-mauve-standard+default
GREETER_THEME=Catppuccin-Mocha-Greeter
CURSORS=catppuccin-mocha-dark-cursors
WALL=/usr/share/backgrounds/catppuccin/catppuccin-mocha.png

if [ "$1" = "restore" ]; then
    [ -f "$BACKUP" ] && cp "$BACKUP" "$CONF" && echo "Config d'origine restaurée."
    exit 0
fi

# 1. Thème GTK, icônes, curseurs et fond d'écran dans des dossiers lisibles par lightdm
echo "Copie du thème GTK..."
cp -a "$U_HOME/.themes/$GTK_THEME" /usr/share/themes/

echo "Copie des icônes et curseurs (Papirus fait ~1 Go, patience)..."
for d in Papirus Papirus-Dark "$CURSORS"; do
    [ -d "/usr/share/icons/$d" ] || cp -a "$U_HOME/.local/share/icons/$d" /usr/share/icons/
done

# Image prise dans le dossier fonds/ du projet (ancien emplacement en secours)
ICI=$(dirname "$(realpath "$0")")
SOURCE_FOND="$ICI/fonds/catppuccin-mocha.png"
[ -f "$SOURCE_FOND" ] || SOURCE_FOND="$U_HOME/Pictures/Wallpapers/catppuccin-mocha.png"
mkdir -p "$(dirname "$WALL")"
cp "$SOURCE_FOND" "$WALL"

chown -R root:root "/usr/share/themes/$GTK_THEME" /usr/share/icons/Papirus /usr/share/icons/Papirus-Dark \
    "/usr/share/icons/$CURSORS" "$(dirname "$WALL")"
chmod -R a+rX "/usr/share/themes/$GTK_THEME" /usr/share/icons/Papirus /usr/share/icons/Papirus-Dark \
    "/usr/share/icons/$CURSORS" "$(dirname "$WALL")"

# 2. Thème dédié au greeter : Catppuccin + retouches de la fenêtre de connexion
mkdir -p "/usr/share/themes/$GREETER_THEME/gtk-3.0"
cat > "/usr/share/themes/$GREETER_THEME/index.theme" <<EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=$GREETER_THEME
Comment=Catppuccin Mocha pour lightdm-gtk-greeter

[X-GNOME-Metatheme]
GtkTheme=$GREETER_THEME
IconTheme=Papirus-Dark
CursorTheme=$CURSORS
EOF

cat > "/usr/share/themes/$GREETER_THEME/gtk-3.0/gtk.css" <<'EOF'
@import url("../../catppuccin-mocha-mauve-standard+default/gtk-3.0/gtk.css");

/* Palette Catppuccin Mocha */
@define-color ctp_base     #1e1e2e;
@define-color ctp_mantle   #181825;
@define-color ctp_crust    #11111b;
@define-color ctp_surface0 #313244;
@define-color ctp_surface1 #45475a;
@define-color ctp_text     #cdd6f4;
@define-color ctp_subtext  #a6adc8;
@define-color ctp_mauve    #cba6f7;
@define-color ctp_red      #f38ba8;

* { font-family: "Inter"; }

/* Barre du haut (horloge, session, langue, alimentation) */
#panel_window {
    background-color: alpha(@ctp_crust, 0.75);
    color: @ctp_text;
    border-bottom: 1px solid alpha(@ctp_mauve, 0.25);
}
#panel_window menubar,
#panel_window menubar > menuitem {
    background: transparent;
    color: @ctp_text;
    padding: 2px 6px;
}
#panel_window menubar > menuitem:hover {
    background-color: alpha(@ctp_mauve, 0.2);
    border-radius: 8px;
}
#clock_label { color: @ctp_text; font-weight: 600; }

/* Fenêtre de connexion */
#login_window,
#power_window {
    background-color: alpha(@ctp_base, 0.92);
    color: @ctp_text;
    border: 2px solid alpha(@ctp_mauve, 0.6);
    border-radius: 18px;
    box-shadow: 0 10px 40px alpha(@ctp_crust, 0.8);
}
#login_window #content_frame,
#login_window #buttonbox_frame {
    background: transparent;
    border: none;
    padding: 0;
}
/* Espace sous l'avatar pour que les boutons ne le chevauchent pas */
#login_window #content_frame { padding: 6px 16px 22px 16px; }
#login_window #buttonbox_frame { padding: 10px 24px 22px 24px; }
#login_window #buttonbox_frame button { margin-left: 8px; }
#login_window #greeter_infobar { border-radius: 10px; }

#login_window label { color: @ctp_text; }
#login_window #message_label { color: @ctp_subtext; }

/* Avatar */
#login_window #user_image_border {
    background: transparent;
    border: 2px solid @ctp_mauve;
    border-radius: 50%;
    padding: 0;
    margin-bottom: 6px;
}

/* Liste des utilisateurs et champ mot de passe */
#login_window combobox button,
#login_window entry {
    background-color: @ctp_surface0;
    color: @ctp_text;
    border: 1px solid @ctp_surface1;
    border-radius: 10px;
    min-height: 34px;
    padding: 0 10px;
    box-shadow: none;
}
#login_window entry:focus {
    border-color: @ctp_mauve;
    box-shadow: 0 0 0 2px alpha(@ctp_mauve, 0.3);
}

/* Bouton « Se connecter » */
#login_window #login_button {
    background-image: none;
    background-color: @ctp_mauve;
    color: @ctp_crust;
    font-weight: 700;
    border: none;
    border-radius: 10px;
    min-height: 34px;
    padding: 0 18px;
}
#login_window #login_button:hover { background-color: shade(@ctp_mauve, 1.1); }

#login_window #cancel_button,
#power_window #cancel_button {
    background-image: none;
    background-color: @ctp_surface0;
    color: @ctp_text;
    border-radius: 10px;
}

/* Fenêtre Redémarrer / Éteindre */
#power_window label { color: @ctp_text; }
#power_window #power_ok_button {
    background-image: none;
    background-color: @ctp_red;
    color: @ctp_crust;
    font-weight: 700;
    border: none;
    border-radius: 10px;
}
EOF
chmod -R a+rX "/usr/share/themes/$GREETER_THEME"

# 3. Configuration du greeter (sauvegarde de l'original une seule fois)
[ -f "$BACKUP" ] || cp "$CONF" "$BACKUP"
cat > "$CONF" <<EOF
# Style Catppuccin Mocha — généré par greeter-catppuccin.sh
# Original : $BACKUP
[greeter]
background=$WALL
user-background=false
theme-name=$GREETER_THEME
icon-theme-name=Papirus-Dark
cursor-theme-name=$CURSORS
cursor-theme-size=24
font-name=Inter 11
xft-antialias=true
xft-hintstyle=hintslight
xft-rgba=rgb
indicators=~host;~spacer;~clock;~spacer;~session;~language;~a11y;~power
clock-format=%A %d %B   %H:%M
position=50%,center 50%,center
round-user-image=true
EOF

echo
echo "Écran de connexion configuré en Catppuccin Mocha."
echo "Aperçu sans redémarrer : verrouille ta session (Ctrl+Alt+Suppr ou xflock4) ou déconnecte-toi."
