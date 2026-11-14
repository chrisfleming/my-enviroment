#!/bin/bash
# 
# Bootstrap a new system
# wget -O - https://raw.githubusercontent.com/chrisfleming/my-enviroment/master/bin/bootstrap.sh  | bash
#
set -e

if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] && [ "ssh-add -l > /dev/null" ]; then
    SSH_CONFIG=${HOME}/.ssh
    mkdir -p ${SSH_CONFIG}
    # You kinda have to take it on trust that these are the github finger-prints
    cat > ${SSH_CONFIG}/known_hosts <<EOF
|1|clnLL0mD6yeybmELLpJW0Z3hSUU=|GYO6eB1F0D+HVTeLlP7edbabPiA= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
|1|Ckc80vuVSIfn10uM74pb4jfDBS8=|lSc7LGFPlKVXCpmJF7EcHTVUlsg= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF
    MYGITHUB=git@github.com:chrisfleming
else
    MYGITHUB=https://github.com/chrisfleming
fi

# Make sure we have git. Needs root (or sudo) only if git is missing.
if command -v git >/dev/null 2>&1; then
    echo "Already have git, good"
else
    SUDO=""
    if [ "$(id -u)" != 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            SUDO=sudo
        else
            echo "git is missing and there is no root/sudo - install git and re-run" >&2
            exit 1
        fi
    fi
    echo "Fetching git"
    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update
        $SUDO apt-get install -y git
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y git
    elif command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -S --noconfirm --needed git
    else
        echo "Don't know how to install git on this system" >&2
        exit 1
    fi
fi

# keep my stff here
MYSRC=${HOME}/projects
mkdir -p ${MYSRC}
cd ${MYSRC}

# Clone dotfiles and elisp
if [ ! -d my-enviroment ]; then
    echo "Fetching dotfiles"
    git clone ${MYGITHUB}/my-enviroment.git my-enviroment
    cd my-enviroment
    ./bin/setup_links.sh
    cd -
fi

cd $HOME

# Done (for now)
echo "Done!"




