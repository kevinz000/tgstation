/obj/item/gun/energy/modular
	ammo_type = list(/obj/item/ammo_casing/energy/modular)
	automatic_charge_overlays = FALSE
	cell_type = null

	var/frame_type = EGUN_FRAME_MEDIUM

	var/list/start_components			//list of typepaths to attach on init

	var/list/all_components				//assoc list component_type = component, used for quick lookup, and preventing conflicts

	var/obj/item/egun_component/capacitor/capacitor

	var/list/obj/item/egun_component/modulator/modulators
	var/max_modulators = 2
	var/active_modulator_index = 1

	var/obj/item/egun_component/lens/lens

	var/list/obj/item/egun_component/mod/mods
	var/max_mods = 4

/obj/item/gun/energy/modular/Initialize()
	. = ..()
	for(var/path in start_components)
		var/obj/item/egun_component/C = new path(src)
		if(istype(C))
			if(!try_attach(C))
				qdel(C)
	start_components = null

/obj/item/gun/energy/modular/Destroy()
	for(var/i in all_components)
		force_detach(i)
		qdel(i)
	return ..()

/obj/item/gun/energy/modular/proc/reset(update = TRUE)

	if(update)
		update_components(FALSE)
	return TRUE

/obj/item/gun/energy/modular/proc/update_components(reset = TRUE)
	if(reset)
		reset(FALSE)

	update_icon()
	return TRUE

/obj/item/gun/energy/modular/proc/force_attach(obj/item/egun_component/C, update = TRUE, mob/user)
	LAZYSET(all_components, C.component_type, C)
	C.forceMove(src)
	C.on_attach(src, user)
	if(update)
		update_components()
	return TRUE

/obj/item/gun/energy/modular/proc/force_detach(obj/item/egun_component/C, update = TRUE, mob/user)
	LAZYREMOVE(all_components, C.component_type)
	UNSETEMPTY(all_components)
	C.forceMove(drop_location())
	C.on_detach(src, user)
	if(update)
		update_components()
	return TRUE

/obj/item/gun/energy/modular/proc/try_attach(obj/item/egun_component/C, mob/user)
	if(!C.can_attach(src, user) || !can_attach(C, user))
		return FALSE
	return force_attach(C, user)

/obj/item/gun/energy/modular/proc/try_detach(obj/item/egun_component/C, mob/user)
	if(C.can_detach(src, user) || !can_detach(C, user))
		return FALSE
	return force_detach(C, user)

/obj/item/gun/energy/modular/proc/can_attach(obj/item/egun_component/C, mob/user)
	if(all_components[C.component_type])
		to_chat(user, "<span class='warning'>[src] already has another component of this type!</span>")
		return FALSE

	return TRUE

/obj/item/gun/energy/modular/proc/can_detach(obj/item/egun_component/C, mob/user)

	return TRUE

/obj/item/gun/energy/modular/update_icon()



