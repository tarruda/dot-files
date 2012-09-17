export PYTHON_VIRTUALENV="$HOME/.python-virtualenv"

function activate_pyenv {
	local envdir="$1"
        local bundledenvdir="$PWD/.python-virtualenv"
        if [ -z "$envdir" ]; then
                if [ -d "$bundledenvdir" ]; then
                    envdir="$bundledenvdir"
                else
                    envdir="$PYTHON_VIRTUALENV"
                fi
        fi
	local file="$envdir/bin/activate"
	if [ -r "$file" ]; then
		source "$file"
	else
		echo "Python virtualenv not properly set in '$envdir'"
		return 1
	fi
}

function create_pyenv {
	local envdir="$1"
	if [ -z "$envdir" ]; then
                envdir="$PYTHON_VIRTUALENV"
	fi
        if [ "$envdir" = "." ]; then
                envdir="$PWD/.python-virtualenv"
        fi
	if [ -d "$envdir" ]; then
		echo "Remove the directory '$envdir' first"
		return 1
	fi
	virtualenv --no-site-packages "$envdir"
}

# Prints python installed packages in a format
# that is usable in the following way:
# 'lpyenv_packages | xargs easy_install'
function lpyenv_packages {
python << "EOF"
import pkg_resources
distros = pkg_resources.AvailableDistributions()
for key in distros:
    for dist in distros[key]:
        print '%s==%s' % (dist.key, dist.version)
EOF
}
