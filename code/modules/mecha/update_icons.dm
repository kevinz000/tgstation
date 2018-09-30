/mob/living/machine/mecha/update_icons()
	cut_overlays()
	. = ..()
	var/list/new_overlays = list()
	var/list/obj/item/mech_part/assembled = list()
	for(var/slot in parts_by_slot)
		assembled += parts_by_slot[slot]
	//timsort/whatever
	for(var/i in 1 to assembled.len)
		var/obj/item/mech_part/MP = assembled[i]
		if(!overlays_by_slot[MP.slot])
			continue
		new_overlays += overlays_by_slot[MP.slot]
	add_overlay(new_overlays)

/mob/living/machine/mecha/proc/force_icon_rebuild(update = TRUE)
	overlays_by_slot.Cut()
	for(var/slot in parts_by_slot)
		var/obj/item/mech_part/MP = parts_by_slot[slot]
		var/ret = MP.get_overlays()
		if(isnull(ret))
			continue
		overlays_by_slot[slot] = ret
	if(update)
		update_icons()

/mob/living/machine/mecha/proc/force_icon_rebuild_slot(slot, update = TRUE)
	overlays_by_slot -= slot
	if(parts_by_slot[slot])
		var/obj/item/mech_part/MP = parts_by_slot[slot]
		var/ret = MP.get_overlays()
		if(isnull(ret))
			return
		overlays_by_slot[slot] = ret
	if(update)
		update_icons()
