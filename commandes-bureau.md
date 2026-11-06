# Commandes de personnalisation du bureau XFCE

Mémo des commandes créées pour styliser le bureau (Debian 13 + XFCE).

---

## `bureau-reglages` — interface graphique

Une fenêtre qui regroupe tout ce mémo. Menu **Paramètres → Personnalisation du bureau**
(aussi dans le Gestionnaire de paramètres d'XFCE), ou la commande `bureau-reglages`.

| Page | Ce qu'on peut y faire |
|---|---|
| Profils | Appliquer, enregistrer ou mettre à la corbeille un profil ; annuler le dernier chargement |
| Apparence | Thème des applications, barre de titre, icônes, curseur et sa taille, polices |
| Fond d'écran | Choisir l'image du bureau |
| Fond animé | Lancer / arrêter le fond animé, lancement à l'ouverture de session, pause automatique ; voir les vidéos de `fonds-animes/` avec un aperçu animé, en choisir une, en ajouter ou en retirer |
| Fenêtres et effets | xfwm4 + picom ou Compiz ; picom, animations, ombres, fondu, arrondi des coins, Alt+Tab stylisé |
| Écran de connexion | Mettre ou retirer le style Catppuccin (mot de passe demandé), aperçu en verrouillant |
| Outils | Relancer les panneaux, le gestionnaire de fenêtres ou picom ; ouvrir ce mémo |

> Les réglages de la page Apparence s'appliquent tout de suite, mais ne sont gardés
> dans un profil que si on l'enregistre.
> Picom désactivé : xfwm4 reprend son compositeur intégré et `bureau-profil load` ne le
> relance plus ; `bureau-wm xfwm4` le réactive.
> Alt+Tab stylisé désactivé : `gtk.css` est renommé en `gtk.css.desactive`.
> **Programmes manquants** : une option dont le programme n'est pas installé (picom, mpv,
> Compiz, ccsm, LightDM…) est grisée, avec la commande `sudo apt install …` à lancer ; la liste
> est relue à chaque retour sur la fenêtre. Sans ffmpeg, pas de miniatures des vidéos.
> Fond animé : il faut mpv, plus picom (vidéo sous le bureau) ou xwinwrap ; en mode Compiz,
> xwinwrap seulement. Un bandeau prévient si la session n'est pas XFCE ou est sous Wayland.

---

## `bureau-profil` — enregistrer / remettre une apparence

Enregistre ou restaure tout le look du bureau : thème, icônes, curseur, polices,
barres de titre, panneaux, lanceurs du dock, fond d'écran, terminal Terminator,
style du Alt+Tab et config picom.

| Commande | Effet |
|---|---|
| `bureau-profil list` | Liste les profils enregistrés |
| `bureau-profil load <nom>` | Applique un profil |
| `bureau-profil save <nom>` | Enregistre l'apparence actuelle sous ce nom |
| `bureau-profil load _avant-load` | Annule le dernier `load` |

Profils disponibles :

| Profil | Style |
|---|---|
| `catppuccin` | Catppuccin Mocha : sombre, pastel, accent mauve |
| `macos-sombre` | macOS sombre (WhiteSur), barre en haut, dock en bas |
| `macos-clair` | macOS clair (WhiteSur) |

Exemples :

```bash
bureau-profil load macos-sombre
bureau-profil load catppuccin
bureau-profil save mon-theme
```

> Le dernier profil chargé reste actif après un redémarrage.
> Chaque `load` sauvegarde d'abord l'état actuel dans `_avant-load`.

---

## `bureau-wm` — choisir le gestionnaire de fenêtres

| Commande | Effet |
|---|---|
| `bureau-wm` | Affiche le mode actuel (`compiz` ou `xfwm4`) |
| `bureau-wm compiz` | Compiz : effet **Génie** (Magic Lamp) à la réduction |
| `bureau-wm xfwm4` | Gestionnaire d'XFCE + picom : animation de glissement vers le bas, coins arrondis, Alt+Tab stylisé |
| `bureau-wm theme` | Recale la barre de titre de Compiz sur le thème actuel |

Le choix est conservé au redémarrage.
`bureau-wm compiz` refuse si Compiz n'est pas installé (et donne la commande `apt`) ;
`bureau-wm xfwm4` sans picom laisse xfwm4 garder son compositeur intégré. Sans le paquet
`marco-common`, `bureau-wm theme` ne recale pas la barre de titre et le dit.

```bash
bureau-wm compiz
bureau-wm xfwm4
```

---

## `fond-anime` — fond d'écran animé

