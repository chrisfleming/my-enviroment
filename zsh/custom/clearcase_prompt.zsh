# clearcase_prompy.zsh

geometry_prompt_clearcase_setup() {}

geometry_prompt_clearcase_check() {
	[ -f $CLEARCASE_ROOT ] || return 1
}

geometry_prompt_clearcase_render() {
	echo $(basename $CLEARCASE_ROOT)
}

geometry_plugin_register clearcase
