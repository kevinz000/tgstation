//Stack-only storage.
/datum/component/storage/concrete/stack
	display_numerical_stacking = TRUE
	var/max_combined_stack_amount = 300

/datum/component/storage/concrete/stack/proc/total_stack_amount()
	. = 0
	STORAGE_COMPONENT_GET_REAL_LOCATION
	for(var/i in real_location)
		var/obj/item/stack/S = i
		if(!istype(S))
			continue
		. += S.amount

/datum/component/storage/concrete/stack/proc/remaining_space()
	return max(0, max_combined_stack_amount - total_stack_amount())

//emptying procs do not need modification as stacks automatically merge.

/datum/component/storage/concrete/stack/_insert_physical_item(obj/item/I, override = FALSE)
	if(!istype(I, /obj/item/stack))
		if(override)
			return ..()
		return FALSE
	STORAGE_COMPONENT_GET_REAL_LOCATION
	var/obj/item/stack/S = I
	var/can_insert = min(S.amount, remaining_space())
	for(var/i in real_location)				//combine.
		if(QDELETED(I))
			return
		var/obj/item/stack/_S = i
		if(!istype(_S))
			continue
		if(_S.merge_type == S.merge_type)
			_S.add(can_insert)
			S.use(can_insert, TRUE)
			return TRUE
	return ..(S.change_stack(null, can_insert), override)

/datum/component/storage/concrete/stack/remove_from_storage(obj/item/I, atom/new_location)
	STORAGE_COMPONENT_GET_REAL_LOCATION
	var/obj/item/stack/S = I
	if(!istype(S))
		return ..()
	if(S.amount > S.max_amount)
		var/overrun = S.amount - S.max_amount
		S.amount = S.max_amount
		var/obj/item/stack/temp = new S.type(real_location, overrun)
		handle_item_insertion(temp)
	return ..(S, new_location)

/datum/component/storage/concrete/stack/_process_numerical_display()
	STORAGE_COMPONENT_GET_REAL_LOCATION
	var/list/numbered_contents = list()
	for(var/i in real_location)
		var/obj/item/I = i
		if(!istype(I) || QDELETED(I))
			continue
		if(!istype(I, /obj/item/stack))
			continue
		var/obj/item/stack/S = I
		if(!numbered_contents[S.merge_type])
			numbered_contents[S.merge_type] = S.amount
		else										//If this code runs something's already wrong.
			var/datum/numbered_display/ND = numbered_contents[S.merge_type]
			ND.number += S.amount
	return numbered_contents
