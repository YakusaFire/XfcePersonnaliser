#!/bin/bash
# Scénario de test du paquet dans un Debian 13 neuf, lancé en root dans le conteneur par
# tests/tester-paquet.sh (dépendances déjà installées dans l'image d'essai, pas de réseau).
set -u
etape() { echo; echo "===== $*"; }
export DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

etape "1. Installation du paquet (dépendances déjà dans l'image d'essai)"
dpkg -i /paquet/*.deb >/tmp/dpkg.log 2>&1; echo "code dpkg : $?"
dpkg -s xfce-personnaliser | grep -E '^(Status|Version)'

etape "2. Commandes et menu"
for c in bureau-reglages bureau-profil bureau-wm fond-anime relancer-picom bureau-modeles fond-anime-fond; do
    printf "%-16s -> %s\n" "$c" "$(readlink -f "$(command -v "$c")")"
done
desktop-file-validate /usr/share/applications/bureau-reglages.desktop 2>/dev/null && echo "entrée du menu : valide" || ls -l /usr/share/applications/bureau-reglages.desktop

MAISON=$(getent passwd essai | cut -d: -f6)  # utilisateur d'essai créé dans l'image
en_essai() { runuser -u essai -- env HOME="$MAISON" LANG=C.UTF-8 XDG_CURRENT_DESKTOP=XFCE XDG_SESSION_TYPE=x11 "$@"; }

etape "3. Premier lancement de l'interface (utilisateur essai, Xvfb + D-Bus)"
en_essai xvfb-run -a dbus-run-session -- python3 /tests/test_ui.py 2>&1 | grep -v -E "Gtk-WARNING|^$"

etape "4. Commandes en ligne"
en_essai bureau-modeles; echo "(bureau-modeles 2e passage : rien à ajouter ci-dessus)"
en_essai bureau-wm
en_essai bureau-profil list
en_essai bureau-wm compiz; echo "code $?"
en_essai relancer-picom; echo "code $?"
en_essai fond-anime /nexiste.mp4; echo "code $?"
en_essai fond-anime auto on; grep '^Exec' $MAISON/.config/autostart/fond-anime.desktop; en_essai fond-anime auto off
# Fenêtre de type bureau du fond animé, sans xwinwrap (Xvfb, sans gestionnaire de fenêtres)
en_essai xvfb-run -a bash -c '
  fond-anime-video --type-bureau 320x200+0+0 -- sleep 3 & sleep 1.5
  xprop -name fond-anime WM_CLASS _NET_WM_WINDOW_TYPE _NET_WM_STATE _NET_WM_DESKTOP WM_HINTS
  wait $!; echo "code fond-anime-video --type-bureau : $?"'

etape "5. Sans panneau lancé : profil, gestionnaire de fenêtres, picom, bouton du panneau (Xvfb)"
en_essai xvfb-run -a dbus-run-session -- bash -c '
  bureau-profil save essai; bureau-profil list | tr "\n" " "; echo
  timeout 60 bureau-profil load essai >/dev/null 2>&1; echo "code load : $? (124 = bloqué)"; sleep 1
  echo "lancés après load : $(pgrep -x -l "xfwm4|xfce4-panel|xfsettingsd" | cut -d" " -f2 | sort | tr "\n" " ")"
  pkill -x xfce4-panel; sleep 1
  timeout 30 bureau-wm xfwm4; echo "code bureau-wm xfwm4 : $?"; sleep 1
  pkill -x xfce4-panel; sleep 1
  timeout 30 relancer-picom arreter; echo "code relancer-picom arreter : $?"
  python3 -c "from importlib.machinery import SourceFileLoader as L; import importlib.util as u; c = L(\"br\", \"/usr/bin/bureau-reglages\"); m = u.module_from_spec(u.spec_from_loader(\"br\", c)); c.exec_module(m); print(m.RELANCE_PANNEAU)" > /tmp/relance.sh 2>/dev/null
  timeout 20 bash /tmp/relance.sh; echo "code bouton « Relancer les panneaux » sans panneau : $?"; sleep 2
  echo "panneau démarré : $(pgrep -x xfce4-panel >/dev/null && echo oui || echo non)"
  timeout 20 bash /tmp/relance.sh; echo "code bouton avec panneau : $?"
' 2>&1 | grep -v -E "Gtk-WARNING|^$|dbus-daemon|dbind-WARNING|xfconfd-WARNING|xfwm4-WARNING|xfce4-panel-WARNING|^\\(xfsettingsd|Xlib|xfwm4-Message|libxfce4"

etape "5b. Profils d'exemple (apparence seulement) : sombre, puis Annuler"
en_essai xvfb-run -a dbus-run-session -- bash -c '
  v() { echo "thème $(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null) | icônes $(xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null) | police $(xfconf-query -c xsettings -p /Gtk/FontName 2>/dev/null)"; }
  echo "profils : $(ls ~/.config/bureau-profils | tr "\n" " ")"
  echo "avant   : $(v)"
  bureau-profil load sombre | tail -1
  echo "sombre  : $(v)"
  timeout 60 bureau-profil load _avant-load >/dev/null 2>&1; echo "code annuler : $?"
  echo "annuler : $(v)"
' 2>&1 | grep -v -E "Gtk-WARNING|^$|dbus-daemon|dbind-WARNING|xfconfd-WARNING|xfwm4-WARNING|xfce4-panel-WARNING|^\(xfsettingsd|Xlib|xfwm4-Message|libxfce4"

etape "6. Écran de connexion (root du conteneur, sans RACINE)"
bash /usr/share/xfce-personnaliser/greeter-catppuccin.sh
grep -E '^(background|icon-theme|cursor|theme-name|font)' /etc/lightdm/lightdm-gtk-greeter.conf
head -1 /usr/share/themes/Catppuccin-Mocha-Greeter/gtk-3.0/gtk.css
xvfb-run -a python3 /tests/test_css.py /usr/share/themes/Catppuccin-Mocha-Greeter/gtk-3.0/gtk.css 2>&1 | grep -v Gtk-WARNING
en_essai xvfb-run -a dbus-run-session -- python3 /tests/test_ui.py connexion 2>&1 | grep -E "^Connexion"
bash /usr/share/xfce-personnaliser/greeter-catppuccin.sh restore
grep -c "Catppuccin" /etc/lightdm/lightdm-gtk-greeter.conf | sed 's/^/lignes Catppuccin après restore : /'

etape "7. Désinstallation"
apt-get remove -y xfce-personnaliser >/dev/null 2>&1; echo "code $?"
ls /usr/bin/bureau-* /usr/share/xfce-personnaliser 2>&1 | head -3
ls $MAISON/.config/picom $MAISON/.local/share/bureau-reglages
