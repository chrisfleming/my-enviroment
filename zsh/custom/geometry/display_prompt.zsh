# display_prompt.zsh

geometry_prompt_display_setup() {}

geometry_prompt_display_check() {
	export DISPLAY="`tmux show-env | sed -n 's/^DISPLAY=//p'`"
}

geometry_prompt_display_render() {
}

geometry_plugin_register display
