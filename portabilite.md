# Rendre XfcePersonnaliser utilisable sur n'importe quel Debian

Inventaire de ce qui ne marche aujourd'hui que sur la machine où le projet a été écrit.
Cible proposée : **Debian 13 (trixie) ou plus récent, XFCE 4.20, session X11**.

Légende : 🔴 bloquant (la fonction ne marche pas du tout ailleurs) · 🟠 marche mal ou à
moitié · 🟢 détail.

## 1. Fichiers de réglage qui ne sont pas dans le dépôt

C'est le plus gros problème : plusieurs fonctions s'appuient sur des fichiers créés à la
main sur cette machine, qu'aucun script ne crée.

| | Fichier | Utilisé par | Ce qui se passe s'il manque |
|---|---|---|---|
| 🔴 | `~/.config/picom/picom.conf` (picom 12, avec `rules = ( … )` et `animations = ( … )`) | `fond-anime` (`preparer_picom`), onglet Effets de l'interface (`ConfigPicom`) | Le fond animé ne passe jamais sous le bureau : il retombe sur xwinwrap (icônes en lecture seule). Les réglages d'ombres, coins arrondis et animations n'ont aucun effet. picom tourne avec ses réglages par défaut. |
| 🔴 | `~/.config/autostart/picom.desktop` (coupe le compositeur d'xfwm4, lance picom, relance le panneau 4 s après) | `bureau-wm`, `bureau-profil load`, `fond-anime` (`picom_pret`), interrupteur picom de l'interface (`autostart_regler`) | L'interrupteur picom ne fait rien (`autostart_regler` sort sans rien écrire). `picom_pret` répond « pas de picom ». picom ne démarre pas à l'ouverture de session. |
| 🔴 | `~/.config/autostart/compiz.desktop` | `bureau-wm compiz` | Compiz marche pour la session en cours mais ne revient pas à la session suivante. |
| 🟠 | `~/.config/gtk-3.0/gtk.css` (style du Alt+Tab, `xfwm-tabwin`) | Interrupteur Alt+Tab | L'interrupteur est grisé (`alttab_dispo` faux) : la fonction n'existe pas pour les autres. |
| 🟠 | Profils `catppuccin`, `macos-sombre`, `macos-clair` dans `~/.config/bureau-profils/` | Onglet Profils | Liste vide au premier lancement : rien à essayer. |

**À faire** : mettre des modèles dans `config/` (picom.conf, les deux `.desktop`, le CSS du
Alt+Tab) et les installer au premier lancement **seulement s'ils n'existent pas**. Ne jamais
écraser un `picom.conf` existant : ajouter alors juste la règle du fond animé, comme le fait
déjà `preparer_picom`.

## 2. Thèmes, icônes, polices et fonds supposés présents

| | Élément | Où | Dans Debian ? |
|---|---|---|---|
| 🔴 | Thème GTK `catppuccin-mocha-mauve-standard+default` lu dans `~/.themes/` | `greeter-catppuccin.sh` (`cp -a "$U_HOME/.themes/$GTK_THEME"`) | Non. Le script échoue (`set -e`). |
| 🔴 | Curseurs `catppuccin-mocha-dark-cursors` lus dans `~/.local/share/icons/` | `greeter-catppuccin.sh` | Non. |
| 🟠 | Fond `catppuccin-mocha.png` | `greeter-catppuccin.sh` | ✅ lu dans `fonds/` du projet (ancien emplacement en secours) ; mais `fonds/` n'est pas versionné : l'image est à fournir. |
| 🟠 | Papirus / Papirus-Dark copiés depuis `~/.local/share/icons/` s'ils manquent dans `/usr/share/icons/` | `greeter-catppuccin.sh` | **Oui** : paquet `papirus-icon-theme`, inutile de copier ~1 Go. |
| 🟠 | Thème xfwm4 `Catppuccin-Mocha-WM`, police Inter | Profils enregistrés | Thème : non. Police : oui (`fonts-inter`). |
| 🟢 | Textes de l'interface qui citent Catppuccin et Papirus (« Style Catppuccin Mocha », « icônes Papirus ») | `bureau-reglages.py` vers la ligne 1371 | — |

**À faire** : pour l'écran de connexion, deux choix possibles. Soit le script télécharge le
thème et les curseurs Catppuccin depuis leurs dépôts GitHub officiels (versions fixées), soit
on les met dans le paquet (licence MIT). Ensuite, prendre `papirus-icon-theme` et
`fonts-inter` dans Debian et griser l'option si un élément manque, au lieu de planter.

## 3. Chemins propres à cette installation

| | Chemin | Où | Problème |
|---|---|---|---|
| ✅ | `~/Pictures/Wallpapers`, `~/Videos` en dur | `bureau-reglages.py` | **Corrigé** : galerie dans `fonds/`, sélecteurs ouverts dans les dossiers XDG. Avant : sur un Debian en français, `xdg-user-dirs` crée `~/Images` et `~/Vidéos` : les dossiers proposés n'existent pas. Il faut lire `xdg-user-dir PICTURES` / `VIDEOS` (ou `GLib.get_user_special_dir`). |
| 🟠 | `$HOME/.local/bin/fond-anime` et `$HOME/.local/bin/bureau-wm` écrits dans les `.desktop` créés | `fond-anime` (démarrage auto, nettoyage), `compiz.desktop` | Faux si le logiciel est installé dans `/usr/bin` par un paquet. Écrire le nom de la commande seul, ou le chemin réel du script. |
| 🟠 | `xwinwrap` cherché dans `~/.local/bin` | `fond-anime` ligne 29 | xwinwrap n'est **pas dans Debian** : compilé à la main ici. |
| 🟢 | `PATH` complété par `~/.local/bin` | `bureau-reglages.py` ligne 61 | Sans effet gênant, mais inutile une fois en paquet. |
| 🟢 | `installer.sh` crée des liens vers le dossier du projet | `installer.sh` | Bien pour développer ; pour les autres il faut une vraie installation (`/usr/bin`, `/usr/share/bureau-reglages/`, `/usr/share/applications/`). |

## 4. Dépendances : paquets Debian 13

Aucune n'est installée ni vérifiée par le projet aujourd'hui (seul `mpv` est testé).

| Rôle | Commandes | Paquet Debian 13 | Indispensable ? |
|---|---|---|---|
| Interface | `python3`, GTK 3 | `python3`, `python3-gi`, `gir1.2-gtk-3.0` | oui |
| Bureau | `xfconf-query`, `xfwm4`, `xfdesktop`, `xfce4-panel`, `xfsettingsd` | `xfconf`, `xfwm4`, `xfdesktop4`, `xfce4-panel`, `xfce4-settings` | oui |
| Outils X11 | `xprop`, `xwininfo`, `xrandr`, libX11 / libXext | `x11-utils`, `x11-xserver-utils`, `libx11-6`, `libxext6` | oui |
| Divers | `setpriv`, `pgrep` / `pkill` | `util-linux`, `procps` | oui (déjà présents partout) |
| Effets | `picom` 12.5 | `picom` | conseillé |
| Fond animé | `mpv` 0.40, `ffmpeg` / `ffprobe` 7.1 | `mpv`, `ffmpeg` | conseillé |
| Compiz | `compiz` 0.8.18, `gtk-window-decorator` | `compiz-core`, `compiz-gnome` (+ `compiz-plugins` pour l'effet Génie) | facultatif |
| Décoration Compiz | `gsettings set org.mate.Marco.general …` | `marco-common` (schéma) | facultatif, avec Compiz |
| Fond animé en mode Compiz | `xwinwrap` | **absent de Debian** | facultatif |
| Écran de connexion | `pkexec`, LightDM + lightdm-gtk-greeter | `pkexec`, `lightdm`, `lightdm-gtk-greeter` | facultatif |
| Icônes, police | Papirus, Inter | `papirus-icon-theme`, `fonts-inter` | conseillé |

Pour le paquet : `Depends:` pour les « oui », `Recommends:` pour picom, mpv, ffmpeg et les
icônes, `Suggests:` pour Compiz et LightDM. xwinwrap : soit le compiler dans le paquet (petit
programme C, licence MIT à vérifier), soit le remplacer en mode Compiz par la fenêtre de
`fond-anime-video`.

## 5. Versions : pourquoi Debian 13 au minimum

- 🔴 **picom 12** : la syntaxe `rules = ( … )`, les `animations` et la règle du fond animé
  n'existent pas dans picom 10 (Debian 12). Rendre le projet compatible avec Debian 12
  demanderait une seconde configuration picom, à base de `opacity-rule` et `shader` par
  fenêtre (sans animations).
- 🟠 **XFCE 4.18** (Debian 12) : à tester (noms des propriétés xfconf du fond d'écran,
  comportement du panneau).
- 🟢 Python 3.13, GTK 3.24, mpv 0.40 : rien de spécial utilisé, Debian 12 conviendrait.

## 6. Ce que le logiciel suppose de la session

| | Supposition | Ce qui arrive ailleurs |
|---|---|---|
| 🔴 | Session **XFCE** | Avec GNOME ou KDE, xfconf, xfwm4 et xfdesktop ne servent à rien : l'interface affiche des réglages sans effet. Il faut vérifier `XDG_CURRENT_DESKTOP` au lancement et prévenir. |
| 🔴 | Session **X11** | Sous Wayland (XFCE 4.20 le propose à titre expérimental), picom, `mpv --wid`, xprop et les fenêtres override-redirect ne marchent pas. Vérifier `XDG_SESSION_TYPE`. |
| 🟠 | Le dock est le **panneau 2**, en masquage intelligent, et la relance du panneau corrige sa zone de survol | Avec un autre agencement de panneaux, la relance ne gêne pas mais l'explication de l'interface ne colle plus. Rien de cassé. |
| 🟠 | Carte graphique qui gère bien `backend = "glx"` | Sur une machine virtuelle ou un vieux pilote, picom glx peut échouer ou afficher un écran noir : prévoir un repli sur `xrender` et une vérification `pgrep -x picom` après le lancement. |
| 🟢 | `XDG_VTNR` défini (pause quand on change de console) | Déjà géré : la vérification est sautée s'il manque. |
| 🟢 | Un seul utilisateur, droits sudo / polkit | Normal pour un poste perso. |

## 7. Langue

🟢 L'interface et les messages sont en français, sans gettext. Ça suffit pour des
utilisateurs francophones ; pour aller plus loin, il faudrait passer les textes par
`gettext` et ajouter un fichier `.po` anglais.

## Ordre de travail proposé

1. ✅ **Détection** *(fait le 6/11)* : bandeau si la session n'est pas XFCE sous X11 ou si
   xfconf-query manque ; options grisées avec la commande `apt` (picom, mpv, ffmpeg, Compiz,
   ccsm, pkexec, lightdm-gtk-greeter, dm-tool, paramètres d'XFCE) ; écran de connexion grisé
   si le système utilise un autre gestionnaire que LightDM ; `bureau-wm`, `relancer-picom` et
   `fond-anime` refusent proprement ce qui ne peut pas marcher. *(sections 4 et 6)*
2. ✅ **Modèles de configuration** *(fait le 6/11)* : `config/picom/picom.conf`,
   `config/gtk-3.0/alttab.css`, `config/autostart/picom.desktop` et `compiz.desktop`, copiés
   par `bin/bureau-modeles` (installateur, ouverture de l'interface, `fond-anime`) seulement
   s'ils manquent. Les entrées de démarrage arrivent désactivées sauf si picom / Compiz tourne
   déjà ; le Alt+Tab arrive désactivé ; elles ne lancent rien si le programme manque.
   Les images de fond sont rangées dans `fonds/` (galerie, ajout par copie, écran de
   connexion) et les sélecteurs de fichiers s'ouvrent dans le dossier Images / Vidéos XDG.
   Reste : des profils d'exemple. *(sections 1 et 3)*
3. **Chemins** : dossiers XDG, plus de `~/.local/bin` écrit en dur. *(section 3)*
4. **Écran de connexion** : téléchargement ou fourniture du thème, plus de copie depuis `~`.
   *(section 2)*
5. **Paquet `.deb`** avec les dépendances, puis test dans une machine virtuelle Debian 13 +
   XFCE neuve.
6. Facultatif : xwinwrap, Debian 12, traduction.
