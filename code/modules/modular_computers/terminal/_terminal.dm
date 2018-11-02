/datum/computer_terminal
	var/terminal_id										//Not user facing.
	var/datum/computer_file/program/running_program
	var/datum/computer/holder

/datum/computer_terminal/New(datum/computer/_holder)
	terminal_id = SScomputers.next_terminal_id()
	holder = _holder

/datum/computer_terminal/Destroy()
	kill_running_program()
	return ..()

/datum/computer_terminal/proc/kill_running_program()
	if(running_program)
		running_program.terminal_killed(src)
	running_program = null

/datum/computer_terminal/proc/on_program_print(datum/computer_file/program/P, text)
	if(P != running_program)
		return FALSE
	return terminal_print(text)

/datum/computer_terminal/proc/terminal_print(text)
	//Blah blah UI code

/datum/computer_terminal/proc/terminal_input(text)
	if(running_program)
		running_program.on_terminal_input(text)
	else
		handle_terminal_execution(text)

/datum/computer_terminal/proc/handle_terminal_execution(text)

