
/obj/item/device/powersuit_control
	name = "powersuit control module"
	desc = "An extremely bulky back mounted unit that stores, powers, and controls powersuit pieces.
	icon = 'icons/obj/powersuit/back.dmi"
	icon_state = "basic"
	item_state = "
	slot_flags = SLOT_FLAG
	resistance_flags = INDESTRUCTIBLE
	siemens_coefficient = 0
	var/obj/item/device/powersuit_piece/suit_jumpsuit = null
	var/obj/item/device/powersuit_piece/suit_head = null
	var/obj/item/device/powersuit_piece/suit_exosuit = null
	var/obj/item/device/powersuit_piece/suit_hands = null
	var/obj/item/device/powersuit_piece/suit_boots = null
	var/obj/item/device/powersuit_piece/suit_eyes = null
	var/obj/item/device/powersuit_piece/suit_ears = null
	var/obj/item/device/powersuit_piece/suit_mask = null
	var/obj/item/device/powersuit_piece/suit_belt = null
	var/obj/item/device/powersuit_piece/suit_control = null
	var/mob/living/carbon/human/user = null

/obj/item/device/powersuit_control/proc/extend_part(obj/item/device/powersuit_piece/P, force = FALSE)
	return P.do_extend(force)

/obj/item/device/powersuit_control/proc/retract_part(obj/item/device/powersuit_piece/P, force = FALSE)
	return P.do_retract(force)








