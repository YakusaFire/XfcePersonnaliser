import sys, gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
erreurs = []
p = Gtk.CssProvider()
p.connect("parsing-error", lambda _p, s, err: erreurs.append(err.message))
p.load_from_path(sys.argv[1])
print(f"CSS du greeter : {len(p.to_string())} caractères chargés, erreurs : {erreurs or 'aucune'}")
