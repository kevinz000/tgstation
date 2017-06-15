
/*
Stolen code from Baystation for purposes of projectile pathing. Doesn't actually calculate angle like it does in Baystation, this is just for incrementing steps.
*/

/datum/plot_vector
	var/angle = 0	// direction of travel in degrees
	var/initial_loc_p_x = 0
	var/initial_loc_p_y = 0
	var/initial_loc_z = 0
	var/loc_p_x = 0	// in pixels from the left edge of the map
	var/loc_p_y = 0	// in pixels from the bottom edge of the map
	var/loc_z = 0	// loc z is in world space coordinates (i.e. z level) - we don't care about measuring pixels for this
	var/offset_x = 0	// distance to increment each step
	var/offset_y = 0
	var/halt = FALSE	//Halts the thing to prevent a projectile's loop from progressing.
	var/increments = 0	//Number of increments
	var/speed = 1		//Don't use this unless you absolutely have to..

/datum/plot_vector/proc/setup_automatic(_angle, _x, _y, _z, _p_x, _p_y, paused = FALSE, _speed = 1)
	halt = paused
	// convert coordinates to pixel space (default is 32px/turf, 8160px across for a size 255 map)
	loc_p_x = _x * world.icon_size + _p_x
	loc_p_y = _y * world.icon_size + _p_y
	loc_z = _z

	initial_loc_p_x = loc_p_x
	initial_loc_p_y = loc_p_y
	initial_loc_z = loc_z

	angle = _angle
	speed = _speed

	recalculate_offsets()

/datum/plot_vector/proc/setAngle(newangle)
	angle = newangle
	recalculate_offsets()

/datum/plot_vector/proc/recalculate_offsets()

	offset_x = sin(angle)
	offset_y = cos(angle)

	// multiply the offset by the turf pixel size
	offset_x *= world.icon_size
	offset_y *= world.icon_size

	offset_x *= speed
	offset_y *= speed

/datum/plot_vector/proc/increment()
	if(halt)
		return FALSE
	loc_p_x += offset_x
	loc_p_y += offset_y
	increments++
	return TRUE

/datum/plot_vector/proc/return_distance()	//Distance in pixels
	var/x_o = loc_p_x - initial_loc_p_x
	var/y_o = loc_p_y - initial_loc_p_y
	return sqrt(x_o ** 2 + y_o ** 2)

/datum/plot_vector/proc/return_angle()
	return angle

/datum/plot_vector/proc/return_location(var/datum/vector_loc/data)
	if(!data)
		data = new()
	data.loc = locate(round(loc_p_x / world.icon_size, 1), round(loc_p_y / world.icon_size, 1), loc_z)
	if(!data.loc)
		return
	data.pixel_x = loc_p_x - (data.loc.x * world.icon_size)
	data.pixel_y = loc_p_y - (data.loc.y * world.icon_size)
	return data

/*
vector_loc is a helper datum for returning precise location data from plot_vector. It includes the turf the object is in
as well as the pixel offsets.

return_turf()
	Returns the turf the object should be currently located in.
*/
/datum/vector_loc
	var/turf/loc
	var/pixel_x
	var/pixel_y

/datum/vector_loc/proc/return_turf()
	return loc
