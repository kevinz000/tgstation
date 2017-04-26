
/datum/universal_state/cascade/proc/scramble_all_areas()
	for(var/area/A in world)
		if(istype(A, /area/space) || (A.z == 2))
			continue
		var/list/turf/turfs = list()
		for(var/turf/T in A.contents)
			turfs += T
		while(turfs.len >= 2)
			var/turf/T1 = pick_n_take(turfs)
			var/turf/T2 = pick_n_take(turfs)
			scramble_overlay_applied += T1
			scramble_overlay_aplpied += T2
			T1.add_overlay(T2.photograph())
			T2.add_overlay(T1.photograph())
			CHECK_TICK

/datum/universal_state/cascade/proc/restore_all_areas()
	for(var/turf/T in scramble_overlay_applied)
		T.overlays.Cut()
