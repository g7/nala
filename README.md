Nala?
=====

Nala is a Python-written file/directory watched designed for Semplice's
dynamic menu, alan.

Yeah, we all know the small RAM footprint of Python...
------------------------------------------------------

Remember, RAM is cheaper than good programmers :-)
The final goal is to port nala to other compiled GLib-friendly programming
languages, such as vala or genie.
With gobject-introspection it may be possible to use the rewritten
library in python scripts too.

Also, nala's current RAM usage is not too high: ~11 MB.
(using a inotify library such as python-inotifyx really lowers the
RAM usage, but Gio and GObjects are awesome, sorry :-D)

Is nala alan-specific?
----------------------

No, it isn't. Feel free to use this not-so-well written code elsewhere.
