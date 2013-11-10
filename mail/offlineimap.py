import os, subprocess

def decrypt_password(account):
    fpath = '%s/.mail-accounts/%s/password.gpg' % \
            (os.environ['HOME'], account,)
    args = ["gpg", "--quiet", "--batch", "--decrypt", fpath]
    try:
        return subprocess.check_output(args).strip()
    except subprocess.CalledProcessError:
        return ""
