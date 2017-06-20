/datum/computer_file/program/ntnetmonitor
	filename = "ntmonitor"
	filedesc = "NTNet Diagnostics and Monitoring"
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors stationwide NTNet network, provides access to logging systems, and allows for configuration changes"
	size = 12
	requires_ntnet = 1
	required_access = GLOB.access_network	//Network control is a more secure program.
	available_on_ntnet = 1
	tgui_id = "ntos_net_monitor"
	var/ntnet_ids_status = FALSE
	var/ntnet_ids_trigger = FALSE
	var/ntnet_allow_flags = 0
	var/ntnet_wireless = FALSE
	var/ntnet_relay_count = 0
	var/ntnet_logs

/datum/computer_file/program/ntnetmonitor/proc/send_ntnet_command(command, command_args)
	var/datum/network_signal/sigout = new
	sigout.add_recipient(HARDWARE_ID_NETWORK)
	sigout.set_text_data_by_key("type", "NTNET_COMMAND")
	if(command)
		sigout.set_text_data_by_key("command", command)
	if(command)
		sigout.set_text_data_by_key("args", command_args)
	return network_send(sigout)

/datum/computer_file/program/ntnetmonitor/proc/request_ntnet_data()
	var/datum/network_signal/sigout = new
	sigout.add_recipient(HARDWARE_ID_NETWORK)
	sigout.set_text_data_by_key("type", "NTNET_QUERY")
	sigout.set_text_data_by_key("query", "NTNET_STATUS")
	sigout.set_text_data_by_key("return_prog_name", filename)
	return network_send(sigout)

/datum/computer_file/program/ntnetmonitor/process_tick()
	request_ntnet_data()
	. = ..()

/datum/computer_file/program/ntnetmonitor/on_network_recieve(obj/item/device/network_card/NIC, datum/network_signal/sig, network_id)
	if(!sig.get_text_data_by_key("type") == "NTNET_STATUS")
		return ..()
	var/list/L = sig.get_all_text_data
	ntnet_ids_trigger = L["ids_trigger"]
	ntnet_ids_status = L["ids_status"]
	ntnet_allow_flags = L["allow_flags"]
	ntnet_wireless = L["wireless_active"]
	ntnet_relay_count = L["relay_count"]
	ntnet_logs = L["logstring"]

/datum/computer_file/program/ntnetmonitor/ui_act(action, params)
	if(..())
		return TRUE
	switch(action)
		if("resetIDS")
			send_ntnet_command(action)
			return TRUE
		if("toggleIDS")
			send_ntnet_command(action)
			return TRUE
		if("toggleWireless")
			if(!GLOB.network_ntnet.ntnet_wireless)
				send_ntnet_command(action)
				return TRUE
			// NTNet is enabled and user is about to shut it down. Let's ask them if they really want to do it, as wirelessly connected computers won't connect without NTNet being enabled (which may prevent people from turning it back on)
			var/mob/user = usr
			if(!user)
				return TRUE
			var/response = alert(user, "Really disable NTNet wireless? If your computer is connected wirelessly you won't be able to turn it back on! This will affect all connected wireless devices.", "NTNet shutdown", "Yes", "No")
			if(response == "Yes")
				send_ntnet_command(action)
			return TRUE
		if("purgelogs")
			send_ntnet_command(action)
			return TRUE
		if("toggle_function")
			send_ntnet_command(action, params["id"])
			return TRUE

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	if(!GLOB.ntnet_global)
		return
	var/list/data = get_header_data()

	data["ntnetstatus"] = ntnet_wireless
	data["ntnetrelays"] = ntnet_relay_count
	data["idsstatus"] = ntnet_ids_status
	data["idsalarm"] = ntnet_ids_trigger

	data["config_softwaredownload"] = (ntnet_allow_flags & NTNET_ALLOW_DOWNLOAD)
	data["config_peertopeer"] = (ntnet_allow_flags & NTNET_ALLOW_P2P)
	data["config_communication"] = (ntnet_allow_flags & NTNET_ALLOW_COMMUNICATION)
	data["config_systemcontrol"] = (ntnet_allow_flags & NTNET_ALLOW_CONTROL)

	data["ntnetlogs"] = list()

	var/list/ntnet_log_list = splittext(ntnet_logs, NTNET_LOG_SEPARATOR)
	for(var/i in ntnet_log_list)
		data["ntnetlogs"] += list(list("entry" = i))

	return data