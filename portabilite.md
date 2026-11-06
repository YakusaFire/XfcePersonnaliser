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
| ✅ | Thème GTK `catppuccin-mocha-mauve-standard+default` lu dans `~/.themes/` | `greeter-catppuccin.sh` | Non. **Corrigé** : pris dans `/usr/share/themes` s'il y est, sinon copié depuis `~`, sinon base Adwaita sombre intégrée à GTK (plus d'échec). |
| ✅ | Curseurs `catppuccin-mocha-dark-cursors` lus dans `~/.local/share/icons/` | `greeter-catppuccin.sh` | Non. **Corrigé** : même règle, sinon curseurs par défaut. |
| ✅ | Fond `catppuccin-mocha.png` | `greeter-catppuccin.sh` | **Corrigé** : lu dans `fonds/` (ou le dossier de données), sinon fond uni `#1e1e2e`. |
| ✅ | Papirus / Papirus-Dark copiés depuis `~/.local/share/icons/` s'ils manquent dans `/usr/share/icons/` | `greeter-catppuccin.sh` | **Oui** : paquet `papirus-icon-theme`. **Corrigé** : copie depuis `~` seulement s'il n'est pas installé, sinon icônes Adwaita ; l'interface conseille le paquet. |
| 🟠 | Thème xfwm4 `Catppuccin-Mocha-WM`, police Inter | Profils enregistrés | Thème : non. Police : oui (`fonts-inter`). |
| 🟢 | Textes de l'interface qui citent Catppuccin et Papirus (« Style Catppuccin Mocha », « icônes Papirus ») | `bureau-reglages.py` vers la ligne 1371 | — |

**Fait (étape 4)** : ni téléchargement ni thème fourni avec le logiciel. Chaque élément est
pris là où il est installé, sinon dans le dossier personnel, sinon remplacé : base Adwaita
sombre (fichier CSS intégré à GTK), icônes Adwaita, curseurs par défaut, fond uni. Les
retouches Catppuccin de la fenêtre de connexion restent, et l'interface dit ce qui est
utilisé et quels paquets Debian complètent le rendu (`papirus-icon-theme`, `fonts-inter`).
Le script refuse proprement si lightdm-gtk-greeter manque.

## 3. Chemins propres à cette installation

| | Chemin | Où | Problème |
|---|---|---|---|
| ✅ | `~/Pictures/Wallpapers`, `~/Videos` en dur | `bureau-reglages.py` | **Corrigé** : galerie dans `fonds/`, sélecteurs ouverts dans les dossiers XDG. Avant : sur un Debian en français, `xdg-user-dirs` crée `~/Images` et `~/Vidéos` : les dossiers proposés n'existent pas. Il faut lire `xdg-user-dir PICTURES` / `VIDEOS` (ou `GLib.get_user_special_dir`). |
| ✅ | `$HOME/.local/bin/fond-anime` et `$HOME/.local/bin/bureau-wm` écrits dans les `.desktop` créés | `fond-anime` (démarrage auto, nettoyage), `compiz.desktop` | **Corrigé** : chemin complet trouvé à l'écriture (`chemin_commande`) : un lien vers le script dans le PATH ou `~/.local/bin`, `/usr/bin` pour un paquet, sinon le script lui-même. Le nom seul ne marcherait pas : le PATH de la session XFCE (LightDM) ne contient pas `~/.local/bin`. |
| 🟢 | `xwinwrap` cherché aussi dans `~/.local/bin` | `fond-anime`, interface | Gardé exprès : simple endroit de recherche en plus du PATH (xwinwrap n'est **pas dans Debian**, compilé à la main ici). |
| ✅ | `PATH` complété par `~/.local/bin` | `bureau-reglages.py` | **Corrigé** : l'interface met le `bin/` voisin en tête du PATH ; elle appelle ses propres scripts, installée ou non. `bureau-profil` appelle `bureau-wm` par son chemin (avant : par le PATH). |
| ✅ | `~/.config`, `~/.cache`, `~/.local/share` en dur | tous les scripts, interface, `installer.sh` | **Corrigé** : `$XDG_CONFIG_HOME`, `$XDG_CACHE_HOME`, `$XDG_DATA_HOME` s'ils sont définis (xfconf, picom, GTK et l'autostart les suivent aussi). Thèmes et icônes cherchés comme GTK, dans `$XDG_DATA_DIRS` (`/usr/local/share` compris). |
| ✅ | `fonds/` et `fonds-animes/` dans le dossier du logiciel | interface | **Corrigé** : si ce dossier n'est pas modifiable (installé dans `/usr` par un paquet), `~/.local/share/bureau-reglages/fonds` et `fonds-animes`. Avant, l'interface plantait au démarrage (`PermissionError`). |
| ✅ | `installer.sh` crée des liens vers le dossier du projet | `installer.sh` | Bien pour développer. **Corrigé** pour les autres : paquet `.deb` (`construire-deb.sh`), installé dans `/usr/share/xfce-personnaliser/`, `/usr/bin` et `/usr/share/applications/`. |

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

