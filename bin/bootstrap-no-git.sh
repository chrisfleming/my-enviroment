#!/bin/bash
# 
# Bootstrap a new system
# curl https://raw.githubusercontent.com/chrisfleming/my-enviroment/master/bin/bootstrap-no-git.sh  | bash
#
set -e

# NON GIT SETUP FOR LABSYSTEMS...

URL="https://github.com/chrisfleming/my-enviroment/archive/master.tar.gz"

# keep my stuff here
MYSRC=${HOME}/projects
mkdir -p ${MYSRC}
cd ${MYSRC}


# Clone dotfiles 
if [ ! -d my-enviroment ]; then
    echo "Fetching dotfiles"
    curl --remote-name --insecure -L $URL 
    tar -xvzf master.tar.gz
    ln -s my-enviroment-master/ my-enviroment
    cd my-enviroment
    #./bin/setup_links.sh
    cd -
fi

cd $HOME

# Done (for now)
echo "Done. No linking done for now!"




