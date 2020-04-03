/datum/component/storage
	/// How many rows our storage grid has
	var/rows = DEFAULT_STORAGE_ROWS
	/// How many columns our storage grid has
	var/columns = DEFAULT_STORAGE_COLUMNS

/obj/item
	/// The storage grid for us. Not always set, because we want to save memory.
	var/datum/grid/binary/storage_item/storage_grid
	/// The string we use to initialize the storage grid.
	var/storage_item_str

/**
  * Instantiate our storage_grid.
  * @params
  * - replace_existing: If this is TRUE, the existing storage grid will be reinitialized by our [storage_item_str].
  * 	There is no safety checks for if it has been modified. Probably don't use this in most cases.
  * - stack_tracing: instructs the grid to throw out stack traces if it isn't set up properly.
  * 	Probably useful for unit testing.
  */
/obj/item/proc/initialize_storage_grid(replace_existing, stack_tracing)
	if(storage_grid)		//we already have one
		//if replace existing is specified, reinitialize it
		if(replace_existing)
			storage_grid.initialize_from_string(storage_item_str(), stack_tracing)
		return
	storage_grid = new(null, null, storage_item_str(), stack_tracing)
	return storage_grid

/**
  * Auto GC's our storage_grid.
  * This will refuse if the grid has been manually modified.
  */
/obj/item/proc/clear_storage_grid()
	if(storage_grid.is_modified())
		return FALSE
	return TRUE

/obj/item/Destroy()
	. = ..()
	QDEL_NULL(storage_grid)

GLOBAL_LIST_INIT(cached_w_class_storage_grids, generate_w_class_storage_grids())

/proc/generate_w_class_storage_grids()
	var/datum/grid/binary/storage_item/tiny = new(1, 1)
	var/datum/grid/binary/storage_item/small = new(2, 2)
	var/datum/grid/binary/storage_item/normal = new(5, 5)
	var/datum/grid/binary/storage_item/bulky = new(5, 10)
	var/datum/grid/binary/storage_item/huge = new(7, 12)
	var/datum/grid/binary/storage_item/gigantic = new(9, 15)
	tiny.fill_with_ones()
	small.fill_with_ones()
	normal.fill_with_ones()
	bulky.fill_with_ones()
	huge.fill_with_ones()
	gigantic.fill_with_ones()
	. = list()
	.["[WEIGHT_CLASS_TINY]"] = tiny
	.["[WEIGHT_CLASS_SMALL]"] = small
	.["[WEIGHT_CLASS_NORMAL]"] = normal
	.["[WEIGHT_CLASS_BULKY]"] = bulky
	.["[WEIGHT_CLASS_HUGE]"] = huge
	.["[WEIGHT_CLASS_GIGANTIC]"] = gigantic

/**
  * Gets our storage grid, instantiating it if necessary.
  */
/obj/item/proc/get_storage_grid()
	return storage_grid || (w_class && GLOB.cached_w_class_storage_grids["[w_class]"]) || initialize_storage_grid()

/obj/item/dropped(mob/user, silent)
	. = ..()
	if(!ismob(loc) && !(SEND_SIGNAL(loc, COMSIG_CONTAINS_SIGNAL) & COMPONENT_CONTAINS_STORAGE))		//the current heuristics is that if we get dropped to the ground we're more likely to not instantly need our storage grid again.
		clear_storage_grid()

// Base class for item storage grids. This is just a normal binary grid.
/datum/grid/binary/storage_item

/**
  * Checks if we are modified for checks on if we should be garbage collected when unused.
  * Admins get a vv catch-all, so all they need to do is change one variable I guess.
  */
/datum/grid/binary/storage_item/proc/is_modified()
	return CHECK_BITFIELD(datum_flags, DF_VAR_EDITED)

/** Base class for storage master grids.
  * Its grid elements will be an item reference.
  * Keeps references for all items in it.
  */
/datum/grid/storage_master
	/// References to items stored inside it.
	var/list/obj/item/stored

/**
  * This proc purges an item from the grid.
  */
/datum/grid/storage_master/proc/remove_item(obj/item/I)
	stored -= I
	for(var/y in grid)
		for(var/x in y)
			if(grid[y][x] == I)
				grid[y][x] = null

/datum/grid/storage_master/can_place_at_point(their_value, our_value, datum/grid/them, their_x, their_y, our_x, our_y)
	if(our_value != null)
		return FALSE
	return TRUE
