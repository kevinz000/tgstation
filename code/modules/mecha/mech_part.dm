/obj/item/mech_part
	name = "generic mech part"
	desc = "You don't know where this should go."
	icon = 'icons/mecha/parts/parts_item.dmi'
	icon_state = ""
	var/mech_icon = 'icons/mecha/parts/parts_mech.dmi'
	var/mech_icon_state = ""
	var/mob/living/machine/mecha/parent
	var/render_layer = MECH_RENDER_LAYER_DEFAULT
	var/slot = MECH_PART_SLOT_ERROR

	//var/list/components = list()
	//var/list/component_capacity = list()				//"[slot flag]" = number

/obj/item/mech_part/proc/on_life(seconds, times_fired)


/obj/item/mech_part/proc/get_overlays()
	. = list()
	. += icon(mech_icon, mech_icon_state)


/obj/item/mech_part/proc/get_render_layer()
	return render_layer
