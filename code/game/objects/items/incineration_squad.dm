
/obj/item/watertank/incineration_pack
	name = "Incineration pack"
	desc = "A back mounted fuel storage unit for an incineration flamethrower."

/obj/item/watertank/incineration_pack/make_noz()
	return new /obj/item/incineration_flamethrower

#define INCINERATOR_MODE_FLAME 1
#define INCINERATOR_MODE_CREMATE 2

/obj/item/incineration_flamethrower		//before maintainers yell, this is radically different from flamethrowers.
	name = "Incineration Flamethrower"
	desc = "A high-tech flamethrower that automatically generates burn-mix at a slow rate and can cremate bodies to a dust to use as biofuel."
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/weapons/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/flamethrower_righthand.dmi'
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	var/mode = INCINERATOR_MODE_FLAME

	var/obj/item/tank/internals/plasma/incineration_flamethrower/tank
	var/list/burnmix_gas_ratios
	var/burnmix_temperature = 373
	var/autofill_mole_limit = 30
	var/autofill_moles = 0.5
	var/cremation_moles = 5
	var/cremation_mole_limit = 30

/obj/item/tank/internals/plasma/incineration_flamethrower
	volume = 150

/obj/item/incineration_flamethrower/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The gas pressure gauge reads [tank.air_contents.return_pressure()] kpa.</span>")

/obj/item/incineration_flamethrower/Initialize()
	. = ..()
	tank = new
	START_PROCESSING(SSobj, src)
	burnmix_gas_ratios = list("o2" = 0.09, "plasma" = 0.91)

/obj/item/incineration_flamethrower/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/incineration_flamethrower/process()
	autofill_tank()

/obj/item/incineration_flamethrower/proc/autofill_tank()
	var/needed = autofill_mole_limit - tank.air_contents.total_moles()
	if(needed <= 0)
		return
	fill_tank(max(autofill_moles, needed))

/obj/item/incineration_flamethrower/proc/fill_tank(moles)
	var/datum/gas_mixture/adding = new(tank.volume)
	for(var/id in burnmix_gas_ratios)
		ASSERT_GAS(id, adding)
		adding.gases[id][MOLES] = moles * burnmix_gas_ratios[id]
	tank.air_contents.merge(adding)

/obj/item/incineration_flamethrower/afterattack(atom/target, mob/user, flag)
	if(flag || (ishuman(user) && !can_trigger_gun(user)))
		return
	if(mode == INCINERATOR_MODE_FLAME)
		flame_attack(target, user)
	else if(mode == INCINERATOR_MODE_CREMATE && ismob(target))
		var/mob/M = target
		if(M.stat == DEAD)
			cremate_mob(target)

/obj/item/incineration_flamethrower/attack_self(mob/user)
	if(mode == INCINERATOR_MODE_FLAME)
		mode = INCINERATOR_MODE_CREMATE
	else
		mode = INCINERATOR_MODE_FLAME
	to_chat(user, "<span class'danger'>You set [src] to [mode == INCINERATOR_MODE_FLAME? "incineration" : "body cremation"] mode.</span>")

/obj/item/incineration_flamethrower/proc/cremate_mob(mob/target, mob/user)
	add_logs(user, target, "cremated with an incineration flamethrower", src)
	user.visible_message("<span class='danger'>[user] cremates [target] into a fine dust with [src], which absorbs [target]'s body as biofuel!</span>")
	fill_tank(cremation_moles)
	target.dust()

/obj/item/incineration_flamethrower/proc/flame_attack(atom/target, mob/user)
	var/turf/starting = get_turf(src)
	target = get_turf(target)
	add_logs(user, target, "incinerated", src)
	var/flaming = getline(starting, target)
	var/iter = 0
	var/turf/current = get_turf(src)
	for(var/t in flaming)
		var/turf/T = t
		if(t == starting)
			continue
		var/list/connected = current.GetAtmosAdjacentTurfs(alldir=TRUE)
		if(!(T in connected))
			break
		current = T
		addtimer(CALLBACK(src, .proc/flame_turf, T), iter)
		iter++

/obj/item/incineration_flamethrower/proc/flame_turf(turf/T)
	var/datum/gas_mixture/flame_gas = tank.air_contents.remove_ratio(0.05)
	T.assume_air(flame_gas)
	T.hotspot_expose(1000, 100)
	SSair.add_to_active(T)
