#!/usr/bin/python
# Based on the fedora openbox xdg pipemenu script. Tested on ubuntu 12.04
#
# Needs the following apt dependencies:
#   - python-xdg
#   - python-gi
#   - python-pythonmagick
#   - gnome-menus

# To override or add custom .desktop files, just set XDG_DATA_HOME to a
# custom directory that contains an 'applications' subdirectory containing
# custom entries. eg:
#
#   $ export XDG_DATA_HOME=$HOME/.xdg
#   $ mkdir $XDG_DATA_HOME/applications # <- add custom .desktop files here
#
# If some icons are not being shown, try installing *-icon-theme packages:
#   $ sudo apt-get install gnome-icon-theme-full
# Or better yet, install faenza icon theme:
#
#   $ sudo apt-add-repository ppa:tiheum/equinox
#   $ sudo apt-get update
#   $ sudo apt-get install faenza-icon-theme
#
# The best way to run this script is automatically whenever the system is
# updated. Add the following to /etc/apt/apt.conf.d/00update-windows-shortcuts
#
# DPkg::Post-Invoke {"sudo -E -u [USER] [PATH TO THIS FILE]";};  
#


import re, sys, os, socket, struct
import xdg.Menu, xdg.DesktopEntry, xdg.Config
import gtk
from PythonMagick import Image, Blob, Geometry, Color

            

def icon_attr(entry):
    name = entry.getIcon()

    if os.path.exists(name):
        return name

    # work around broken .desktop files
    # unless the icon is a full path it should not have an extension
    name = re.sub('\..{3,4}$', '', name)

    # imlib2 cannot load svg
    
    iconinfo = theme.lookup_icon(name, 128, gtk.ICON_LOOKUP_GENERIC_FALLBACK)
    if iconinfo:
        iconfile = iconinfo.get_filename()
        if hasattr(iconinfo, 'free'):
            iconinfo.free()
        if iconfile:
            return iconfile
    return ''

def walk_menu(entry):
    if isinstance(entry, xdg.Menu.Menu) and entry.Show is True:
        map(walk_menu, entry.getEntries())
    elif isinstance(entry, xdg.Menu.MenuEntry) and entry.Show is True:
        # byte 1 signals another entry
        conn.sendall('\x01')
        img_path = icon_attr(entry.DesktopEntry).encode('utf-8')
        if img_path:
            # Create an empty image and set the background color to
            # transparent. This is important to have transparent background
            # when converting from SVG
            img = Image()
            img.backgroundColor(Color(0, 0, 0, 0xffff))
            img.read(img_path)
            # scale the image to 48x48 pixels
            img.scale(Geometry(48, 48))
            # ensure the image is converted to ICO
            img.magick('ICO')
            b = Blob()
            img.write(b)
            # icon length plus data
            conn.sendall(struct.pack('i', len(b.data)))
            conn.sendall(b.data)
        else:
            conn.sendall(struct.pack('i', 0))

        name = entry.DesktopEntry.getName()
        # name length plus data
        conn.sendall(struct.pack('i', len(name)))
        conn.sendall(name)

        command = re.sub(' -caption "%c"| -caption %c',
                ' -caption "%s"' % name, entry.DesktopEntry.getExec())
        command = re.sub(' [^ ]*%[fFuUdDnNickvm]', '', command)
        if entry.DesktopEntry.getTerminal():
                command = 'xterm -title "%s" -e %s' % (name, command)

        # command length plus data
        conn.sendall(struct.pack('i', len(command)))
        conn.sendall(command)


# open connection to the server
HOST = '192.168.56.1'
PORT = 55556
conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
conn.connect((HOST, PORT))

lang = os.environ.get('LANG')
if lang:
    xdg.Config.setLocale(lang)

# lie to get the same menu as in GNOME
xdg.Config.setWindowManager('GNOME')

theme = gtk.icon_theme_get_default()

# theme = Gtk.IconTheme.get_default()

menu = xdg.Menu.parse('applications.menu')

map(walk_menu, menu.getEntries())

# byte 0 signals end of all entries
conn.sendall('\x00')
conn.close()
