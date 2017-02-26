
/obj/item/clothing
	var/obj/item/device/powersuit_piece/powersuit_module = null

/obj/item/device/radio/headset
	var/obj/item/device/powersuit_piece/powersuit_module = null

/obj/item/weapon/storage/belt
	var/obj/item/device/powersuit_piece/powersuit_module = null

/obj/item/device/powersuit_piece
	name = "powersuit integration module"
	desc = "A complex device that gives a mundane piece of clothing armor and equipment mounting slots. Normally not seen outside of actual powersuits, and normally not used \
		in such mundane clothing..."
	icon = 'icons/obj/powersuit/misc.dmi'
	icon_state = "generic_part"
	item_state = "flash"
	resistance_flags = INDESTRUCTIBLE
	siemens_coefficient = 0
	var/obj/item/worn_piece = null
	var/obj/item/device/powersuit_control/controller = null
	var/worn_type = POWERSUIT_PIECE_NONE
	var/list/obj/item/device/powersuit_module/modules = list()

/obj/item/device/powersuit_piece/proc/retract(force = FALSE)
	worn_piece.flags &= ~NODROP
	var/mob/living/carbon/human/H = worn_piece.loc
	if(!istype(H))
		worn_piece.forceMove(controller)
		return FALSE
	if(H.transferItemToLoc(worn_piece, controller, force))
		to_user("[worn_piece] unlatches from your body and retracts into [controller]!", POWERSUIT_CHAT_NOTICE)
		return TRUE
	else
		to_user("[worn_piece] is stuck on your body and can't seem to retract properly!", POWERSUIT_CHAT_WARNING)
		return FALSE

/obj/item/device/powersuit_piece/proc/do_retract(force = FALSE)
	if(worn_type == POWERSUIT_PIECE_BACK || worn_type = POWERSUIT_PIECE_NONE || !worn_piece)
		return FALSE
	return retract(force)

/obj/item/device/powersuit_piece/proc/to_user(message, priority = POWERSUIT_CHAT_NOTICE)
	if(controller)
		controller.to_user(message, priority)

/obj/item/device/powersuit_piece/proc/extend(force = FALSE)
	var/mob/living/carbon/human/H = controller.loc
	if(!istype(H))
		return FALSE
	var/part_slot = powersuit_typedefine_to_slot(worn_type)
	if(force)
		var/obj/item/I = get_item_by_slot(part_slot)
		H.dropItemToGround(I, TRUE)
	if(equip_to_slot_if_possible(worn_piece, part_slot))
		worn_piece.flags |= NODROP
		to_user("[worn_piece] extends over your body and locks into place!", POWERSUIT_CHAT_NOTICE)
		return TRUE
	else
		to_user("[worn_piece] jams and is unable to properly extend!", POWERSUIT_CHAT_WARNING)
		return FALSE

/obj/item/device/powersuit_piece/proc/do_extend(force = FALSE)
	if(worn_type == POWERSUIT_PIECE_BACK || worn_type == POWERSUIT_PIECE_NONE || !worn_piece)
		return FALSE
	return extend(force)

/obj/item/device/powersuit_piece/proc/unarmed_attack(atom/A, proximity)
	. = 0
	for(var/obj/item/device/powersuit_module/M in modules)
		. += M.unarmed_attack(A, proximity)

/obj/item/device/powersuit_piece/proc/autoset_clothing_type(/obj/item/C)
	if(istype(C, /obj/item/device/radio/headset))
		worn_type = POWERSUIT_PIECE_EARS
	else if(istype(C, /obj/item/clothing/glasses))
		worn_type = POWERSUIT_PIECE_EYES
	else if(istype(C, /obj/item/clothing/under))
		worn_type = POWERSUIT_PIECE_JUMPSUIT
	else if(istype(C, /obj/item/clothing/gloves))
		worn_type = POWERSUIT_PIECE_HANDS
	else if(istype(C, /obj/item/clothing/shoes))
		worn_type = POWERSUIT_PIECE_BOOTS
	else if(istype(C, /obj/item/clothing/head))
		worn_type = POWERSUIT_PIECE_HELMET
	else if(istype(C, /obj/item/clothing/mask))
		worn_type = POWERSUIT_PIECE_MASK
	else if(istype(C, /obj/item/clothing/suit))
		worn_type = POWERSUIT_PIECE_EXOSUIT
	else if(istype(C, /obj/item/device/powersuit_control))
		worn_type = POWERSUIT_PIECE_BACK
	else if(istype(C, /obj/item/weapon/storage/belt))
		worn_type = POEWRSUIT_PIECE_BELT
	else
		worn_type = POWERSUIT_PIECE_NONE
		return FALSE
	return TRUE

/obj/item/device/powersuit_piece/proc/attach_to_clothing(/obj/item/C)
	if(ismob(loc))
		var/mob/M = loc
		if(!M.drop_item(src))
			return FALSE
	if(!autoset_clothing_type(C))
		return FALSE
	if(!(C.resistance_flags & INDESTRUCTIBLE))
		C.resistance_flags |= INDESTRUCTIBLE
	C.siemens_coefficient = 0
	C.powersuit_module = src
	forceMove(C)
	return TRUE

/obj/item/device/powersuit_piece/proc/detach_from_clothing(/obj/item/C)
	C.resistance_flags = initial(C.resistnace_flags)
	C.siemens_coefficient = initial(C.siemens_coefficient)
	C.powersuit_module = null
	for(var/obj/item/device/powersuit_module/M in modules)
		M.remove(src, null)
		M.forceMove(get_turf(C))
	forceMove(get_turf(C))
	worn_type = POWERSUIT_PIECE_NONE
	return TRUE
