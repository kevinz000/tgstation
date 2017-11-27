
// External storage-related logic:
// /mob/proc/ClickOn() in /_onclick/click.dm - clicking items in storages
// /mob/living/Move() in /modules/mob/living/living.dm - hiding storage boxes on mob movement

/datum/component/storage/concrete
	var/drop_all_on_deconstruct = TRUE
	var/drop_all_on_destroy = FALSE
	var/transfer_contents_on_component_transfer = FALSE
	var/list/datum/component/storage/slaves = list()

/datum/component/storage/concrete/Initialize()
	. = ..()
	RegisterSignal(COMSIG_ATOM_CONTENTS_DEL, .proc/on_contents_del)
	RegisterSignal(COMSIG_OBJ_DECONSTRUCT, .proc/on_deconstruct)

/datum/component/storage/concrete/Destroy()
	STORAGE_COMPONENT_GET_REAL_LOCATION
	for(var/atom/_A in real_location)
		_A.mouse_opacity = initial(_A.mouse_opacity)
	if(drop_all_on_destroy)
		do_quick_empty()
	for(var/i in slaves)
		var/datum/component/storage/slave = i
		slave.change_master(null)
	return ..()

/datum/component/storage/concrete/master()
	return src

/datum/component/storage/concrete/real_location()
	return parent

/datum/component/storage/concrete/OnTransfer(datum/new_parent)
	if(!isatom(new_parent))
		return COMPONENT_INCOMPATIBLE
	var/list/mob/_is_using = is_using.Copy()
	close_all()
	if(transfer_contents_on_component_transfer)
		var/atom/old = parent
		for(var/i in old)
			var/atom/movable/AM = i
			AM.forceMove(new_parent)
	for(var/i in _is_using)
		var/mob/M = i
		show_to(M)

/datum/component/storage/concrete/_insert_physical_item(obj/item/I, override = FALSE)
	. = TRUE
	STORAGE_COMPONENT_GET_REAL_LOCATION
	if(I.loc != real_location)
		I.forceMove(real_location)
	refresh_mob_views()

/datum/component/storage/concrete/refresh_mob_views()
	. = ..()
	for(var/i in slaves)
		var/datum/component/storage/slave = i
		slave.refresh_mob_views()

/datum/component/storage/concrete/emp_act(severity)
	STORAGE_COMPONENT_GET_REAL_LOCATION
	for(var/i in real_location)
		var/atom/A = i
		A.emp_act(severity)

/datum/component/storage/concrete/proc/on_slave_link(datum/component/storage/S)
	if(S == src)
		return FALSE
	slaves += S
	return TRUE

/datum/component/storage/concrete/proc/on_slave_unlink(datum/component/storage/S)
	slaves -= S
	return FALSE

/datum/component/storage/concrete/proc/on_contents_del(atom/A)
	var/atom/real_location = parent
	if(A in real_location)
		usr = null
		remove_from_storage(A, null)

/datum/component/storage/concrete/proc/on_deconstruct(disassembled)
	if(drop_all_on_deconstruct)
		do_quick_empty()

/datum/component/storage/concrete/can_see_contents()
	. = ..()
	for(var/i in slaves)
		var/datum/component/storage/slave = i
		. |= slave.can_see_contents()

/datum/component/storage/concrete/remove_from_storage(atom/movable/AM, atom/new_location)
	//Cache this as it should be reusable down the bottom, will not apply if anyone adds a sleep to dropped
	//or moving objects, things that should never happen
	STORAGE_COMPONENT_GET_PARENT_ATOM
	var/list/seeing_mobs = can_see_contents()
	for(var/mob/M in seeing_mobs)
		M.client.screen -= AM
	if(ismob(parent.loc) && isitem(AM))
		var/obj/item/I = AM
		var/mob/M = parent.loc
		I.dropped(M)
	if(new_location)
		AM.forceMove(new_location)
		//Reset the items values
		AM.layer = initial(AM.layer)
		AM.plane = initial(AM.plane)
		AM.mouse_opacity = initial(AM.mouse_opacity)
		if(AM.maptext)
			AM.maptext = ""
		//We don't want to call this if the item is being destroyed
		AM.on_exit_storage(src)
	else
		//Being destroyed, just move to nullspace now (so it's not in contents for the icon update)
		AM.moveToNullspace()
	refresh_mob_views()
	if(isobj(parent))
		var/obj/O = parent
		O.update_icon()
	return TRUE

/datum/component/storage/concrete/proc/slave_can_insert_object(datum/component/storage/slave, obj/item/I, stop_messages = FALSE, mob/M)
	return TRUE

/datum/component/storage/concrete/proc/handle_item_insertion_from_slave(datum/component/storage/slave, obj/item/I, prevent_warning = FALSE, M)
	. = handle_item_insertion(I, prevent_warning, M, slave)
	if(. && !prevent_warning)
		slave.mob_item_insertion_feedback(usr, M, I)

/datum/component/storage/concrete/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)		//Remote is null or the slave datum
	STORAGE_COMPONENT_GET_MASTER_STORAGE
	STORAGE_COMPONENT_GET_PARENT_ATOM
	if(!istype(I))
		return FALSE
	if(M && !M.temporarilyRemoveItemFromInventory(I))
		return FALSE
	if(I.pulledby)
		I.pulledby.stop_pulling()
	if(!_insert_physical_item(I))
		return FALSE
	I.on_enter_storage(master)
	refresh_mob_views()
	I.mouse_opacity = MOUSE_OPACITY_OPAQUE //So you can click on the area around the item to equip it, instead of having to pixel hunt
	if(M)
		if(M.client && M.active_storage != src)
			M.client.screen -= I
		if(M.observers && M.observers.len)
			for(var/i in M.observers)
				var/mob/dead/observe = i
				if(observe.client && observe.active_storage != src)
					observe.client.screen -= I
		if(!remote)
			parent.add_fingerprint(M)
			mob_item_insertion_feedback(usr, M, I)
	update_icon()
	return TRUE

/datum/component/storage/concrete/update_icon()
	if(isobj(parent))
		var/obj/O = parent
		O.update_icon()
	for(var/i in slaves)
		var/datum/component/storage/slave = i
		slave.update_icon()
