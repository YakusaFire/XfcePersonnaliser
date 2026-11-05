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
| Fond animé | Lancer / arrêter le fond animé, lancement à l'ouverture de session ; voir les vidéos de `fonds-animes/` avec un aperçu animé, en choisir une, en ajouter ou en retirer |
| Fenêtres et effets | xfwm4 + picom ou Compiz ; picom, animations, ombres, fondu, arrondi des coins, Alt+Tab stylisé |
| Écran de connexion | Mettre ou retirer le style Catppuccin (mot de passe demandé), aperçu en verrouillant |
| Outils | Relancer les panneaux, le gestionnaire de fenêtres ou picom ; ouvrir ce mémo |

> Les réglages de la page Apparence s'appliquent tout de suite, mais ne sont gardés
> dans un profil que si on l'enregistre.
> Picom désactivé : xfwm4 reprend son compositeur intégré et `bureau-profil load` ne le
> relance plus ; `bureau-wm xfwm4` le réactive.
> Alt+Tab stylisé désactivé : `gtk.css` est renommé en `gtk.css.desactive`.

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

```bash
bureau-wm compiz
bureau-wm xfwm4
```

---

## `fond-anime` — fond d'écran animé

Lit une vidéo en boucle, sans le son, à la place du fond d'écran : mpv joue la vidéo dans
une fenêtre de type « bureau » créée par xwinwrap, sous toutes les applications. Comme elle
cache les icônes de xfdesktop, `fond-anime-icones` les réaffiche par-dessus.
Aussi réglable depuis `bureau-reglages`, onglet **Fond animé** : un clic sur une vidéo
la montre dans l'aperçu, un double-clic la met en fond d'écran.

| Commande | Effet |
|---|---|
| `fond-anime VIDEO.mp4` | Lance cette vidéo en fond d'écran et la mémorise |
| `fond-anime` | Relance la dernière vidéo mémorisée (réaffiche aussi les icônes) |
| `fond-anime stop` | Arrête le fond animé : le fond d'écran normal réapparaît |
| `fond-anime auto on` | Lance le fond animé à chaque ouverture de session |
| `fond-anime auto off` | Ne le lance plus au démarrage |
| `fond-anime --help` | Affiche l'aide |
| `pgrep -af fond-anime-mpv` | Vérifie s'il tourne (aucune ligne = arrêté) |

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

Icônes par-dessus la vidéo : double-clic pour ouvrir ; clic droit sur le vide pour
« Ouvrir le dossier Bureau », « Ouvrir un terminal ici » ou « Actualiser ».

> Tant qu'il tourne, il recouvre le fond d'écran choisi dans un profil ou dans `bureau-reglages`.
> picom ne lui met ni ombre, ni coins arrondis, ni animation (règle `fond-anime-mpv` dans `picom.conf`).
> Dépendances : `mpv`, `xwinwrap` (`~/.local/bin/xwinwrap`) et `xrandr` ; `ffmpeg` / `ffprobe`
> pour les miniatures et les durées affichées dans l'onglet.

---

## `greeter-catppuccin.sh` — écran de connexion (LightDM)

L'écran de connexion tourne sous l'utilisateur `lightdm`, qui ne peut pas lire `~/.themes`
ni `~/.local/share/icons`. Le script copie thème, icônes, curseurs et fond d'écran dans
`/usr/share/…`, crée un thème dédié `Catppuccin-Mocha-Greeter` (fenêtre arrondie, bordure
mauve, bouton mauve) et écrit `/etc/lightdm/lightdm-gtk-greeter.conf`.

| Commande | Effet |
|---|---|
| `sudo ./greeter-catppuccin.sh` | Applique Catppuccin Mocha à l'écran de connexion |
| `sudo ./greeter-catppuccin.sh restore` | Remet la config d'origine du greeter |
| `dm-tool lock` | Verrouille la session pour voir le résultat |

Retoucher le style : `/usr/share/themes/Catppuccin-Mocha-Greeter/gtk-3.0/gtk.css`
(sauvegarde de la config : `/etc/lightdm/lightdm-gtk-greeter.conf.avant-catppuccin`).

---

## Réglages avancés

| Commande | Effet |
|---|---|
| `ccsm` | Panneau de réglages de Compiz (effets, durées, raccourcis…) |
| `xfce4-panel -r` | Relance les panneaux (si le dock est mal placé) |
| `xfwm4 --replace &` | Relance le gestionnaire de fenêtres d'XFCE |
| `picom &` | Relance picom (mode xfwm4 uniquement) |

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

| Élément | Chemin |
|---|---|
| Scripts | `bin/bureau-profil`, `bin/bureau-wm` (ce dossier), liens dans `~/.local/bin/` |
| Fond animé (programmes) | `bin/fond-anime`, `bin/fond-anime-icones` (ce dossier), liens dans `~/.local/bin/` ; `~/.local/bin/xwinwrap` |
| Installation des liens et du menu | `installer.sh` (ce dossier) |
| Fond animé (vidéo mémorisée, PID) | `~/.config/fond-anime/video`, `~/.config/fond-anime/pid` |
| Vidéos du fond animé | `fonds-animes/` (ce dossier) — les originaux sont restés dans `~/Videos/FOND_ECRAN/` |
| Miniatures et infos des vidéos (cache) | `~/.cache/bureau-reglages/` |
| Interface graphique | `bureau-reglages.py` (ce dossier), lien `~/.local/bin/bureau-reglages` — relancer `installer.sh` si le dossier est déplacé |
| Entrée du menu | `~/.local/share/applications/bureau-reglages.desktop` |
| Script de l'écran de connexion | `greeter-catppuccin.sh` (ce dossier) |
| Profils enregistrés | `~/.config/bureau-profils/` |
| Thèmes GTK / fenêtres | `~/.themes/` |
| Icônes et curseurs | `~/.local/share/icons/` |
| Polices (JetBrains Mono) | `~/.local/share/fonts/` |
| Fonds d'écran | `~/Pictures/Wallpapers/` |
| Config picom | `~/.config/picom/picom.conf` |
| Style du Alt+Tab | `~/.config/gtk-3.0/gtk.css` |
| Config Compiz | `~/.config/compiz/compizconfig/Default.ini` |
| Démarrage automatique | `~/.config/autostart/picom.desktop`, `compiz.desktop`, `fond-anime.desktop` |
| Sauvegarde de la config d'origine | `~/.config/xfce4-backup-20261104-084020/` |
