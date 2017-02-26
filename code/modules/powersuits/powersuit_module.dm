
/obj/item/device/powersuit_module
	name = "powersuit module"
	desc = "A piece of equipment fitted to be installed in a standard powersuit mounting port."
	resistance_flags = INDESTRUCTIBLE
	var/obj/item/device/powersuit_piece/host = null
	icon = 'icons/obj/powersuit/misc.dmi'
	icon_state = "generic_module"
	item_state = "flash"


/obj/item/device/powersuit_module/proc/unarmed_attack(atom/A, proximity)
	return FALSE








