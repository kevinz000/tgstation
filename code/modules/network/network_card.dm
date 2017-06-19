
GLOBAL_VAR_INIT(network_hardware_id_current, 1)
GLOBAL_LIST_EMPTY(network_devices_by_id)

/obj/item/device/network_card
	name = "networking card"
	var/hardware_id
	var/list/datum/network/connected_networks
	var/list/autoconnect_network_ids
	var/atom/host

/obj/item/device/network_card/Initialize()
	. = ..()
	hardware_id = GLOB.network_hardware_id_current++
	GLOB.network_devices_by_id[hardware_id] = src
	if(islist(autoconnect_network_ids))
		for(var/id in autoconnect_network_ids)
			var/datum/network/net = return_network_by_id(id)
			if(net)
				connect_to_network(net)

/obj/item/device/network_card/Destroy()
	for(var/net in connected_networks)
		disconnect_from_network(net)
	GLOB.network_devices_by_id[hardware_id] = null
	host = null
	return ..()

/obj/item/device/network_card/proc/connect_to_network(datum/network/connecting)
	if(!istype(connecting))
		return FALSE
	if(connecting.connect_device(src))
		LAZYADD(connected_networks, connecting)
		on_network_connect(connecting)
		return TRUE
	return FALSE

/obj/item/device/network_card/proc/on_network_connect(datum/network/connected)

/obj/item/device/network_card/proc/disconnect_from_network(datum/network/disconnecting)
	if(!istype(disconnecting) || !LAZYLEN(connected_networks) || !(disconnecting in connected_networks))
		return FALSE
	disconnecting.disconnect_device(src)
	on_network_disconnect(disconnecting)
	return TRUE

/obj/item/device/network_card/proc/on_network_disconnect(datum/network/lost)

/obj/item/device/network_card/proc/send_on_all_networks(datum/network_signal/sig)
	for(var/i in connected_networks)
		network_send(sig, i)

/obj/item/device/network_card/proc/network_send(datum/network_signal/sig, network_id)
	if(!connected_networks[network_id])
		return FALSE
	var/datum/network/N = connected_networks[network_id]
	return N.on_signal_from_device(src, sig)

/obj/item/device/network_card/proc/network_recieve(datum/network_signal/sig, network_id)
	if(host)
		host.on_network_recieve(src, sig, network_id)

/obj/item/device/network_card/proc/promiscious_recieve(datum/network_signal/sig, network_id)
	if(host)
		host.promiscious_network_recieve(src, sig, network_id)