Lit une vidéo en boucle, sans le son, à la place du fond d'écran.
Aussi réglable depuis `bureau-reglages`, onglet **Fond animé** : un clic sur une vidéo
la montre dans l'aperçu, un double-clic la met en fond d'écran.

**Avec picom (mode xfwm4 + picom)**, la vidéo passe *sous* le vrai bureau : les icônes
sont celles d'XFCE et s'utilisent normalement (déplacer, supprimer, renommer, créer un
lanceur ou un dossier, glisser depuis Thunar, menu du clic droit). Pour ça :

1. `fond-anime-video` ouvre la fenêtre de la vidéo tout en bas de l'écran, sous xfdesktop, et l'y garde ;
2. `fond-anime-fond` remplace le fond de xfdesktop par une couleur unie, la couleur moyenne
   de la vidéo (les bords des icônes et l'ombre de leurs noms s'y fondent), et garde le vrai
   fond de côté ;
3. picom rend cette couleur transparente (shader `fond-anime.glsl`), ce qui laisse voir la vidéo.
   La règle ne s'applique que pendant le fond animé, quand la fenêtre du bureau porte la
   propriété `_FOND_ANIME` : un fond d'écran normal n'est jamais touché.

**Pause automatique** (avec picom, activée par défaut) : chaque seconde, `fond-anime-video`
regarde si la vidéo se voit. Elle se met en pause quand une fenêtre est en plein écran ou
agrandie sur l'espace de travail courant, quand l'écran est éteint ou quand la session est
verrouillée, et repart dès que le bureau se revoit. mpv passe alors d'environ 6 % d'un cœur
à 0,1 %, et la carte graphique ne décode plus la vidéo. Réglage : `fond-anime pause-auto on|off`,
ou l'interrupteur de l'onglet « Fond animé ».

**Sans picom (mode Compiz)**, la vidéo recouvre le bureau et `fond-anime-icones` réaffiche les
icônes par-dessus : elles s'ouvrent au double-clic mais ne se déplacent pas, et il n'y a pas
de pause automatique.

