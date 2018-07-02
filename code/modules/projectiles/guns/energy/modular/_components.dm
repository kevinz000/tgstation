/obj/item/egun_component
	name = "Generic Component"
	icon = 'icons/obj/guns/modular_eguns.dmi'
	icon_state = "surge_protector"
	var/component_type = "generic"					//ID doesn't necessarily describe it, more used for preventing conflicting components.
	var/supported_frame_types = ALL

/obj/item/egun_component/proc/can_attach(obj/item/gun/energy/modular/M, mob/user)

	return TRUE

/obj/item/egun_component/proc/can_detach(obj/item/gun/energy/modular/M, mob/user)

	return TRUE

/obj/item/egun_component/proc/on_attach(obj/item/gun/energy/modular/M)


/obj/item/egun_component/proc/on_detach(obj/item/gun/energy/modular/M)
