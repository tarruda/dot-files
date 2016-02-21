#!/usr/bin/env python

import os.path
import subprocess

cmd = 'beet ls | cut -f1 -d- | uniq | sort --random-sort | head -n 5'
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
artists = ["'artist:{0}'".format(a.strip()) for a in p.stdout]
p.wait()
cmd = "beet config -d | grep '^directory'"
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
d, _ = p.communicate()
_, d = d.split(':')
music_dir = os.path.expanduser(d.strip())
query = 'beet ls -p {0} | sort --random-sort | head -n 100'.format(', '.join(artists))
p = subprocess.Popen(query, stdout=subprocess.PIPE, shell=True)
for s in p.stdout:
    print(os.path.relpath(s.strip(), music_dir))

