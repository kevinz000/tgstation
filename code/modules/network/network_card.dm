
GLOBAL_VAR_INIT(network_hardware_id_current, 1)
GLOBAL_LIST_EMPTY(network_devices_by_id)		//Admins: Don't touch this. Ever.

/obj/item/device/network_card
	name = "networking card"
	var/hardware_id							//ID of the device. Can not be changed. Admins: Don't touch this. Ever. Doing so will result in bad things.
	var/network_name = "Network Device"		//Name of the device. Change as you want.
	var/list/datum/network/connected_networks
	var/list/obj/item/device/network_card/constant_connections		//Simulated constant connections, for things like live updating UIs and cameranet connections. networkid = connections
	var/list/autoconnect_network_ids
	var/atom/host

/obj/item/device/network_card/Initialize()
	. = ..()
	hardware_id = num2text(GLOB.network_hardware_id_current++)
	GLOB.network_devices_by_id[hardware_id] = src
	constant_connections = list()
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

/obj/item/device/network_card/proc/return_location()
	if(host)
		return host.loc
	return loc

/obj/item/device/network_card/proc/return_zlevel()
	var/turf/T = get_turf(return_location())
	return T.z

/obj/item/device/network_card/proc/get_hardware_id()
	return hardware_id

/obj/item/device/network_card/proc/return_network_nickname()
	return network_name

/obj/item/device/network_card/proc/get_full_identifier()
	return "\[[hardware_id]\] - \"[network_name]\""

/obj/item/device/network_card/proc/on_constant_connection_break(obj/item/device/network_card/dev)

/obj/item/device/network_card/proc/make_constant_connection(obj/item/device/network_card/dev, network_id)
	var/datum/network/N = connected_networks[network_id]
	if(!N)
		return FALSE
	if(N.add_constant_connection(src, dev))
		if(!constant_connections[network_id])
			constant_connections[network_id] = list()
		var/list/L = constant_connections[network_id]
		L += dev
		return TRUE
	return FALSE

/obj/item/device/network_card/proc/break_constant_connection(obj/item/device/network_card/dev, network_id)
	var/datum/network/N = connected_networks[network_id]
	if(!N)
		return FALSE
	if(N.break_constant_connection(src, dev))
		var/list/L = constant_connections[network_id]
		L -= dev
		return TRUE
	return FALSE

/obj/item/device/network_card/proc/connect_to_network_id(id)
	return connect_to_network(return_network_by_id(id))

/obj/item/device/network_card/proc/connect_to_network(datum/network/connecting)
	if(!istype(connecting))
		return FALSE
	if(connecting.connect_device(src))
		LAZYADD(connected_networks, connecting)
		on_network_connect(connecting)
		return TRUE
	return FALSE

/obj/item/device/network_card/proc/on_network_connect(datum/network/connected)

/obj/item/device/network_card/proc/disconnect_from_network_id(id)
	return disconnect_from_network(return_network_by_id(id))

/obj/item/device/network_card/proc/disconnect_from_network(datum/network/disconnecting)
	if(!istype(disconnecting) || !LAZYLEN(connected_networks) || !(disconnecting in connected_networks))
		return FALSE
	if(constant_connections[disconnecting.id])
		for(var/i in constant_connections[disconnecting.id])
			break_constant_connection(i, disconnecting.id)
	disconnecting.disconnect_device(src)
	on_network_disconnect(disconnecting)
	return TRUE

/obj/item/device/network_card/proc/on_network_disconnect(datum/network/lost)

/obj/item/device/network_card/proc/send_on_all_networks(datum/network_signal/sig)
	for(var/i in connected_networks)
		network_send(sig, i)

/obj/item/device/network_card/proc/network_send(datum/network_signal/sig, network_id)
	if(!connected_networks[network_id] || !can_recieve_network(network_id))
		return FALSE
	var/datum/network/N = connected_networks[network_id]
	return N.on_signal_from_device(src, sig)

/obj/item/device/network_card/proc/can_send_network(network_id)
	return TRUE

/obj/item/device/network_card/proc/network_recieve(datum/network_signal/sig, network_id)
	if(host && can_recieve_network(network_id))
		host.on_network_recieve(src, sig, network_id)

/obj/item/device/network_card/proc/can_recieve_network(network_id)
	return TRUE

/obj/item/device/network_card/proc/promiscious_recieve(datum/network_signal/sig, network_id)
	if(host && can_recieve_network(network_id))
		host.promiscious_network_recieve(src, sig, network_id)
