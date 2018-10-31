// Relays don't handle any actual communication. Global Exonet datum does that, relays only tell the datum if it should or shouldn't work.
/obj/machinery/exonet_relay
	name = "Exonet Quantum Relay"
	desc = "A very complex router and transmitter capable of connecting electronic devices together. Looks fragile."
	use_power = ACTIVE_POWER_USE
	active_power_usage = 10000 //10kW, apropriate for machine that keeps massive cross-Zlevel wireless network operational. Used to be 20 but that actually drained the smes one round
	idle_power_usage = 100
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "bus"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/exonet_relay
	var/datum/exonet/Exonet = null // This is mostly for backwards reference and to allow varedit modifications from ingame.
	var/enabled = 1				// Set to 0 if the relay was turned off
	var/dos_failure = 0			// Set to 1 if the relay failed due to (D)DoS attack
	var/list/dos_sources = list()	// Backwards reference for qdel() stuff
	var/uid
	var/static/gl_uid = 1

	// Denial of Service attack variables
	var/dos_overload = 0		// Amount of DoS "packets" in this relay's buffer
	var/dos_capacity = 500		// Amount of DoS "packets" in buffer required to crash the relay
	var/dos_dissipate = 1		// Amount of DoS "packets" dissipated over time.


// TODO: Implement more logic here. For now it's only a placeholder.
/obj/machinery/exonet_relay/is_operational()
	if(stat & (BROKEN | NOPOWER | EMPED))
		return FALSE
	if(dos_failure)
		return FALSE
	if(!enabled)
		return FALSE
	return TRUE

/obj/machinery/exonet_relay/update_icon()
	if(is_operational())
		icon_state = "bus"
	else
		icon_state = "bus_off"

/obj/machinery/exonet_relay/process()
	if(is_operational())
		use_power = ACTIVE_POWER_USE
	else
		use_power = IDLE_POWER_USE

	update_icon()

	if(dos_overload)
		dos_overload = max(0, dos_overload - dos_dissipate)

	// If DoS traffic exceeded capacity, crash.
	if((dos_overload > dos_capacity) && !dos_failure)
		dos_failure = 1
		update_icon()
		SSnetworks.station_network.add_log("Quantum relay switched from normal operation mode to overload recovery mode.")
	// If the DoS buffer reaches 0 again, restart.
	if((dos_overload == 0) && dos_failure)
		dos_failure = 0
		update_icon()
		SSnetworks.station_network.add_log("Quantum relay switched from overload recovery mode to normal operation mode.")
	..()

/obj/machinery/exonet_relay/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "exonet_relay", "Exonet Quantum Relay", 500, 300, master_ui, state)
		ui.open()


/obj/machinery/exonet_relay/ui_data(mob/user)
	var/list/data = list()
	data["enabled"] = enabled
	data["dos_capacity"] = dos_capacity
	data["dos_overload"] = dos_overload
	data["dos_crashed"] = dos_failure
	return data


/obj/machinery/exonet_relay/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("restart")
			dos_overload = 0
			dos_failure = 0
			update_icon()
			SSnetworks.station_network.add_log("Quantum relay manually restarted from overload recovery mode to normal operation mode.")
		if("toggle")
			enabled = !enabled
			SSnetworks.station_network.add_log("Quantum relay manually [enabled ? "enabled" : "disabled"].")
			update_icon()

/obj/machinery/exonet_relay/Initialize()
	uid = gl_uid++
	component_parts = list()

	if(SSnetworks.station_network)
		SSnetworks.station_network.relays.Add(src)
		Exonet = SSnetworks.station_network
		SSnetworks.station_network.add_log("New quantum relay activated. Current amount of linked relays: [Exonet.relays.len]")
	. = ..()

/obj/machinery/exonet_relay/Destroy()
	if(SSnetworks.station_network)
		SSnetworks.station_network.relays.Remove(src)
		SSnetworks.station_network.add_log("Quantum relay connection severed. Current amount of linked relays: [Exonet.relays.len]")
		Exonet = null

	for(var/datum/computer_file/program/exonet_dos/D in dos_sources)
		D.target = null
		D.error = "Connection to quantum relay severed"

	return ..()
