
/obj/machinery/power/PSU
	name = "power supply unit"
	desc = "A cheap power supply unit that powers machinery installed on it without the need of wireless power from an Area Power Controller."
	icon_state = "term"
	var/list/obj/machinery/linked_machinery = list()
	var/max_linked = 5
	var/link_with_beam = TRUE
	var/connection_range = 2
	var/efficiency = 0.5	//Better off using wireless!

/obj/machinery/power/PSU/update_icon()
	if(link_with_beam)
		//WIP: LINKING CABLE "BEAM"
	..()

/obj/machinery/power/PSU/can_connect(obj/machinery/M)
	if(M in linked_machinery)
		return FALSE
	if(get_dist(get_turf(M), get_turf(src)) > connection_range)
		return FALSE
	if(M.direct_power)
		return FALSE
	return TRUE

/obj/machinery/power/PSU/proc/relay_power(obj/machinery/M, amount)


/obj/machinery/power/PSU/mouseDropT()

/obj/machinery/power/PSU/attackby()

