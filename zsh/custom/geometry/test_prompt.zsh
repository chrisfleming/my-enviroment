# Color definitions
GEOMETRY_COLOR_TEST=${GEOMETRY_COLOR_JOBS:-blue}

# Symbol definitions
GEOMETRY_SYMBOL_TEST=${GEOMETRY_SYMBOL_TEST:-"t"}

geometry_prompt_test_setup() {
typeset -g ZSH_VI_MODE="main"
function zle-keymap-select {
  RPROMPT=${${RPROMPT/\[vicmd\] /}/\[main\] /}
  RPROMPT="[$KEYMAP] $RPROMPT"
  zle reset-prompt
}
zle -N zle-keymap-select
}

geometry_prompt_test_check() {
#  [[ $(print -P '%j') == "0" ]]
}

geometry_prompt_test_render() {
  #local test_prompt='%(1j.'$GEOMETRY_SYMBOL_TEST' %j.)'
  local test_prompt="${${KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"

  echo $(prompt_geometry_colorize $GEOMETRY_COLOR_TEST $test_prompt)
}

geometry_plugin_register test

