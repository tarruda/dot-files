#!/usr/bin/python
# Based on the fedora openbox xdg pipemenu script.
#
# Tested on ubuntu 12.04 and needs the following apt dependencies:
#   - python-xdg
#   - python-gi
#   - python-pythonmagick
#   - gnome-menus


import xdg.Menu, xdg.DesktopEntry, xdg.Config
import re, sys, os
from xml.sax.saxutils import escape
from gi.repository import Gtk
from PythonMagick import Image, Blob

def icon_attr(entry):
    name = entry.getIcon()

    if os.path.exists(name):
        return name

    # work around broken .desktop files
    # unless the icon is a full path it should not have an extension
    name = re.sub('\..{3,4}$', '', name)

    # imlib2 cannot load svg
    iconinfo = theme.lookup_icon(name, 22, Gtk.IconLookupFlags.NO_SVG)
    if iconinfo:
        iconfile = iconinfo.get_filename()
        if hasattr(iconinfo, 'free'):
            iconinfo.free()
        if iconfile:
            return iconfile
    return ''

def escape_utf8(s):
    if isinstance(s, unicode):
        s = s.encode('utf-8', 'xmlcharrefreplace')
    return escape(s)

def entry_name(entry):
    return escape_utf8(entry.getName())

def walk_menu(entry):
    if isinstance(entry, xdg.Menu.Menu) and entry.Show is True:
        map(walk_menu, entry.getEntries())
    elif isinstance(entry, xdg.Menu.MenuEntry) and entry.Show is True:
        name = entry_name(entry.DesktopEntry)
        command = re.sub(' -caption "%c"| -caption %c',
                ' -caption "%s"' % name,
                escape_utf8(entry.DesktopEntry.getExec()))
        command = re.sub(' [^ ]*%[fFuUdDnNickvm]', '', command)
        if entry.DesktopEntry.getTerminal():
                command = 'xterm -title "%s" -e %s' % (name, command)
        img_path = escape_utf8(icon_attr(entry.DesktopEntry))
        if img_path:
            img = Image(img_path)
            b = Blob()
            img.write(b)
            print '%s %s' % (b.length(), img.fileName(),)
            if img.magick() != 'ICO':
                # convert to ICO
                img.magick('ICO')
            img.write(b)
            print '%s %s' % (b.length(), img.fileName(),)
            # print 'name: %s, icon: %s, command: %s' % (name.replace('"', ''),
            #         img_path, command)


lang = os.environ.get('LANG')
if lang:
    xdg.Config.setLocale(lang)

# lie to get the same menu as in GNOME
xdg.Config.setWindowManager('GNOME')

theme = Gtk.IconTheme.get_default()

menu = xdg.Menu.parse('applications.menu')

map(walk_menu, menu.getEntries())
