/mob/living/movespeed_ds(ignorewalk = 0)
	. = 0
	var/static/datum/config_entry/number/movespeed_base_run/config_runspeed
	var/static/datum/config_entry/number/movespeed_base_walk/config_walkspeed
	if(isnull(config_runspeed) || isnull(config_runspeed))
		config_runspeed = CONFIG_GET_DATUM(number/movespeed_base_run)
		config_walkspeed = CONFIG_GET_DATUM(number/movespeed_base_walk)
	if(ignorewalk)
		. += config_runspeed.value_cache
	else
		switch(m_intent)
			if(MOVE_INTENT_RUN)
				. += config_runspeed.value_cache
				if(drowsyness > 0)
					. *= 0.16666
			if(MOVE_INTENT_WALK)
				. += config_walkspeed.value_cache
	. *= movespeed_mod
	. += movespeed_adj
	if(isopenturf(loc) && !is_flying())
		var/turf/open/T = loc
		. *= T.turf_movespeed_mod
		. += T.turf_movespeed_adj
