/datum/computer_file/program/exonetmonitor
	filename = "ntmonitor"
	filedesc = "exonet Diagnostics and Monitoring"
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors stationwide exonet network, provides access to logging systems, and allows for configuration changes"
	size = 12
	requires_exonet = 1
	required_access = ACCESS_NETWORK	//NETWORK CONTROL IS A MORE SECURE PROGRAM.
	available_on_exonet = 1
	tgui_id = "ntos_net_monitor"

/datum/computer_file/program/exonetmonitor/ui_act(action, params)
	if(..())
		return 1
	switch(action)
		if("resetIDS")
			. = 1
			if(GLOB.exonet_global)
				GLOB.exonet_global.resetIDS()
			return 1
		if("toggleIDS")
			. = 1
			if(GLOB.exonet_global)
				GLOB.exonet_global.toggleIDS()
			return 1
		if("toggleWireless")
			. = 1
			if(!GLOB.exonet_global)
				return 1

			// exonet is disabled. Enabling can be done without user prompt
			if(GLOB.exonet_global.setting_disabled)
				GLOB.exonet_global.setting_disabled = 0
				return 1

			// exonet is enabled and user is about to shut it down. Let's ask them if they really want to do it, as wirelessly connected computers won't connect without exonet being enabled (which may prevent people from turning it back on)
			var/mob/user = usr
			if(!user)
				return 1
			var/response = alert(user, "Really disable exonet wireless? If your computer is connected wirelessly you won't be able to turn it back on! This will affect all connected wireless devices.", "exonet shutdown", "Yes", "No")
			if(response == "Yes")
				GLOB.exonet_global.setting_disabled = 1
			return 1
		if("purgelogs")
			. = 1
			if(GLOB.exonet_global)
				GLOB.exonet_global.purge_logs()
		if("updatemaxlogs")
			. = 1
			var/mob/user = usr
			var/logcount = text2num(input(user,"Enter amount of logs to keep in memory ([MIN_exonet_LOGS]-[MAX_exonet_LOGS]):"))
			if(GLOB.exonet_global)
				GLOB.exonet_global.update_max_log_count(logcount)
		if("toggle_function")
			. = 1
			if(!GLOB.exonet_global)
				return 1
			GLOB.exonet_global.toggle_function(text2num(params["id"]))

/datum/computer_file/program/exonetmonitor/ui_data(mob/user)
	if(!GLOB.exonet_global)
		return
	var/list/data = get_header_data()

	data["exonetstatus"] = GLOB.exonet_global.check_function()
	data["exonetrelays"] = GLOB.exonet_global.relays.len
	data["idsstatus"] = GLOB.exonet_global.intrusion_detection_enabled
	data["idsalarm"] = GLOB.exonet_global.intrusion_detection_alarm

	data["config_softwaredownload"] = GLOB.exonet_global.setting_softwaredownload
	data["config_peertopeer"] = GLOB.exonet_global.setting_peertopeer
	data["config_communication"] = GLOB.exonet_global.setting_communication
	data["config_systemcontrol"] = GLOB.exonet_global.setting_systemcontrol

	data["exonetlogs"] = list()

	for(var/i in GLOB.exonet_global.logs)
		data["exonetlogs"] += list(list("entry" = i))
	data["exonetmaxlogs"] = GLOB.exonet_global.setting_maxlogcount

	return data