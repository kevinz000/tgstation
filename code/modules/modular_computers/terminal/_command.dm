/datum/computer_file/program/terminal_command
	computer_program_flags = COMPUTER_PROGRAM_SYSTEM_INTERNAL | COMPUTER_PROGRAM_HIDDEN_GUI

/datum/computer_file/program/terminal_command/supports_gui_execution()
	return FALSE

/datum/computer_file/program/terminal_command/supports_terminal_execution()
	return TRUE
