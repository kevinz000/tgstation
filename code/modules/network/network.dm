
GLOBAL_LIST_EMPTY(networks)							//All unique networks in the game.
GLOBAL_DATUM_INIT(NETWORK_DEFAULT, NETWORK_PATH_DEFAULT, new)	//Default network. Sending/recieving will always work on this one, no restrictions/checks.

/proc/return_network_by_id(id)
	return GLOB.networks[id]

/datum/network
	var/id	//MUST BE UNIQUE!
	var/list/obj/item/device/network_card/devices		//Associative list of devices by their ID. ID = device.
	var/list/obj/item/device/network_card/sniffers		//Above, but this can recieve all signals no matter what.
	var/automatic_signal_relaying = TRUE

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

/datum/network/proc/on_signal_from_device(obj/item/device/network_card/dev, datum/network_signal/sig)
	if(automatic_signal_relaying)
		auto_relay(sig)

/datum/network/proc/auto_relay(datum/network_signal/sig)
	for(var/I in sniffers)
		var/obj/item/device/network_card/NIC = I
		send_signal_to_device(I, sig, FALSE)
	for(var/I in sig.recipients)
		if(devices[text2num(I)])
			send_signal_to_device(devices[text2num(I)], sig, TRUE)

/datum/network/proc/send_signal_to_device(obj/item/device/network_card/dev, datum/network_signal/sig, intended = TRUE)
	if(!intended)
		dev.promiscious_recieve(sig, id)
	else
		dev.network_recieve(sig, id)

/datum/network/default
	id = NETWORK_ID_DEFAULT


