//Modular computers, NTNet, and integrated circuits when that is later ported to this.

PROCESSING_SUBSYSTEM_DEF(electronics)
	name = "Electronics"
	wait = 2
	stat_tag = "EXE"
	var/datum/exonet/exonet_network			//Primary network!

/datum/subsystem/electronics/Initialize()
	exonet_network = new
	return ..()
