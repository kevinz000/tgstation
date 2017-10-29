
/obj/vehicle/ridden
	name = "ridden vehicle"
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = FALSE

/obj/vehicle/ridden/Moved()
	. = ..()
	process_occupant_offsets()
	process_occupant_layers()

/obj/vehicle/ridden/proc/process_occupant_offsets()

/obj/vehicle/ridden/proc/process_occupant_layers()

/obj/vehicle/ridden/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	return ..()
/////////////////////////////////////////
/obj/vehicle/ridden/post_buckle_mob(mob/living/M)
	add_occupant(M)
	return ..()

/obj/vehicle/user_buckle_mob(mob/living/M, mob/user, force = FALSE)
	if(user.incapacitated())
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density)
			if(A != src && A != M)
				return
	M.forceMove(get_turf(src))
	. = ..()
	after_buckle(M, force)
