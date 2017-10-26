
#define VEHICLE_CONTROL_PERMISSION 1
#define VEHICLE_CONTROL_DRIVE 2

/obj/vehicle
	name = "generic vehicle"
	desc = "Yell at coderbus."
	icon = ''
	icon_state = ""
	var/list/mob/passengers		//LAZYLIST!
	var/list/mob/controllers	//mob = bitflags of their control level.
	var/movedelay = 2
	var/lastmove = 0
	var/canmove = TRUE

/obj/vehicle/relaymove(mob/user, direction)
	if(controllers[user] && (controllers[user] & VEHICLE_CONTROL_DRIVE]))
		return driver_move(user, direction)
	return FALSE

/obj/vehicle/proc/driver_move(mob/user, direction)
	if(lastmove + movedelay > world.time)
		return FALSE
	lastmove = world.time
	return step(src, direction)

/obj/vehicle/add_control_flags(mob/controller, flags)
	if(!controllers[controller])
		controllers[controller] = flag
	else
		controllers[controller] |= flag
	return TRUE

/obj/vehicle/remove_control_flags(mob/controller, flags)
	if(!controllers[controller])
		return TRUE
	else
		controllers[controller] &= ~flags
		if(!controllers[controller])			//deadminned
			controllers -= controller
	return TRUE

