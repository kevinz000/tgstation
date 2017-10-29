
/obj/vehicle/ridden
	name = "ridden vehicle"
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = FALSE
	var/requires_keys = FALSE
	var/key_type
	var/obj/item/key
	var/legs_required = 2
	var/arms_requires = 0	//why not?

/obj/vehicle/ridden/Moved()
	. = ..()
	process_occupant_offsets()
	process_occupant_layers()
	check_riders()

/obj/vehicle/ridden/proc/check_riders()
	for(var/mob/living/carbon/C in occupants)		//carp always get to ride scooters!
		if(C.get_num_legs() < legs_required || C.get_num_arms() < arms_required)
			if(unbuckle_mob(C))
				C.visible_message("<span class='warning'[C] falls off of [src]!</span>")

/obj/vehicle/ridden/proc/process_occupant_offsets()

/obj/vehicle/ridden/proc/process_occupant_layers()

/obj/vehicle/ridden/proc/reset_unbuckled_mob(mob/living/M)
	M.layer = initial(M.layer)
	M.pixel_x = initial(M.pixel_x)
	M.pixel_y = initial(M.pixel_y)

/obj/vehicle/ridden/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	reset_unbuckled_mob(M)
	return ..()

/obj/vehicle/ridden/post_buckle_mob(mob/living/M)
	add_occupant(M)
	return ..()

/obj/vehicle/driver_move(mob/user, direction)
	if(requires_keys && !istype(key, key_type))
		to_chat(user, "<span class='warning'>[src] has no key inserted!</span>")
		return FALSE
	return ..()

/obj/vehicle/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(user.incapacitated())
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density)
			if(A != src && A != M)
				return
	M.forceMove(get_turf(src))
	return ..()
