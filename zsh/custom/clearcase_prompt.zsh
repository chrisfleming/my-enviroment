# clearcase_prompy.zsh

geometry_prompt_clearcase_setup() {}

geometry_prompt_clearcase_check() {
	return 0
    # [[ -n $CLEARCASE_ROOT ]] || return 1
}

geometry_prompt_clearcase_render() {
	echo "ROOT"
	# echo $(basename $CLEARCASE_ROOT)
}

geometry_plugin_register clearcase
