
#define VEHICLE_CONTROL_PERMISSION 1
#define VEHICLE_CONTROL_DRIVE 2

/obj/vehicle
	name = "generic vehicle"
	desc = "Yell at coderbus."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "fuckyou"
	max_integrity = 300
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 0, bomb = 30, bio = 0, rad = 0, fire = 60, acid = 60)
	density = TRUE
	anchored = FALSE
	var/list/mob/occupants				//mob = bitflags of their control level.
	var/movedelay = 2
	var/lastmove = 0
	var/canmove = TRUE
	var/emulate_door_bumps = TRUE	//when bumping a door try to make occupants bump them to open them.

/obj/vehicle/Initialize(mapload)
	. = ..()
	occupants = list()

/obj/vehicle/proc/is_occupant(mob/M)
	return !isnull(occupants[M])

/obj/vehicle/proc/add_occupant(mob/M, control_flags)
	if(!istype(M) || occupants[M])
		return FALSE
	occupants[M] = NONE
	add_control_flags(M, control_flags)
	return TRUE

/obj/vehicle/proc/remove_occupant(mob/M)
	if(!istype(M))
		return FALSE
	remove_control_flags(M, ALL)
	occupants -= M
	return TRUE

/obj/vehicle/relaymove(mob/user, direction)
	if(is_occupant(M) && (occupants[user] & VEHICLE_CONTROL_DRIVE]))
		return driver_move(user, direction)
	return FALSE

/obj/vehicle/proc/driver_move(mob/user, direction)
	vehicle_move(direction)

/obj/vehicle/proc/vehicle_move(direction)
	if(lastmove + movedelay > world.time)
		return FALSE
	lastmove = world.time
	return step(src, direction)

/obj/vehicle/add_control_flags(mob/controller, flags)
	if(!istype(controller))
		return FALSE
	occupants[controller] |= flags
	return TRUE

/obj/vehicle/remove_control_flags(mob/controller, flags)
	if(!istype(controller))
		return FALSE
	occupants[controller] &= ~flags
	return TRUE

/obj/vehicle/Collide(atom/movable/M)
	. = ..()
	if(emulate_door_bumps)
		if(istype(M, /obj/machinery/door) && has_buckled_mobs())
			for(var/m in occupants)
				M.CollidedWith(m)

