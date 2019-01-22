/datum/component/computer
	var/datum/computer_file/program/active_program				//Onscreen program. Possibly multi window later but for now whatever.
	var/list/datum/computer_file/program/running_programs		//Lazylist of running programs

/datum/component/computer/New()
	SScomputers.add_computer(src)

/datum/component/computer/Destroy()
	SScomputers.remove_computer(src)
	return ..()

/datum/component/computer/process()
	for(var/i in running_programs)
		var/datum/computer_file/program/P = i
		P.process()

/datum/component/computer/proc/get_location()
	return null

/datum/component/computer/proc/use_power(units)
	return TRUE

/datum/component/computer/proc/power_remaining()
	return INFINITY

/datum/component/computer/proc/power_percentage()
	return 1

/datum/component/computer/proc/can_launch_program(datum/computer_file/program/P, force = FALSE)

/datum/component/computer/proc/launch_program(datum/computer_file/program/P, force = FALSE)
	if(
