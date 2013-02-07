#!/usr/bin/env python
import os, sys

# Check for menu cache
menu_cache = '/tmp/obmenu-cache.xml'
if os.path.isfile(menu_cache):
    f = open(menu_cache, 'r')
    print f.read()
    f.close()
    sys.exit()

import glob, re
from xml.sax.saxutils import escape, quoteattr

# TODO add support desktop entries localization

HOME = os.environ['HOME']

dirs = ('/usr/share/applications',
        '/usr/local/share/applications',
        '/usr/kde/3.5/share/applications',
        os.path.join(HOME, '.gnome/apps'),
        os.path.join(HOME, '.kde/share/apps'),
        os.path.join(HOME, '.local/share/applications'),
        os.path.join(HOME, '.obmenu-override/applications'),)

icon_dirs = [os.path.join(HOME, '.obmenu-override/pixmaps'),
             '/usr/local/share/pixmaps',
             '/usr/share/pixmaps',
             ]
# Try scalable first, then grow in size starting from 16
for size in 'scalable', 16, 22, 24, 32, 36, 48, 64, 72, 96, 128, 192, 256:
    icon_dirs.append('/usr/local/share/icons/hicolor/%s/apps' % size)
    icon_dirs.append('/usr/share/icons/hicolor/%s/apps' % size)


reflags = re.IGNORECASE | re.MULTILINE
de_type = re.compile(r'^type=(.+)$', reflags)
de_categories = re.compile(r'^categories=(.+)$', reflags)
de_name = re.compile(r'^name=(.+)$', reflags)
de_exec = re.compile(r'^exec=(.+)$',  reflags)
de_icon = re.compile(r'^icon=(.+)$',  reflags)
exec_param = re.compile(r'\s*\%\w\s*') # used to remove command parameters
# If the entry has more than one category, we choose only one.
# priority is the same as the definition in this regexp.
# registered categories were taken from:
# http://standards.freedesktop.org/menu-spec/menu-spec-1.0.html#category-registry
de_category = re.compile(r'''
        \b(
        video           |
        audio           |
        development     |
        education       |
        game            |
        graphics        |
        network         |
        office          |
        settings        |
        system          |
        utility
        )\b''', reflags | re.VERBOSE)

# Use different labels depending on the category
category_labels = {
        'game': 'Games',
        'system': 'System Tools'
        }

def get_category(categories):
    e_category = de_category.search(categories)
    if not e_category:
        return
    e_category = e_category.group(1).lower()
    if e_category in category_labels:
        return category_labels[e_category]
    return e_category.capitalize()

# based on:
# http://standards.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html#icon_lookup
def get_icon(icon_name):
    for d in icon_dirs:
        if not os.path.isdir(d):
            continue
        icon_path = os.path.join(d, icon_name + '.png')
        if os.path.isfile(icon_path):
            return icon_path
        icon_path = os.path.join(d, icon_name + '.svg')
        if os.path.isfile(icon_path):
            return icon_path
        icon_path = os.path.join(d, icon_name + '.xpm')
        if os.path.isfile(icon_path):
            return icon_path


menu = {}

# first create the menu graph. desktop entries in the user home will override
# system entries
for d in dirs:
    if not os.path.isdir(d):
        continue
    desktop_entries = glob.iglob(os.path.join(d, '*.desktop'))
    for path in desktop_entries:
        f = open(path, 'r')
        entry = f.read()
        f.close()
        entry_type = de_type.search(entry)
        entry_categories = de_categories.search(entry)
        entry_name = de_name.search(entry)
        entry_exec = de_exec.search(entry)
        entry_icon = de_icon.search(entry)
        if not (entry_type and entry_categories and entry_name and entry_exec):
            continue
        if entry_type.group(1).lower() != 'application':
            continue
        e_category = get_category(entry_categories.group(1))
        if not e_category:
            continue
        e_name = entry_name.group(1)
        e_exec = exec_param.sub('', entry_exec.group(1))
        e_icon = None
        if entry_icon:
            e_icon = get_icon(entry_icon.group(1))
        if e_category not in menu:
            menu[e_category] = {}
        menu[e_category][e_name] = (e_exec, e_icon,)


openbox_config_dir = os.path.join(HOME, '.config/openbox')
before_menu_file = os.path.join(openbox_config_dir, 'before-menu.xml')
after_menu_file = os.path.join(openbox_config_dir, 'after-menu.xml')
# output the menu
sysout = sys.stdout
sys.stdout = open(menu_cache, 'w')
print '<openbox_pipe_menu>\n'
if os.path.isfile(before_menu_file):
    f = open(before_menu_file)
    print f.read()
    f.close()
for k, v in menu.items():
    print '<menu id=%s label=%s>' % (quoteattr(k), quoteattr(k),)
    for k, v in v.items():
        if v[1]:
            print '  <item label=%s icon=%s>\n' % (quoteattr(k),
                    quoteattr(v[1]),)
        else:
            print '  <item label=%s>\n' % quoteattr(k)
        print ('    <action name="Execute">\n'
               '      <execute>%s</execute>\n'
               '    </action>\n'
               '  </item>') % escape(v[0])
    print '</menu>\n'
if os.path.isfile(after_menu_file):
    f = open(after_menu_file)
    print f.read()
    f.close()
print '\n</openbox_pipe_menu>'
sys.stdout.close()
sys.stdout = sysout
f = open(menu_cache, 'r')
print f.read()
f.close()
