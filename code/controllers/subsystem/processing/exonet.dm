PROCESSING_SUBSYSTEM_DEF(exonet)
	name = "Exonet"
	stat_tag = "ENT"
	init_order = INIT_ORDER_CIRCUIT
	flags = NONE
	var/datum/exonet/station_network

/datum/controller/subsystem/processing/exonet/Initialize()
	station_network = new
	for(var/obj/machinery/exonet_relay/R in GLOB.machines)
		station_network.relays[R.id] = R
		R.network = station_network
	return ..()
