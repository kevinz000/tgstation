
GLOBAL_LIST_EMPTY(networks)							//All unique networks in the game.
GLOBAL_DATUM_INIT(NETWORK_DEFAULT, NETWORK_PATH_DEFAULT, new)	//Default network. Sending/recieving will always work on this one, no restrictions/checks.

/proc/return_network_by_id(id)
	return GLOB.networks[id]

/datum/network
	var/id	//MUST BE UNIQUE!
	var/list/obj/item/device/network_card/devices		//Associative list of devices by their ID. ID = device.

/datum/network/New()
	. = ..()
	if(!id)
		CRASH("Attempted creation of network with null ID!")
		qdel(src)
		return
	if(GLOB.networks[id])
		CRASH("Attempted creation of network id [id] when one already exists!")
		qdel(src)
		return
	GLOB.networks[id] = src
	devices = list()

/datum/network/proc/connect_device(obj/item/device/network_card/dev)
	if(!istype(dev))
		return FALSE
	devices[dev.id] = dev
	return TRUE

/datum/network/proc/disconnect_device(obj/item/device/network_card/dev)
	if(!istype(dev))
		return FALSE
	if(!devices[dev.id])
		return FALSE
	devices[dev.id] = null
	return TRUE

/datum/network/default
	id = NETWORK_ID_DEFAULT


