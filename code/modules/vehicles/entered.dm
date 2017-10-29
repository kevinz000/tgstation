
/obj/vehicle/entered
	var/enter_delay = 20

/obj/vehicle/entered/MouseDrop_T(atom/dropping, mob/M)
	if(M == dropping)
		mob_try_enter(M)

/obj/vehicle/entered/proc/mob_try_enter(mob/M)
	if(do_after(M, get_enter_delay(M), FALSE, src, TRUE))
		mob_enter(M)
		return TRUE
	return FALSE

/obj/vehicle/entered/proc/get_enter_delay(mob/M)
	return enter_delay

/obj/vehicle/entered/proc/mob_enter(mob/M, silent = FALSE)
	if(!silent)
		M.visible_message("<span class='boldnotice'>[M] climbs into \the [src]!</span>")
	M.forceMove(src)
	add_occupant(M)
	return TRUE

/obj/vehicle/entered/proc/mob_exit(mob/M, silent = FALSE)
	remove_occupant(M)
	M.forceMove(exit_location(M))
	if(!silent)
		M.visible_message("<span class='boldnotice'>[M] drops out of \the [src]!</span>")
	return TRUE

/obj/vehicle/entered/proc/exit_location(M)
	return drop_location()







