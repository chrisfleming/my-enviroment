# clearcase_prompy.zsh

geometry_prompt_RPS1_setup() {
typeset -g ZSH_VI_MODE="main"
function zle-keymap-select {
  RPROMPT=${${RPROMPT/\[vicmd\] /}/\[main\] /}
  RPROMPT="[$KEYMAP] $RPROMPT"
  zle reset-prompt
}
zle -N zle-keymap-select

}

geometry_prompt_RPS1_check() {
#	[ -f $RPS1 ] || return 0
    return 1
}

geometry_prompt_RPS1_render() {
	echo $RPS1
}

geometry_plugin_register RPS1
