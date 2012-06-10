windowstate
===========

Windowstate is a utility for saving and restoring the sizes and positions of
application windows on Microsoft Windows systems.

Why?
----

Windows 7 (and probably Vista) have a tendancy to mess up window positions and
sizes in certain circumstances, such as when disconnecting and reconnecting
the primary display. The usual symptom is that once the display is reconnected
all of the application windows have been shrunk and repositioned to the top-left
corner of the screen. This can be particularly irritating if you have a large
number of carefully sized and positioned windows open. So far as I can tell
there is no universal solution to this problem, so I wrote this program as a
workaround.

Installation
------------

If you have a RubyInstaller for Windows installation, then you can install
the gem from a command prompt in the usual way:

```
gem install windowstate
```

Alternatively, you can download the standalone executable from github on

https://github.com/downloads/LichP/windowstate/windowstate.exe

Usage
-----

Windowstate is a command line application, so you will need to run it from the
command prompt. To save the current window states:

```
windowstate save
```

It is recommended you do this immediately before causing a display disconnect.
Once your display is reconnected, to restore the previously saved window
state:

```
windowstate restore
```

The saved state is stored as JSON in a file called `windowstate.json`, which is
save in your user local temp directory by default. You can override this with
the `--file` option - see `windowstate --help` for details.

Does it Work?
-------------

Windowstate has not been extensively tested: it works on my system with my
typical window set, but it might not catch some legitimate application
windows, and has not been tested in a multi-display environment. If you
run in to problems, please let me know and/or open an issue on Github.

Contact and Contributing
------------------------

The homepage for this project is

http://github.com/LichP/windowstate

Any feedback, suggestions, etc are very welcome. If you have bugfixes and/or
contributions, feel free to fork, branch, and send a pull request.

Enjoy :-)

Phil Stewart, June 2012
