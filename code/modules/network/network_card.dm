
GLOBAL_VAR_INIT(network_card_hardware_id_current, 1)
GLOBAL_LIST_EMPTY(network_cards_by_id)

/obj/item/device/network_card
	name = "networking card"
	var/hardware_id
	var/list/datum/network/connected_networks
	var/list/autoconnect_network_ids

/obj/item/device/network_card/Initialize()
	. = ..()
	hardware_id = GLOB.network_card_hardware_id_current++
	GLOB.network_cards_by_id[hardware_id] = src
	if(islist(autoconnect_network_ids))
		for(var/id in autoconnect_network_ids)
			var/datum/network/net = return_network_by_id(id)
			if(net)
				connect_to_network(net)

/obj/item/device/network_card/Destroy()
	for(var/net in connected_networks)
		disconnect_from_network(net)
	GLOB.network_cards_by_id[hardware_id] = null
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

/obj/item/device/network_card/proc/network_send(




/obj/item/device/network_card/proc/network_recieve(


