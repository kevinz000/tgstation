/obj/machinery/exonet_node
	name = "exonet node"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "exonet_node"
	idle_power_usage = 25
	var/on = TRUE
	var/toggle = TRUE
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/exonet_node
	max_integrity = 300
	integrity_failure = 100
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)
	desc = "This machine is exonet node."
	var/list/logs = list() // Gets written to by exonet's send_message() function.
	var/opened = FALSE

/obj/machinery/exonet_node/Initialize()
	. = ..()
	SScircuit.all_exonet_nodes += src

/obj/machinery/exonet_node/Destroy()
	SScircuit.all_exonet_nodes -= src
	return ..()

/obj/machinery/exonet_node/proc/is_operating()
	return on && !stat

// Proc: update_icon()
// Parameters: None
// Description: Self explanatory.
/obj/machinery/exonet_node/update_icon()
	icon_state = "[initial(icon_state)][on? "" : "_off"]"

// Proc: update_power()
// Parameters: None
// Description: Sets the device on/off and adjusts power draw based on stat and toggle variables.
/obj/machinery/exonet_node/proc/update_power()
	on = is_operational() && toggle
	use_power = on
	update_icon()

// Proc: emp_act()
// Parameters: 1 (severity - how strong the EMP is, with lower numbers being stronger)
// Description: Shuts off the machine for awhile if an EMP hits it.  Ion anomalies also call this to turn it off.
/obj/machinery/exonet_node/emp_act(severity)
	if(!(stat & EMPED))
		stat |= EMPED
		var/duration = (300 * 10)/severity
		addtimer(CALLBACK(src, /obj/machinery/exonet_node/proc/unemp_act), rand(duration - 20, duration + 20))
	update_icon()
	..()

/obj/machinery/exonet_node/proc/unemp_act(severity)
	stat &= ~EMPED

// Proc: attackby()
// Parameters: 2 (I - the item being whacked against the machine, user - the person doing the whacking)
// Description: Handles deconstruction.
/obj/machinery/exonet_node/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/screwdriver))
		default_deconstruction_screwdriver(user, I)
	else if(istype(I, /obj/item/crowbar))
		default_deconstruction_crowbar(user, I)
	else
		return ..()

// Proc: attack_ai()
// Parameters: 1 (user - the AI clicking on the machine)
// Description: Redirects to attack_hand()
/obj/machinery/exonet_node/attack_ai(mob/user)
	ui_interact(user)


/obj/machinery/exonet_node/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, var/force_open = 1,datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "exonet_node", name, 600, 300, master_ui, state)
		ui.open()

/obj/machinery/exonet_node/ui_data(mob/user)
	var/list/data = list()
	data["toggle"] = toggle
	data["logs"] = logs
	return data

/obj/machinery/exonet_node/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle_power")
			toggle = !toggle
			update_power()
			if(!toggle)
				investigate_log("has been turned off by [key_name(usr)].", INVESTIGATE_EXONET)
			. = TRUE
	update_icon()
	add_fingerprint(usr)

// Proc: get_exonet_node()
// Parameters: None
// Description: Helper proc to get a reference to an Exonet node.

/obj/machinery/exonet_node/proc/write_log(var/origin_address, var/target_address, var/data_type, var/content)
	var/msg = "[time2text(world.time, "hh:mm:ss")] | FROM [origin_address] TO [target_address] | TYPE: [data_type] | CONTENT: [content]"
	logs.Add(msg)
// Relays don't handle any actual communication. Global NTNet datum does that, relays only tell the datum if it should or shouldn't work.
/obj/machinery/ntnet_relay
	name = "NTNet Quantum Relay"
	desc = "A very complex router and transmitter capable of connecting electronic devices together. Looks fragile."
	use_power = ACTIVE_POWER_USE
	active_power_usage = 10000 //10kW, apropriate for machine that keeps massive cross-Zlevel wireless network operational. Used to be 20 but that actually drained the smes one round
	idle_power_usage = 100
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "bus"
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/ntnet_relay
	var/datum/ntnet/NTNet = null // This is mostly for backwards reference and to allow varedit modifications from ingame.
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
/obj/machinery/ntnet_relay/is_operational()
	if(stat & (BROKEN | NOPOWER | EMPED))
		return 0
	if(dos_failure)
		return 0
	if(!enabled)
		return 0
	return 1

/obj/machinery/ntnet_relay/update_icon()
	if(is_operational())
		icon_state = "bus"
	else
		icon_state = "bus_off"

/obj/machinery/ntnet_relay/process()
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
		GLOB.ntnet_global.add_log("Quantum relay switched from normal operation mode to overload recovery mode.")
	// If the DoS buffer reaches 0 again, restart.
	if((dos_overload == 0) && dos_failure)
		dos_failure = 0
		update_icon()
		GLOB.ntnet_global.add_log("Quantum relay switched from overload recovery mode to normal operation mode.")
	..()

/obj/machinery/ntnet_relay/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "ntnet_relay", "NTNet Quantum Relay", 500, 300, master_ui, state)
		ui.open()


/obj/machinery/ntnet_relay/ui_data(mob/user)
	var/list/data = list()
	data["enabled"] = enabled
	data["dos_capacity"] = dos_capacity
	data["dos_overload"] = dos_overload
	data["dos_crashed"] = dos_failure
	return data


/obj/machinery/ntnet_relay/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("restart")
			dos_overload = 0
			dos_failure = 0
			update_icon()
			GLOB.ntnet_global.add_log("Quantum relay manually restarted from overload recovery mode to normal operation mode.")
		if("toggle")
			enabled = !enabled
			GLOB.ntnet_global.add_log("Quantum relay manually [enabled ? "enabled" : "disabled"].")
			update_icon()


/obj/machinery/ntnet_relay/attack_hand(mob/living/user)
	ui_interact(user)

/obj/machinery/ntnet_relay/Initialize()
	uid = gl_uid++
	component_parts = list()

	if(GLOB.ntnet_global)
		GLOB.ntnet_global.relays.Add(src)
		NTNet = GLOB.ntnet_global
		GLOB.ntnet_global.add_log("New quantum relay activated. Current amount of linked relays: [NTNet.relays.len]")
	. = ..()

/obj/machinery/ntnet_relay/Destroy()
	if(GLOB.ntnet_global)
		GLOB.ntnet_global.relays.Remove(src)
		GLOB.ntnet_global.add_log("Quantum relay connection severed. Current amount of linked relays: [NTNet.relays.len]")
		NTNet = null

	for(var/datum/computer_file/program/ntnet_dos/D in dos_sources)
		D.target = null
		D.error = "Connection to quantum relay severed"

	return ..()