# clearcase_prompt.zsh

clearcase_prompt() {
	[ -f $CLEARCASE_ROOT ] || return 0
	echo $(basename $CLEARCASE_ROOT)
}
