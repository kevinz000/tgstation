
GLOBAL_LIST_EMPTY(networks)							//All unique networks in the game.
GLOBAL_DATUM_INIT(network_default, /datum/network/default, new)	//Default network. Sending/recieving will always work on this one, no restrictions/checks.

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
	devices[dev.hardware_id] = dev
	return TRUE

/datum/network/proc/disconnect_device(obj/item/device/network_card/dev)
	if(!istype(dev))
		return FALSE
	if(!devices[dev.hardware_id])
		return FALSE
	devices[dev.hardware_id] = null
	return TRUE

/datum/network/proc/on_signal_from_device(obj/item/device/network_card/dev, datum/network_signal/sig)
	if(!can_recieve_from_device(dev))
		return FALSE
	sniffer_intercept_signal(sig)
	if(automatic_signal_relaying)
		auto_relay(sig)
	return TRUE

/datum/network/proc/can_recieve_from_device(obj/item/device/network_card/dev)
	return TRUE

/datum/network/proc/can_send_to_device(obj/item/device/network_card/dev)
	return TRUE

/datum/network/proc/auto_relay(datum/network_signal/sig)
	if(sig.broadcast)
		return network_broadcast(sig)
	for(var/I in sig.recipient_ids)
		if(devices[text2num(I)])
			send_signal_to_device(devices[text2num(I)], sig)

/datum/network/proc/network_broadcast(datum/network_signal/sig)
	for(var/I in devices)
		send_signal_to_device(devices[I], sig)

/datum/network/proc/sniffer_intercept_signal(datum/network_signal/sig)
	for(var/I in sniffers)
		if(can_send_to_device(sniffers[I])
			var/obj/item/device/network_card/NIC = I
			NIC.promiscious_recieve(sig, id)

/datum/network/proc/send_signal_to_id(datum/network_signal/sig, id)
	if(devices[id])
		send_signal_to_device(devices[id],sig)

/datum/network/proc/send_signal_to_device(obj/item/device/network_card/dev, datum/network_signal/sig)
	sniffer_intercept_signal(sig)
	if(can_send_to_device(dev))
		dev.network_recieve(sig, id)

/datum/network/proc/network_signal_to_device(obj/item/device/network_card/dev, datum/network_signal/sig)
	sig.source_id = HARDWARE_ID_NETWORK
	send_signal_to_device(dev, sig)

/datum/network/default
	id = NETWORK_ID_DEFAULT


