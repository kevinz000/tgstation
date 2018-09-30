/mob/living/machine/mecha
	name = "generic exosuit"
	desc = "Looks generic."
	var/list/parts_by_slot	= list()				//slot = obj/item/mech_part or path to one or null
	var/list/overlays_by_slot = list()

/mob/living/machine/mecha/Initialize()
	. = ..()
	for(var/slot in parts_by_slot)
		if(ispath(parts_by_slot[slot], /obj/item/mech_part))
			parts_by_slot[slot] = new parts_by_slot[slot]

//Might be switched to /process later?
/mob/living/machine/mecha/Life(seconds, times_fired)
	for(var/slot in parts_by_slot)
		var/obj/item/mech_part/MP = parts_by_slot[slot]
		MP.on_life(seconds, times_fired)

/mob/living/machine/mecha/proc/get_part_by_slot(slot)
	return parts_by_slot[slot]

/mob/living/machine/mecha/proc/get_parts_by_slots(list/slots)
	if(!islist(slots))
		return get_part_by_slot(slots)
	. = list()
	for(var/i in slots)
		if(parts_by_slot[i])
			. += parts_by_slot[i]

/mob/living/machine/mecha/proc/add_part(obj/item/mech_part/MP)
	if(!istype(MP))
		return FALSE
	if(!parts_by_slot.Find(MP.slot) || istype(parts_by_slot[MP.slot], /obj/item/mech_part))
		return FALSE
	parts_by_slot[MP.slot] = MP
	MP.forceMove(src)
	force_icon_rebuild_slot(MP.slot)
	return TRUE

/mob/living/machine/mecha/proc/remove_part(obj/item/mech_part/MP)
	if(!istype(MP))
		return FALSE
	if(!parts_by_slot.Find(MP.slot) || !(parts_by_slot[MP.slot] == MP))
		return FALSE
	parts_by_slot[MP.slot] = null
	overlays_by_slot -= MP.slot
	update_icons()
	MP.forceMove(drop_location())
	return TRUE

/mob/living/machine/mecha/proc/remove_slot(slot)
	remove_part(parts_by_slot[slot])
