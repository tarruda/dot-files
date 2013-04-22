#!/usr/bin/env python
import os, subprocess

def get_password(account):
    cmd = ['gpg', '--batch', '-q', '--decrypt', '%s/.mail-passwords/%s.gpg'\
            % (os.environ.get('HOME'), account,)]
    # remove trailing newlines and return
    return subprocess.check_output(cmd).strip() 