✅ Dans le paquet (`construire-deb.sh`) : `Depends:` pour les « oui » (plus `python3-gi-cairo`
et `python3-cairo`), `Recommends:` pour picom (>= 12), mpv, ffmpeg, xdg-utils, exo-utils,
papirus-icon-theme et fonts-inter, `Suggests:` pour Compiz, LightDM et pkexec. Tous ces
noms existent dans Debian 13 (vérifié avec `apt-cache`). Reste xwinwrap : soit le compiler
dans le paquet (petit programme C, licence à vérifier), soit le remplacer en mode Compiz par
la fenêtre de `fond-anime-video`.

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
3. ✅ **Chemins** *(fait le 6/11)* : plus de `~/.local/bin` supposé dans les entrées de
   démarrage ni dans le PATH de l'interface ; dossiers XDG suivis partout ; images et vidéos
   dans `~/.local/share/bureau-reglages/` quand le logiciel est en lecture seule (l'interface
   ne plante plus). Reste pour le paquet : une vraie installation à la place des liens de
   `installer.sh`. *(section 3)*
4. ✅ **Écran de connexion** *(fait le 6/11)* : plus d'échec quand un thème manque. Chaque
   élément est pris dans `/usr/share`, sinon copié depuis `~`, sinon remplacé (Adwaita sombre,
   fond uni…). Mode test `RACINE=dossier` (sans root). *(section 2)*
5. ✅ **Paquet `.deb`** *(construit et testé le 6/11)* : `construire-deb.sh` le fabrique sans
   root (`dpkg-deb --root-owner-group`). Vérifié : contenu et droits (root, 755/644), entrée du
   menu (`desktop-file-validate`), dépendances résolues par `apt-get install --simulate`.
   **Testé dans un Debian 13 neuf** (conteneur Docker, `tests/tester-paquet.sh`) : `apt`
   installe le paquet et ses 223 dépendances (109 Mo) ; commandes, premier lancement de
   l'interface sous Xvfb, refus propres, profils, écran de connexion et désinstallation
   fonctionnent. Ce test a révélé et fait corriger :
   - `xfce4-panel --quit` et `-r` attendent sans fin quand aucun panneau ne tourne :
     `bureau-profil load`, `bureau-wm`, `relancer-picom` et l'interface restaient bloqués ;
   - sur un compte neuf, `/general/use_compositing` n'existe pas : `xfconf-query -s` échouait
     (`load` et `bureau-wm xfwm4` s'arrêtaient, picom ne pouvait pas démarrer) ;
   - `pkill -x gtk-window-decorator` ne trouvait jamais le processus (nom tronqué à
     15 caractères) : la décoration de Compiz restait lancée en repassant à xfwm4 ;
   - liste des thèmes GTK vide sur un système neuf (Adwaita est intégré à GTK) ;
   - copies de `bureau-modeles` en lecture seule si le modèle l'était.

   **Reste** : un essai dans une vraie session XFCE (machine virtuelle, pour l'affichage),
   passer `lintian` (absent ici), et choisir une licence (le dépôt n'en a pas : le fichier
   `copyright` du paquet le dit).
6. Facultatif : xwinwrap, Debian 12, traduction.
