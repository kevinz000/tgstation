// File for grid datums I guess

/// A simple, base type of grid.
/datum/grid
	/**
	  * The actual grid, list of lists. List lengths will always be the same no laziness there.
	  * Items can be.. anything, really.
	  * The top of the grid is the highest index on the first list.
	  * the rightmost of the grid is the highest index on the second.
	  *
	  * IN TERMS OF X/Y: Y is rows, X is columns. Y = 1 is bottommost row, X = 1 is leftmost row.
	  *
	  */
	var/list/grid
	/// Size in rows so length(grid). Y coordinate.
	var/rows = 0
	/// Size in columns so length(grid[1]). X coordinate.
	var/columns = 0
	/// Our current.. "direction".
	var/dir = NORTH

/datum/grid/New(rows, columns, initialize_from_string)
	if(initialize_from_string)
		initialize_from_string(initialize_from_string)
	else if(rowS && columns)
		set_size(rows, columns)

/// Sets our size. If larger, any existing data is kept. If smaller, existing data is truncated.
/datum/grid/proc/set_size(rows, columns)
	LAZYINITLIST(grid)
	grid.len = rows
	for(var/i in 1 to rows)
		if(!islist(grid[i]))
			grid[i] = list()
		var/list/L = grid[i]
		L.len = columns

// Rotates clockwise by turns of 90 degrees.
/datum/grid/proc/rotate_clockwise(turns)
	turns %= 4
	if(!turns)		// why are you even calling the proc 4head
		return
	// If we ever add customizable placement points, here's where you'd turn it.
	// now for the actual rotation
	if(turns == 2)		//easy
		reverseRange(grid)
		for(var/i in 1 to length(grid))
			reverseRange(grid[i])
	else
		// meh, it isn't just north/south.
		// now i could do some complex thing to inplace this but
		// who cares, grids are already going to be a trainwreck performancewise
		// let's just make a new one and iterate
		var/list/ngrid = list()
		ngrid.len = columns
		for(var/i in ngrid)
			var/list/L = list()
			L.len = rows
			ngrid[i] = L
		// now that the list is made do the painstaking thing of iterating our list into it.
		if(turns == 1)
			for(var/y in 1 to rows)
				for(var/x in 1 to columns)
					ngrid[columns - x + 1][y] = grid[y][x]
		else		//turns == 3
			for(var/y in 1 to rows)
				for(var/x in 1 to columns)
					ngrid[x][rows - x + 1] = grid[y][x]
		// finally, update rows/columns.
		var/old = rows
		rows = columns
		columns = old

/// Point check for fit, much like value_to_write_on_placement_at_point
/datum/grid/proc/can_place_at_point(their_value, our_value, datum/grid/them, their_x, their_y, our_x, our_y)
	return // overridei n subtypes

/// See if a grid would physically fit on us at a certain x/y value based on its placement point.
/datum/grid/proc/can_fit_other(datum/grid/other, x, y)
	var/list/point_of_reference = other.get_placement_point()
	var/their_rows = other.rows
	var/their_columns = other.columns
	var/por_x = point_of_reference[1]
	var/por_y = point_of_reference[2]
	// get effective x/y, which is then the lower left coordinate of where we'd place 'em.
	var/effective_x = x - por_x + 1
	var/effective_y = y - por_y + 1
	// check fit.
	if(!ISINRANGE(effective_x, 1, columns) || !ISINRANGE(effective_y, 1, rows))
		return FALSE
	return TRUE

/// Get the point of reference when we do default placement checks (so if we give x/y this is the point on THIS grid that the x/y on the grid we're trying to place on corrosponds to). Returns list(x, y)
/datum/grid/proc/get_placement_point()
	return list(1, 1)		//bottom left until someone whips up another implementation and wants to make it customizable.

/// I suck at naming procs - This is to determine what we write on our grid when we place a point of another grid on us. This is called on the RECEIVING grid!
/datum/grid/proc/value_to_write_on_placement_at_point(their_value, our_value, datum/grid/them, their_x, their_y, our_x, our_y)
	return // yeah we're not going to bother implementing. doing it on subtypes.

/// Initialize the grid from a string.
/datum/grid/proc/initialize_from_string(str)
	return // Not implemented on base /grid.

/** Checks if we can place another grid on us at the specified point.
  * Returns GRID_CAN_PLACE, GRID_DOES_NOT_FIT, or GRID_VALUE_BLOCKED
  */
/datum/grid/proc/check_placement_conflicts(datum/grid/other, x, y)
	if(!can_fit_other(other, x, y))
		return GRID_DOES_NOT_FIT
	var/list/point_of_reference = other.get_placement_point()
	var/offset_x = x - point_of_reference[1]
	var/offset_y = y - point_of_reference[2]
	// Now check values.
	for(var/ty in 1 to other.rows)
		for(var/tx in 1 to other.columns)
			var/tvalue = other.grid[ty][tx]
			var/ox = tx + offset_x
			var/oy = ty + offset_y
			var/ovalue = grid[oy][ox]
			if(!can_place_at_point(tvalue, ovalue, other, tx, ty, ox, oy))
				return GRID_VALUE_BLOCKED
	return GRID_CAN_PLACE

/**
  * An iterator that returns a whole lot of lists because.. why not.
  * I wish we had actual iterators I guess?
  * Iterates left to right, bottom to up in that order.
  * Don't know why you'd use this I guess, pretty un-performant
  * Sigh.
  *
  * returns list(value, x, y)
  */
/datum/grid/proc/iterate()
	. = list()
	for(var/y in 1 to rows)
		for(var/x in 1 to columns)
			. += list(grid[y][x], x, y)

/** Places a grid at a location. No safety checks other than GRID_DOES_NOT_FIT, do check_placement_conflicts() yourself beforehand.
  * If it can't physically fit you get a crash for your troubles.
  */
/datum/grid/proc/do_place_grid(datum/grid/other, x, y)
	if(!can_fit_other(other, x, y))		// we can't ignore no-fit errors.
		CRASH("WARNING: do_place_grid called but can_fit_other failed. This usually means someone didn't check placement themselves and are trying to rely on this to do it for them. Don't do this!")
	var/list/point_of_reference = other.get_placement_point()
	var/offset_x = x - point_of_reference[1]
	var/offset_y = y - point_of_reference[2]
	for(var/ty in 1 to other.rows)
		for(var/tx in 1 to other.columns)
			var/tvalue = other.grid[ty][tx]
			var/ox = tx + offset_x
			var/oy = ty + offset_y
			var/ovalue = grid[oy][ox]
			var/nvalue = value_to_write_on_placement_at_point(tvalue, ovalue, other, tx, ty, ox, oy)
			grid[oy][ox] = nvalue
