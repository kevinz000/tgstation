
/obj/item/weapon/implant/mindshield/loyalty
	name = "loyalty implant"
	desc = "The old, outdated version of the mindshield implant, supposedly discontinued due to worker rights movements. Protects employees from brainwashing... <span class='boldwarning'>as well as ensuring their loyalty at any cost.</span>"
	origin_tech = "materials=2;biotech=4;programming=4;illegal=4"
	var/brainwash_override = FALSE

/obj/item/weapon/implant/mindshield/loyalty/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Loyalty Implant<BR>
				<b>Life:</b> Twenty years.<BR>
				<b>Important Notes:</b> Personnel injected with this device are much more resistant to brainwashing. Can be remotely activated to override thoughts.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that protects the host's mental functions from manipulation.<BR>
				<span class='boldwarning'>Alert:</span> Old version of mindshield implant. Contains now-illegal remote activated processing units that can coerce individuals to obey orders.<BR>
				[brainwash_override ? "<span class='boldwarning'>Warning: Remote override chip activated!</span><BR>" : ""]
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat

/obj/item/weapon/implant/mindshield/loyalty/implant(mob/living/target)
	if(brainwash_override)
		brainwash(target)
	. = ..()

/obj/item/weapon/implant/mindshield/loyalty/proc/brainwash(mob/living/target)
	if(target.mind in SSticker.mode.head_revolutionaries)
		target.emote("scream")
		target.visible_message("<span class='danger'>[target] clutches their head and screams in pain! Their new implant seems to have shorted out!</span>")	//Ouch!
		target.adjustFireLoss(30)
		qdel(src)
	if(istype(SSticker.mode, /datum/game_mode/order_66))
		var/datum/game_mode/order_66/GM = SSticker.mode
		GM.NT_brainwash(target.mind)
	else
		return FALSE

/obj/item/weapon/implant/mindshield/loyalty/proc/activate_order_66()
	brainwash_override = TRUE
	if(imp_in)
		brainwash(imp_in)

/* Deconversion isn't a thing for now.
/obj/item/weapon/implant/mindshield/loyalty/removed(mob/target, silent = 0, special = 0)
	if(..())
		//Deconversion, possibly.
		return TRUE
	return FALSE
*/

//No implanters, they're delivered via special means.

/obj/item/clothing/gloves/color/captain/order_66
	var/implants = 5

/obj/item/clothing/gloves/color/captain/order_66/Touch(atom/A, proximity)
	if(iscarbon(A) && iscarbon(loc) && proximity && (istype(SSticker.mode, /datum/game_mode/order_66)))
		var/mob/living/carbon/victim = A
		var/mob/living/carbon/converter = loc
		if(!implants)
			return ..()
		if(!(locate(/obj/item/weapon/implant/mindshield/loyalty) in victim))
			var/obj/item/weapon/implant/mindshield/loyalty/chip = new
			chip.brainwash_override = SSticker.mode.activated
			chip.implant(victim, converter, TRUE)
			to_chat(converter, "<span class='boldnotice'>You silently inject a NanoTrasen loyalty implant into [victim]...</span>")
	return ..()

/proc/scale_order_66_implants()
	var/coeff = config.order_66_implants_coeff
	var/players = 0
	for(var/I in GLOB.player_list)
		players++
	var/ret = ceiling(players/coeff)
	return ret

/proc/order_66_is_NT_loyalist(mob/living/L)
	if(istype(SSticker.mode, /datum/game_mode/order_66)
		var/datum/game_mode/order_66/order = SSticker.mode
		if(L.mind in order.NT_loyalists)
			return TRUE
	return FALSE

/proc/order_66_is_NT(mob/living/L)
	if(order_66_is_NT_loyalist(L) || order_66_is_NT_leader(L))
		return TRUE
	return FALSE

/proc/order_66_is_NT_leader(mob/living/L)
	if(istype(SSticker.mode, /datum/game_mode/order_66)
		var/datum/game_mode/order_66/order = SSticker.mode
		if(L.mind in order.NT_leaders)
			return TRUE
	return FALSE

/datum/game_mode/order_66/proc/add_loyalist(datum/mind/victim)

/datum/game_mode/order_66/proc/remove_loyalist(datum/mind/free)

/datum/game_mode/order_66/proc/prepare_NT_loyalist(datum/mind/M, roundstart = FALSE)
	//Prepare loyalist, etc etc

/datum/game_mode/order_66/proc/add_order_66_HUD_icons(datum/mind/loyalist)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ORDER_66]
	hud.join_hud(loyalist.current)
	set_antag_hud(loyalist.current, ((loyalist == NT_leader) ? "hud_order_66_leader" : "hud_order_66"))

/datum/game_mode/order_66/proc/remove_order_66_HUD_icons(datum/mind/rip)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ORDER_66]
	hud.leave_hud(rip.current)
	set_antag_hud(rip.current, null)
