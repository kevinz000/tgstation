/datum/component/computer/physical
	var/atom/physical											//Physical holder, if it exists.
	var/physical_bind_state = MODULAR_COMPUTER_INDEPENDENT

/datum/component/computer/proc/bind_to_atom(atom/A)
	if(physical || physical_bind_state)
		return FALSE
	if(!A.modular_computers_can_bind(src))
		return FALSE
	physical = A
	physical_bind_state = A.modular_computers_implementation_level()
	A.on_modular_computers_bind(src)
	return TRUE

/datum/component/computer/proc/unbind_from_atom(atom/A)
	if(!physical)
		return FALSE
	A.on_modular_computers_unbind(src)
	physical = null
	return TRUE

