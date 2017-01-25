
/proc/check_ckey_for_living_mob(ckey)
	for(var/mob/living/L in world)
		if(L.ckey == ckey)
			return TRUE
	return FALSE

/proc/check_ckey_conflict(ckey)
	if(!global.cross_allowed)
		return FALSE
	var/list/transmit = list()
	transmit["key"] = global.comms_key
	transmit["check_active_ckey"] = ckey
	return world.Export("[global.cross_address]?[list2params(transmit)]")

/proc/atom_cross_server(atom/A, newX, newY, newZ, ckey_override = TRUE)
	if(!global.cross_allowed)
		return FALSE
	var/ckeytocheck = "1"
	if(ismob(A))
		var/mob/M = A
		ckeytocheck = M.ckey
	var/list/transmit = list()
	transmit["key"] = global.comms_key
	transmit["atom_x"] = newX
	transmit["atom_y"] = newY
	transmit["atom_z"] = newZ
	transmit["atom_ckey_override"] = ckey_override
	transmit["cross_server_atom"] = make_savefile_from_atom(A)
	transmit["cross_server_ckey"] = ckeytocheck
	return world.Export("[global.cross_address]?[list2params(transmit)]")

/proc/make_savefile_from_atom(atom/A)
	var/savefile/F = new
	F["atom"] << A
	F["type"] << A.type
	F["x"] << A.x
	F["y"] << A.y
	F["z"] << A.z
	if(ismob(A))
		var/mob/M = A
		F["ckey"] = M.ckey
	return F

/proc/make_atom_from_savefile(savefile/F)
	var/atom/A = new F["type"](locate(F["x"],F["y"],F["z"]))
	F["atom"] >> A
	if(ismob(A))
		var/mob/M = A
		M.ckey = F["ckey"]
	return TRUE

/proc/savefiletest(atom/A, x,y,z)
	savefile_to_atom(atom_to_savefile(A),locate(x,y,z))

/proc/mob_to_savefile(mob/M)
	return FALSE	//Not supported

/proc/turf_to_savefile(turf/T)
	return FALSE	//Same

/proc/obj_to_savefile(obj/O)
	var/savefile/F = new
	F["saved_mode"] = "object"
	F["saved_atom"] << O
	F["saved_type"] = O.type
	F["saved_x"] = O.x
	F["saved_y"] = O.y
	F["saved_z"] = O.z
	return F

/proc/atom_to_savefile(atom/A)
	. = FALSE
	if(ismob(A))
		var/mob/M = A
		. = mob_to_savefile(A)
	if(istype(A, /turf))
		var/turf/T = A
		. = turf_to_savefile(T)
	if(isobj(A))
		var/obj/O = A
		. = obj_to_savefile(A)

/proc/savefile_to_atom(savefile/F, loc = null)
	var/type = F["saved_type"]
	if(!loc)
		loc = locate(F["saved_x"],F["saved_y"],F["saved_z"])
	if(F["saved_mode"] == "object")
		var/obj/O = new type(loc)
		F["saved_atom"] >> O
		return O
	return FALSE


