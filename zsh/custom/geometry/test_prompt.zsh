# Color definitions
GEOMETRY_COLOR_TEST=${GEOMETRY_COLOR_JOBS:-blue}

# Symbol definitions
GEOMETRY_SYMBOL_TEST=${GEOMETRY_SYMBOL_TEST:-"test"}

geometry_prompt_test_setup() {}

geometry_prompt_test_check() {
  [[ $(print -P '%j') == "0" ]]
}

geometry_prompt_test_render() {
  local test_prompt='%(1j.'$GEOMETRY_SYMBOL_TEST' %j.)'
   echo $(prompt_geometry_colorize $GEOMETRY_COLOR_TEST $test_prompt)
}

geometry_plugin_register test

