
GLOBAL_DATUM(network_ntnet, /datum/network/ntnet)	//NTNet

/datum/network/ntnet
	id = NETWORK_ID_NTNET

	var/list/logs = list()	//NTNet specific logs

	var/list/obj/machinery/ntnet_relay/relays = list()	//Assoc list relay_id = relay
	var/relaychat_channels = list()

	var/ntnet_allow_flags = NTNET_ALLOW_ALL	//Deprecate this ASAP /PLEASE/
	var/IDS_enabled = TRUE					//Same
	var/IDS_triggered = FALSE				//Same

	var/list/NTOS_station_software = list()
	var/list/NTOS_antag_software = list()
	var/list/fileservers = list()

/datum/network/ntnet/New()
	. = ..()
	ntnet_log("NTNET SYSTEM INIT")
	build_ntnet_software_lists()

/datum/network/ntnet/proc/register_relay(obj/machinery/ntnet_relay/NTR)
	relays[NTR.relay_id] = NTR
	return TRUE

/datum/network/ntnet/proc/unregister_relay(obj/machinery/ntnet_relay/NTR)
	relays -= [NTR.relay_id]

/datum/network/ntnet/proc/get_relay_by_id(id)
	if(!istext(id))
		id = num2text(id)
	return relays[id]

/datum/network/ntnet/proc/return_zlevel_connectivity(zlevel)
	var/relay = FALSE
	for(var/i in relays)
		var/obj/machinery/nt_relay/NTR = relays[i]
		if(NTR.z == zlevel)
			relay = TRUE
			break
	if(relay)
		return NTNET_WIRELESS_STRONG
	else if(relays.len)
		return NTNET_WIRELESS_WEAK
	return NTNET_WIRELESS_NONE

/datum/network/ntnet/can_send_to_device(obj/item/device/network_card/NIC)
	. = ..()
	if(.)
		return get_connection_strength_to_device(NIC)

/datum/network/ntnet/can_recieve_to_device(obj/item/device/network_card/NIC)
	. = ..()
	if(.)
		return get_connection_strength_to_device(NIC)

/datum/network/ntnet/connect_device(obj/item/device/network_card/NIC)
	if(get_connection_strength_to_device(NIC))
		return ..()
	else
		return FALSE

/datum/network/ntnet/proc/get_connection_strength_to_device(obj/item/device/network_card/NIC)
	if(!istype(NIC, /obj/item/device/network_card/ntnet))
		return NTNET_CONNECTION_WEAK	//Lesser devices get connection for now.
	var/obj/item/device/network_card/ntnet/NTNIC = NIC
	if(NTNIC.ethernet && NTNIC.is_ethernet_connected)
		return NTNET_CONNECTION_ETHERNET
	var/relay_boost = return_zlevel_connectivity(NTNIC.return_zlevel)
	if(!NTNIC.wireless_range || !relay_boost)
		return NTNET_CONNECTION_NONE
	if(relay_boost == NTNET_WIRELESS_STRONG)
		return NTNIC.wireless_range
	else if(relay_boost == NTNET_WIRELESS_WEAK)
		return Clamp(NTNIC.wireless_range - 1, 0, NTNET_CONNECTION_ETHERNET)

/datum/network/ntnet/proc/resetIDS()
	IDS_triggered = FALSE

/datum/network/ntnet/proc/toggleIDS()
	resetIDS()
	IDS_enabled = !IDS_enabled

/datum/network/ntnet/proc/build_ntnet_software_lists()
	NTOS_station_software = list()
	NTOS_antag_software = list()
	for(var/F in typesof(/datum/computer_file/program))
		var/datum/computer_file/program/prog = new F
		if(!prog || prog.filename == "UnknownProgram" || prog.filetype != "PRG")
			continue
		if(prog.available_on_ntnet)
			NTOS_station_software += prog
		if(prog.available_on_syndinet)
			NTOS_antag_software += prog

/datum/network/ntnet/proc/ntnet_log(lstring, obj/item/device/network_card/source)
	var/log_text = "[worldtime2text()] - "
	if(source)
		log_text += "[source.get_network_tag()] - "
	else
		log_text += "*SYSTEM* - "
	log_text += lstring
	logs += log_text

//Checks whether a specific NTNet function is allowed. Please, deprecate this for better simulated permissions!
/datum/network/ntnet/proc/check_ntnet_function(flag)
	return (ntnet_allow_flags & flag)

/datum/network/ntnet/proc/find_NTOS_software_by_name(filename)
	for(var/N in NTOS_station_software)
		var/datum/computer_file/program/P = N
		if(filename == P.filename)
			return P
	for(var/N in NTOS_antag_software)
		var/datum/computer_file/program/P = N
		if(filename == P.filename)
			return P

/datum/network/ntnet/proc/toggle_function(function)
	if(!function)
		return
	var/new_state = !(ntnet_allow_flags & function)
	if(new_state)
		ntnet_allow_flags |= function
	else
		ntnet_allow_flags &= ~function
	switch(function)
		if(NTNET_ALLOW_DOWNLOAD)
			ntnet_log("Configuration Updated. Wireless network firewall now [new_state ? "allows" : "disallows"] connection to software repositories.")
		if(NTNET_ALLOW_P2P)
			ntnet_log("Configuration Updated. Wireless network firewall now [new_state ? "allows" : "disallows"] peer to peer network traffic.")
		if(NTNET_ALLOW_COMMUNICATION)
			ntnet_log("Configuration Updated. Wireless network firewall now [new_state ? "allows" : "disallows"] instant messaging and similar communication services.")
		if(NTNET_ALLOW_CONTROL)
			ntnet_log("Configuration Updated. Wireless network firewall now [new_state ? "allows" : "disallows"] remote control of station's systems.")
