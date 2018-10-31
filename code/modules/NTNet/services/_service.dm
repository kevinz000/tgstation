/datum/exonet_service
	var/name = "Unidentified Network Service"
	var/id
	var/list/networks_by_id = list()			//Yes we support multinetwork services!

/datum/exonet_service/New()
	var/datum/component/exonet_interface/N = AddComponent(/datum/component/exonet_interface, id, name, FALSE)
	id = N.hardware_id

/datum/exonet_service/Destroy()
	for(var/i in networks_by_id)
		var/datum/exonet/N = i
		disconnect(N, TRUE)
	networks_by_id = null
	return ..()

/datum/exonet_service/proc/connect(datum/exonet/net)
	if(!istype(net))
		return FALSE
	GET_COMPONENT(interface, /datum/component/exonet_interface)
	if(!interface.register_connection(net))
		return FALSE
	if(!net.register_service(src))
		interface.unregister_connection(net)
		return FALSE
	networks_by_id[net.network_id] = net
	return TRUE

/datum/exonet_service/proc/disconnect(datum/exonet/net, force = FALSE)
	if(!istype(net) || (!net.unregister_service(src) && !force))
		return FALSE
	GET_COMPONENT(interface, /datum/component/exonet_interface)
	interface.unregister_connection(net)
	networks_by_id -= net.network_id
	return TRUE

/datum/exonet_service/proc/exonet_intercept(datum/netdata/data, datum/exonet/net, datum/component/exonet_interface/sender)
	return
