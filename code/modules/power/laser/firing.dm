
#define PTL_HITSCAN_PASS 0
#define PTL_HITSCAN_PIERCE 1
#define PTL_HITSCAN_HIT 2
#define PTL_HITSCAN_TURN 3

#define PTL_FULLPIERCE_NONE 0
#define PTL_FULLPIERCE_NORMAL 1
#define PTL_FULLPIERCE_NOHIT 2

#define PTL_HITSCAN_RETURN_ERROR 0
#define PTL_HITSCAN_RETURN_HIT 1
#define PTL_HITSCAN_RETURN_ZEDGE 2

/obj/machinery/power/PTL/proc/hitscan_beamline(var/turf/starting, beam_dir, generate_effects = TRUE, effect_type = null, effect_duration = null, full_pierce = FALSE)
	var/list/affected = list()
	var/hit = FALSE
	var/iterations_left = 1000
	affected["[NORTH]"] = list()
	affected["[SOUTH]"] = list()
	affected["[EAST]"] = list()
	affected["[WEST]"] = list()
	affected["RESULT"] = PTL_HITSCAN_RETURN_ERROR
	affected["HIT_ATOM"] = null
	affected["BEAM_EFFECT_LIST"] = list()
	affected["[beam_dir]"] += starting
	var/turf/scanning
	scanning = starting
	while(!hit)
		iterations_left--
		var/reflector_hit = FALSE
		if(iterations_left <= 0)
			break
		for(var/atom/A in scanning)
			if(!full_pierce)
				var/V = hitscan_check(A)
				if(V == PTL_HITSCAN_PASS)
					continue
				else if(V == PTL_HITSCAN_PIERCE)
					affected["[beam_dir]"] += A
					continue
				else if(V == PTL_HITSCAN_HIT)
					hit = TRUE
					affected["HIT_ATOM"] = A
					affected["RESULT"] = PTL_HITSCAN_RETURN_HIT
					continue
				else if(V == PTL_HITSCAN_TURN)
					reflector_hit = TRUE
			else if(full_pierce = PTL_FULLPIERCE_NORMAL)	//Full pierce - Add everything but space to affected
				if(!isspaceturf(A))
					affected["[beam_dir]"] += A
		if(((scanning.x < 5) || (scanning.x > (world.maxx - 5))) || ((scanning.y < 5) || (scanning.y > (world.maxy - 5))))	//ZLEVEL EDGE CHECK
			hit = TRUE
			affected["RESULT"] = PTL_HITSCAN_RETURN_ZEDGE
			continue
		if(reflector_hit)
			var/obj/structure/reflector/found_R = null
			for(var/obj/structure/reflector/R in scanning)
				found_R = R
				break
			beam_dir = hitscan_reflect(found_R, beam_dir)
		scanning = get_step(scanning, beam_dir)
		if(!isnull(effect_type))
			affected["BEAM_EFFECT_LIST"] += hitscan_effect(scanning, effect_type, beam_dir, effect_duration)
		CHECK_TICK
	return affected

/obj/machinery/power/PTL/proc/hitscan_check(var/atom/A)	//1 for passes, 0 for hit.
	if(isclosedturf(A))			//Mechanics still WIP
		return PTL_HITSCAN_HIT
	else if(ismovableatom(A))
		if(istype(A, /obj/structure/reflector))
			var/obj/structure/reflector/R = A
			if(R.can_reflect_PTL)
				return PTL_HITSCAN_TURN
		return PTL_HITSCAN_PIERCE
	else
		return PTL_HITSCAN_PASS

/obj/machinery/power/PTL/proc/hitscan_reflect(obj/structure/reflector/R, beam_dir)
	return R.get_reflection(R.dir, beam_dir)

/obj/machinery/power/PTL/proc/hitscan_effect(location, type, effect_dir, effect_duration)
	var/obj/effect/overlay/temp/PTL/E = new type(location, effect_duration)
	if(!istype(E))
		return null
	E.dir = effect_dir
	return E

