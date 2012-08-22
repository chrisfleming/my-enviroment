#!/bin/bash

mkdir -p ~/.todo.actions.d/

cd ~/.todo.actions.d/

# Simple Edit Plugin
curl https://raw.github.com/mbrubeck/todo.txt-cli/master/todo.actions.d/edit > edit
chmod a+x edit

# Birdseye
curl https://raw.github.com/ginatrapani/todo.txt-cli/addons/.todo.actions.d/birdseye > birdseye
curl https://raw.github.com/ginatrapani/todo.txt-cli/addons/.todo.actions.d/birdseye.py > birdseye.py
chmod a+x birdseye

# Review
curl https://raw.github.com/emilerl/emilerl/master/todo.actions.d/review > review
curl https://raw.github.com/chrisfleming/emilerl/master/todo.actions.d/review.py > review.py
curl https://raw.github.com/emilerl/emilerl/master/todo.actions.d/todotxt.py > todotxt.py
curl https://raw.github.com/emilerl/emilerl/master/scripts/imapls.py > imapls.py
curl https://raw.github.com/chrisfleming/emilerl/master/todo.actions.d/mdown.py > mdown.py
chmod a+x review


