
/world/proc/SDQL3_qdel_datum(D)
	qdel(D)

/world/proc/SDQL_gen_vv_href(t)
	var/text = ""
	text += "<A HREF='?_src_=vars;[HrefToken()];Vars=[REF(t)]'>[REF(t)]</A>"
	if(istype(t, /atom))
		var/atom/a = t
		var/turf/T = a.loc
		var/turf/actual = get_turf(a)
		if(istype(T))
			text += ": [t] at turf [T] [COORD(T)]<br>"
		else if(a.loc && istype(actual))
			text += ": [t] in [a.loc] at turf [actual] [COORD(actual)]<br>"
		else
			text += ": [t]<br>"
	else
		text += ": [t]<br>"
	return text



/proc/SDQL3_get_all_from(types, list/locations)
	. = list()
	if(!locations)
		return list()
	if(!islist(locations))
		locations = list(locations)
	if(!islist(types))
		if(!ispath(types))
			return list()
		types = list(types)
	for(location in locations)
		for(var/i in types)
			if(ispath(i, /mob))
				for(var/mob/d in location)
					if(typecache[d.type])
						. += d
					CHECK_TICK
			else if(ispath(i, /turf))
				for(var/turf/d in location)
					if(typecache[d.type])
						. += d
					CHECK_TICK

			else if(ispath(i, /obj))
				for(var/obj/d in location)
					if(typecache[d.type])
						. += d
					CHECK_TICK

			else if(ispath(i, /area))
				for(var/area/d in location)
					if(typecache[d.type])
						. += d
					CHECK_TICK

			else if(ispath(i, /atom))
				for(var/atom/d in location)
					if(typecache[d.type])
						. += d
					CHECK_TICK
			else if(ispath(type, /datum))
				if(location == world)
					for(var/datum/d) //stupid byond trick to have it not return atoms to make this less laggy
						if(typecache[d.type])
							. += d
						CHECK_TICK
				else
					for(var/datum/d in location) //stupid byond trick to have it not return atoms to make this less laggy
						if(typecache[d.type])
							. += d
						CHECK_TICK