#define PTL_TRACER 1	//Tracer beam, pierces through everything and shows trajectory.
#define PTL_PULSE 2		//Burst of damage
#define PTL_PRIMARY 3	//Primary firing, continuous effect application

/obj/machinery/power/PTL/proc/find_starting_turf()
	var/x_offset = laser_tile_x_offset["[dir]"]
	var/y_offset = laser_tile_y_offset["[dir]"]
	var/turf/T = get_turf(src)
	var/turf/starting = locate((T.x + x_offset), (T.y + y_offset), T.z)
	return starting

/obj/machinery/power/PTL/proc/fire_beam(direction, type = PTL_PRIMARY, power, effect_duration_override = null, fullpierce = PTL_FULLPIERCE_NONE)
	var/turf/T = find_starting_turf()
	var/effect_type = null
	switch(type)
		if(PTL_PRIMARY)
			effect_type = /obj/effect/overlay/temp/PTL/continuous
		if(PTL_PULSE)
			effect_type = /obj/effect/overlay/temp/PTL/pulse
		if(PTL_TRACER)
			effect_type = /obj/effect/overlay/temp/PTL/tracer
	var/list/impacted = hitscan_beamline(T, direction, TRUE, effect_type, effect_duration_override, fullpierce)
	var/result = null
	var/atom/direct_hit = null
	var/list/hit = list()
	for(var/V in impacted)
		if(V == "RESULT")
			result = impacted["RESULT"]
		if(V == "HIT_ATOM")
			direct_hit = impacted["HIT_ATOM"]
		else
			for(var/v in impacted[V])
				hit += v
				CHECK_TICK
	if(istype(direct_hit))
		switch(type)
			if(PTL_PRIMARY)
				primary_hit(power, direct_hit, TRUE)
			if(PTL_TRACER)
				tracer_hit(power, direct_hit, TRUE)
			if(PTL_PULSE)
				pulse_hit(power, direct_hit, TRUE)
	for(var/atom/A in hit)
		switch(type)
			if(PTL_PRIMARY)
				primary_hit(power, direct_hit)
			if(PTL_TRACER)
				tracer_hit(power, direct_hit)
			if(PTL_PULSE)
				pulse_hit(power, direct_hit)
		CHECK_TICK
	if(result == PTL_HITSCAN_RETURN_ZEDGE)
		on_zlevel_edge_hit(power)

/obj/machinery/power/PTL/proc/tracer_hit(power, atom/A, direct_hit = FALSE)
	if(isliving(A))
		var/mob/living/L = A
		L.adjustFireLoss(power/1000000)
		to_chat(L, "<span class='warning'>You are seared by the laser!</span>")


/obj/machinery/power/PTL/proc/pulse_hit(power, atom/A, direct_hit = FALSE)

/obj/machinery/power/PTL/proc/primary_hit(power, atom/A, direct_hit = FALSE)

/obj/machinery/power/PTL/proc/on_zlevel_edge_hit(power)
	transmit_power(power)

/obj/machinery/power/PTL/proc/check_station_impact(area_threshold = 2, turf_threshold = 75)
	var/list/affected = hitscan_beamline(starting = find_starting_turf(), beam_dir = dir, generate_effects = FALSE, full_pierce = PTL_FULLPIERCE_NOHIT)
	var/list/turf_matches = list()
	var/list/area_matches = list()
	for(var/V in affected)
		if(V == "RESULT")
			continue
		if(V == "HIT_ATOM")
			continue
		for(var/v in affected[V])
			if(isturf(v))
				var/turf/T = v
				if(!is_type_in_list(T.loc, the_station_areas))
					area_matches[T.loc] = TRUE
					turf_matches += T
	if((area_matches.len > area_threshold) || (turf_matches > turf_threshold))
		return TRUE
	return FALSE
