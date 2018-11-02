/datum/computer
	var/datum/computer_file/program/active_program				//Onscreen program. Possibly multi window later but for now whatever.
	var/list/datum/computer_file/program/running_programs		//Lazylist of running programs

	var/atom/physical											//Physical holder, if it exists.
	var/physical_bind_state = MODULAR_COMPUTER_INDEPENDENT

/datum/computer/New()
	SScomputers.add_computer(src)

/datum/computer/Destroy()
	SScomputers.remove_computer(src)
	return ..()

/datum/computer/process()
	for(var/i in running_programs)
		var/datum/computer_file/program/P = i
		P.process()

/datum/computer/proc/bind_to_atom(atom/A)
	if(physical || physical_bind_state)
		return FALSE
	if(!A.modular_computers_can_bind(src))
		return FALSE
	physical = A
	physical_bind_state = A.modular_computers_implementation_level()
	A.on_modular_computers_bind(src)
	return TRUE

/datum/computer/proc/unbind_from_atom(atom/A)
	if(!physical)
		return FALSE
	A.on_modular_computers_unbind(src)
	physical = null
	return TRUE