| Commande | Effet |
|---|---|
| `fond-anime VIDEO.mp4` | Lance cette vidéo en fond d'écran et la mémorise |
| `fond-anime` | Relance la dernière vidéo mémorisée (réaffiche aussi les icônes) |
| `fond-anime stop` | Arrête le fond animé : le fond d'écran normal réapparaît |
| `fond-anime actualiser` | Replace le fond animé dans le bon mode (fait tout seul après un changement de profil, de gestionnaire de fenêtres ou de picom) |
| `fond-anime auto on` | Lance le fond animé à chaque ouverture de session (l'entrée de démarrage reçoit le chemin complet de la commande, car le PATH de la session ne contient pas `~/.local/bin`) |
| `fond-anime auto off` | Ne le lance plus au démarrage |
| `fond-anime pause-auto on` | Met la vidéo en pause tant qu'elle ne se voit pas (réglage par défaut) |
| `fond-anime pause-auto off` | La vidéo tourne tout le temps, même cachée |
| `fond-anime --help` | Affiche l'aide |
| `pgrep -af "^mpv .*fond-anime-mpv"` | Vérifie s'il tourne (aucune ligne = arrêté) |
| `fond-anime-fond etat` | Dit si le fond de xfdesktop est masqué (`masqué`) ou normal |
| `fond-anime-fond restaurer` | Remet le vrai fond d'écran si le bureau reste noir sans vidéo |

Les vidéos à utiliser se rangent dans le dossier **`fonds-animes/`** de ce projet
(`~/Documents/PROJET/XfcePersonnaliser/fonds-animes/`). Il suffit d'y copier une vidéo
(mp4, webm, mkv, mov…) pour qu'elle apparaisse dans l'onglet ; le bouton « Ajouter des vidéos… »
fait la copie. Vidéos actuelles (1920×1080, 30 images/s) :

| Vidéo | Boucle |
|---|---|
| `Claude_fond_ecran_anime.mp4` | 10 s, 15 Mo |
| `Claude_fond_ecran_anime_1080p.mp4` | 30 s, 25 Mo |

Exemples :

```bash
fond-anime ~/Documents/PROJET/XfcePersonnaliser/fonds-animes/Claude_fond_ecran_anime_1080p.mp4
fond-anime stop
fond-anime auto off
```

> Tant qu'il tourne, il recouvre le fond d'écran choisi dans un profil ou dans `bureau-reglages` ;
> `fond-anime stop` le remet. Un profil enregistré pendant le fond animé garde le vrai fond d'écran.
> Si la session se ferme pendant le fond animé, le fond d'écran est remis à l'ouverture suivante
> (entrée `fond-anime-nettoyage.desktop`, créée et retirée toute seule).
> La règle de picom et le shader sont ajoutés tout seuls à `~/.config/picom/` s'ils manquent
> (par exemple après le chargement d'un ancien profil).
> Dépendances : `mpv`, `xrandr` ; `picom` pour la vidéo sous le bureau, sinon `xwinwrap`
> (`~/.local/bin/xwinwrap`, absent des dépôts Debian ; seul possible en mode Compiz) ;
> `ffmpeg` / `ffprobe` pour la couleur de masquage, les miniatures et les durées de l'onglet.
> S'il ne peut pas se lancer, `fond-anime` dit ce qui manque (picom absent, arrêté ou sans
> bloc `rules`, xwinwrap absent) et remet le fond d'écran.

---

## `greeter-catppuccin.sh` — écran de connexion (LightDM)

L'écran de connexion tourne sous l'utilisateur `lightdm`, qui ne peut pas lire `~/.themes`
ni `~/.local/share/icons`. Pour chaque élément, le script prend la version installée pour
tout le système (`/usr/share`, `/usr/local/share`), sinon copie celle du dossier personnel
dans `/usr/share/…`, sinon la remplace :

| Élément | S'il manque |
|---|---|
| Thème GTK `catppuccin-mocha-mauve-standard+default` | Base Adwaita sombre, intégrée à GTK |
| Icônes Papirus-Dark (et Papirus) | Icônes Adwaita — `sudo apt install papirus-icon-theme` |
| Curseurs `catppuccin-mocha-dark-cursors` | Curseurs par défaut |
| Image `catppuccin-mocha.png` (dossier des fonds de l'interface) | Fond uni `#1e1e2e` |
| Police Inter (installée pour tout le système) | Police par défaut — `sudo apt install fonts-inter` |

Il crée ensuite un thème dédié `Catppuccin-Mocha-Greeter` (fenêtre arrondie, bordure mauve,
bouton mauve) et écrit `/etc/lightdm/lightdm-gtk-greeter.conf`. Il dit à la fin ce qu'il a
remplacé ; l'interface affiche ce qui est utilisé et les paquets qui complètent le rendu.

| Commande | Effet |
|---|---|
| `sudo ./greeter-catppuccin.sh` | Applique Catppuccin Mocha à l'écran de connexion |
| `sudo ./greeter-catppuccin.sh restore` | Remet la config d'origine du greeter |
| `dm-tool lock` | Verrouille la session pour voir le résultat |
| `RACINE=/tmp/essai ./greeter-catppuccin.sh` | Test sans root : écrit sous `/tmp/essai` au lieu de `/` (y mettre `etc/lightdm/lightdm-gtk-greeter.conf` avant) |

Retoucher le style : `/usr/share/themes/Catppuccin-Mocha-Greeter/gtk-3.0/gtk.css`
(sauvegarde de la config : `/etc/lightdm/lightdm-gtk-greeter.conf.avant-catppuccin`).

---

## Réglages avancés

| Commande | Effet |
|---|---|
| `ccsm` | Panneau de réglages de Compiz (effets, durées, raccourcis…) |
| `xfce4-panel -r` | Relance les panneaux (si le dock est mal placé, ou s'il ne réapparaît qu'en passant la souris en haut de l'écran) |
| `xfwm4 --replace &` | Relance le gestionnaire de fenêtres d'XFCE |
| `relancer-picom` | Relance picom puis le panneau (mode xfwm4) : à utiliser au lieu de relancer picom à la main, sinon le dock ne réapparaît plus qu'en haut de l'écran |
| `relancer-picom arreter` | Arrête picom, rend la main au compositeur d'xfwm4 et relance le panneau |
| `bureau-modeles` | Met en place les réglages de départ du dossier `config/` qui manquent (`picom.conf`, shader, style du Alt+Tab désactivé, `picom.desktop`, `compiz.desktop`) ; n'écrase jamais rien. Lancé aussi par `installer.sh`, à l'ouverture de l'interface et par `fond-anime` |

---

## Sauvegarde et retour en arrière (git)

Ce dossier est un dépôt git, publié sur https://github.com/YakusaFire/XfcePersonnaliser.
Les commandes se lancent depuis le dossier du projet.

| Commande | Effet |
|---|---|
| `git status` | Fichiers modifiés depuis la dernière version enregistrée |
| `git diff` | Détail des changements pas encore enregistrés |
| `git add -A && git commit -m "message"` | Enregistre une nouvelle version |
| `git push` | Envoie les versions enregistrées sur GitHub |
| `git log --oneline` | Liste des versions |
| `git restore <fichier>` | Annule les changements pas encore enregistrés d'un fichier |
| `git checkout <version> -- <fichier>` | Remet un fichier tel qu'il était dans une version |
| `git revert <version>` | Annule une version déjà enregistrée (en crée une qui fait l'inverse) |

> Les vidéos de `fonds-animes/` ne sont pas dans git. Les réglages (`picom.conf`, `gtk.css`,
> xfconf…) non plus : pour eux, la sauvegarde est un profil (`bureau-profil save <nom>`).

---

## Paquets installés (avec sudo)

```bash
sudo apt install picom
sudo apt install compiz compiz-plugins compiz-plugins-main compiz-gnome compizconfig-settings-manager
sudo apt install mpv   # fond animé
```

---

## Emplacements des fichiers

`~/.config`, `~/.cache` et `~/.local/share` valent `$XDG_CONFIG_HOME`, `$XDG_CACHE_HOME` et
`$XDG_DATA_HOME` quand ces variables sont définies (sur ce PC, elles pointent au même endroit).

| Élément | Chemin |
|---|---|
| Scripts | `bin/bureau-profil`, `bin/bureau-wm`, `bin/relancer-picom`, `bin/bureau-modeles` (ce dossier), liens dans `~/.local/bin/` |
| Fond animé (programmes) | `bin/fond-anime`, `bin/fond-anime-video`, `bin/fond-anime-fond`, `bin/fond-anime-icones` (ce dossier), liens dans `~/.local/bin/` ; `~/.local/bin/xwinwrap` |
| Fond animé (shader picom) | `config/picom/fond-anime.glsl` (ce dossier), copié dans `~/.config/picom/` |
| Fond animé (vrai fond gardé de côté) | `~/.config/fond-anime/fond-xfdesktop.json` (pendant la vidéo) |
| Sauvegarde d'avant le passage sous le bureau | `~/.config/fond-anime/sauvegarde-avant-vrai-bureau/` (`picom.conf`, fond de xfdesktop) |
| Installation des liens et du menu | `installer.sh` (ce dossier) |
| Fond animé (vidéo mémorisée, PID, réglage de pause) | `~/.config/fond-anime/video`, `pid`, `pause-auto` |
| Prise de commande de mpv (pause automatique) | `/run/user/<numéro>/fond-anime-mpv.sock` |
| Vidéos du fond animé | `fonds-animes/` (ce dossier) — les originaux sont restés dans `~/Videos/FOND_ECRAN/` ; `~/.local/share/bureau-reglages/fonds-animes/` si le dossier du logiciel n'est pas modifiable (installation dans `/usr`) |
| Miniatures et infos des vidéos (cache) | `~/.cache/bureau-reglages/` |
| Interface graphique | `bureau-reglages.py` (ce dossier), lien `~/.local/bin/bureau-reglages` — relancer `installer.sh` si le dossier est déplacé |
| Entrée du menu | `~/.local/share/applications/bureau-reglages.desktop` |
| Script de l'écran de connexion | `greeter-catppuccin.sh` (ce dossier) |
| Profils enregistrés | `~/.config/bureau-profils/` |
| Thèmes GTK / fenêtres | `~/.themes/` |
| Icônes et curseurs | `~/.local/share/icons/` |
| Polices (JetBrains Mono) | `~/.local/share/fonts/` |
| Fonds d'écran | `fonds/` (ce dossier, non versionné) : galerie de l'interface, « Ajouter des images… » y copie ; les originaux sont restés dans `~/Pictures/Wallpapers/`, où pointent encore les profils ; `~/.local/share/bureau-reglages/fonds/` si le dossier du logiciel n'est pas modifiable |
| Réglages de départ (modèles) | `config/picom/picom.conf`, `config/gtk-3.0/alttab.css`, `config/autostart/picom.desktop` et `compiz.desktop` (ce dossier), copiés par `bureau-modeles` |
| Config picom | `~/.config/picom/picom.conf` |
| Style du Alt+Tab | `~/.config/gtk-3.0/gtk.css` |
| Config Compiz | `~/.config/compiz/compizconfig/Default.ini` |
| Démarrage automatique | `~/.config/autostart/picom.desktop` (relance aussi le panneau 4 s après picom, sinon la zone de survol du dock reste en haut à gauche), `compiz.desktop`, `fond-anime.desktop`, `fond-anime-nettoyage.desktop` (seulement pendant le fond animé) |
| Sauvegarde de la config d'origine | `~/.config/xfce4-backup-20261104-084020/` |
