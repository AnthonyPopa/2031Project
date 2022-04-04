set_global_assignment -entity "PLL_main" -library "lib_PLL_main" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL_main" -library "lib_PLL_main" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "PLL_main" -library "lib_PLL_main" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL_main" -name SPD_FILE [file join $::quartus(sip_path) "PLL_main.spd"]

set_global_assignment -library "lib_PLL_main" -name MISC_FILE [file join $::quartus(sip_path) "PLL_main_sim/PLL_main.vho"]
