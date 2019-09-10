#!/usr/bin/env bash

set -o nounset    # error when referencing undefined variable
set -o errexit    # exit when command fails

mkdir -p ~/.vim/pack/coc/start
cd ~/.vim/pack/coc/start
curl --fail -L https://github.com/neoclide/coc.nvim/archive/release.tar.gz|tar xzfv -

mkdir -p ~/.config/coc/extensions
cd ~/.config/coc/extensions
if [ ! -f package.json ]
then
	echo '{"dependencies":{}}' > package.json
fi


npm install coc-calc --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-css --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-docker --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-git --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-html --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-json --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-pairs --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-python --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-sh --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-snippets --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-solargraph --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
npm install coc-yaml --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod

