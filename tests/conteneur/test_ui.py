import importlib.util, os, sys
from importlib.machinery import SourceFileLoader
chargeur = SourceFileLoader("br", "/usr/bin/bureau-reglages")
spec = importlib.util.spec_from_loader("br", chargeur)
br = importlib.util.module_from_spec(spec); chargeur.exec_module(br)
from gi.repository import Gtk
app = Gtk.Application(application_id="fr.bureau.ReglagesEssai"); app.register(None)
seulement_connexion = len(sys.argv) > 1
if not seulement_connexion:
    print("ICI :", br.ICI, "| modifiable :", os.access(br.ICI, os.W_OK))
    print("FONDS :", br.FONDS, "| VIDEOS :", br.VIDEOS_FOND)
    print("bandeau :", br.probleme_session())
f = br.Fenetre(app)
if not seulement_connexion:
    print("statut :", f.texte_statut.get_text())
    print("programmes absents :", ", ".join(c for c, ok in f.etat.programmes.items() if not ok))
    for nom, w in (("Fond animé", f.ligne_anime), ("Picom", f.ligne_picom), ("Verrouiller", f.ligne_verrou)):
        print(f"{nom} : {'actif' if w.is_sensitive() else 'grisé'} | {w.desc.get_text()}")
    print("Compiz :", "actif" if f.radio_compiz.is_sensitive() else "grisé", "|", f.radio_compiz.desc.get_text())
    print("thèmes GTK :", br.themes("gtk-3.0/gtk.css"), "| icônes :", br.themes_icones()[0][:6])
print(f"Connexion : {'actif' if f.ligne_greeter.is_sensitive() else 'grisé'} | {f.ligne_greeter.desc.get_text()}")
f.destroy()
