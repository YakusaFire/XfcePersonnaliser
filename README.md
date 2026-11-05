# XfcePersonnaliser

Personnalisation du bureau XFCE (Debian 13, XFCE 4.20) : profils d'apparence complets,
effets de fenêtres avec picom ou Compiz, écran de connexion Catppuccin, fond d'écran animé,
et une interface graphique qui regroupe le tout.

## Contenu

| Élément | Rôle |
|---|---|
| `bureau-reglages.py` | Interface graphique « Personnalisation du bureau » (GTK 3) |
| `bin/bureau-profil` | Enregistre ou applique un profil d'apparence complet |
| `bin/bureau-wm` | Choix du gestionnaire de fenêtres : xfwm4 + picom ou Compiz |
| `bin/fond-anime` | Fond d'écran animé à partir d'une vidéo (mpv + xwinwrap) |
| `bin/fond-anime-icones` | Icônes du bureau affichées par-dessus le fond animé |
| `greeter-catppuccin.sh` | Style Catppuccin Mocha pour l'écran de connexion LightDM |
| `installer.sh` | Installe les commandes dans `~/.local/bin` et l'entrée du menu |
| `fonds-animes/` | Vidéos proposées pour le fond animé (non versionnées) |
| `commandes-bureau.md` | Mémo de toutes les commandes et des fichiers utilisés |

## Installation

```bash
./installer.sh
```

Les commandes de `~/.local/bin` sont des liens vers ce dossier : relancer `installer.sh`
s'il est déplacé.

## Dépendances

- XFCE 4.20 (xfwm4, xfdesktop, xfce4-panel), LightDM avec lightdm-gtk-greeter
- Python 3 avec PyGObject (GTK 3) et pycairo
- picom 12 ou plus récent ; Compiz en option (effet Génie)
- mpv, ffmpeg / ffprobe, xrandr, et `xwinwrap` dans `~/.local/bin` (non fourni)
- Thèmes non fournis : Catppuccin GTK (Mocha, accent mauve), Papirus, curseurs Catppuccin, WhiteSur

## Utilisation

Menu **Paramètres → Personnalisation du bureau**, ou la commande `bureau-reglages`.
Toutes les commandes sont décrites dans [commandes-bureau.md](commandes-bureau.md).
