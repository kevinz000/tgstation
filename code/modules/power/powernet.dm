////////////////////////////////////////////
// POWERNET DATUM
// each contiguous network of cables & nodes
/////////////////////////////////////
/datum/powernet
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all connected machines

	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewavail = 0			// the available power as it appears on the power console (gradually updated)
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/netexcess = 0			// excess power on the powernet (typically avail-load)///////

/datum/powernet/New(obj/structure/cable/C, autoprop = TRUE)
	SSmachines.powernets += src
	if(istype(C))
		cables += C
		if(autoprop)
			automatic_propagation(C)

/datum/powernet/Destroy()
	nullify_network()
	SSmachines.powernets -= src
	return ..()

/datum/powernet/proc/merge_network(datum/powernet/PN)
	if(!istype(PN))
		return
	for(var/i in PN.nodes)
		var/obj/machinery/power/M = PN.nodes[i]
		if(istype(M))
			M.powernet = src
	for(var/i in PN.cables)
		var/obj/structure/cable/C = PN.cables[i]
		if(istype(C))
			C.powernet = src
	nodes |= PN.nodes
	cables |= PN.cables
	PN.nodes.Cut()
	PN.cables.Cut()
	qdel(PN)

/datum/powernet/proc/nullify_network(delete_self = FALSE)
	for(var/i in nodes)
		var/obj/machinery/power/M = nodes[i]
		if(istype(M) && M.powernet == src)
			M.powernet = null
	for(var/i in cables)
		var/obj/structure/cable/C = cables[i]
		if(istype(C) && C.powernet == src)
			C.powernet = null
	nodes.Cut()
	cables.Cut()
	if(delete_self)
		qdel(src)

/datum/powernet/proc/automatic_propagation(obj/structure/cable/C)
	if(!istype(C))
		return
	nullify_network()
	var/list/obj/structure/cable/possible_expansions = list(C)
	do
		var/list/c = C.powernet_expansion()
		var/list/m = C.machinery_expansion()

/datum/powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	if(istype(C) && C.powernet == src)
		C.powernet = null
	null_check()

//add a cable to the current powernet
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)// if C already has a powernet...
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C) //..remove it
	C.powernet = src
	cables +=C

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -=M
	M.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it


//add a power machine to the current powernet
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()//..remove it
	M.powernet = src
	nodes[M] = M

//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset()
	//see if there's a surplus of power remaining in the powernet and stores unused power in the SMES
	netexcess = avail - load

	if(netexcess > 100 && nodes && nodes.len)		// if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
			S.restore()				// and restore some of the power that was used

	// update power consoles
	viewavail = round(0.8 * viewavail + 0.2 * avail)
	viewload = round(0.8 * viewload + 0.2 * load)

	// reset the powernet
	load = 0
	avail = newavail
	newavail = 0

/datum/powernet/proc/get_electrocute_damage()
	if(avail >= 1000)
		return CLAMP(round(avail/10000), 10, 90) + rand(-5,5)
	else
		return 0