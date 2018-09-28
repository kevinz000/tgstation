/mob/machine/mecha
	name = "generic exosuit"
	desc = "Looks generic."
	var/list/part_slots	= list()				//slot = obj/item/mech_part or path to one

/mob/machine/mecha/Initialize()
	. = ..()
	for(var/slot in part_slots)
		if(ispath(part_slots[slot], /obj/item/mech_part))
			var/obj/item/mech_part/P = new part_slots[slot]
			if(!length(part_slots & P.slots))
				qdel(P)
				continue
			part_slots[slot] = P
