
/datum/universal_state/cascade/proc/good_end()
	restore_all_areas()

/datum/universal_state/cascade/proc/bad_end()
	scramble_all_areas()
	for(var/mob/living/L in mob_list)
		to_chat(L, "<span class='boldwarning'>You hear an unearthly ringing, and you feel... <i>light<i>!</span>")
		L.Weaken(20)
		INVOKE_ASYNC(GLOBAL_PROC, ./proc/shake_camera, L, 600, 0.2)
	addtimer(CALLBACK(src, .autoannounce, CASCADE_ANNOUNCEMENT_BAD_ENDING_1), CASCADE_ANNOUNCEMENT_BAD_ENDING_1_DELAY)
	addtimer(CALLBACK(src, .autoannounce, CASCADE_ANNOUNCEMENT_BAD_ENDING_2), CASCADE_ANNOUNCEMENT_BAD_ENDING_2_DELAY)
	addtimer(CALLBACK(src, .autoannounce, CASCADE_ANNOUNCEMENT_BAD_ENDING_3), CASCADE_ANNOUNCEMENT_BAD_ENDING_3_DELAY)
	addtimer(CALLBACK(src, .spawn_hostile_mobs), CASCADE_BAD_ENDING_HOSTILE_SPAWN_DELAY)
	addtimer(CALLBACK(src, .universe_end), CASCADE_UNIVERSE_END_DELAY)

/datum/universal_state/cascade/proc/universe_end()
	autoannounce(CASCADE_ANNOUNCEMENT_UNIVERSE_END)
	universe_end_handle_mobs()
	universe_end_handle_turfs()
	universe_end_handle_round()

/datum/universal_state/cascade/proc/universe_end_handle_round()
	//round end
	//generate report

/datum/universal_state/cascade/proc/universe_end_handle_mobs()
	var/list/mob/living/exposed = list()
	for(var/mob/living/L in mob_list)
		if(check_safe_area(L))
			continue
		if(!L.ckey)
			L.death()
			L.visible_message("<span class='boldwarning'>[L] bursts into a horrific explosion of particles!</span>")
		exposed += L
	to_chat(exposed, "<span class='userdanger'>You suddenly realize you see your life flashing by. You think of one last happy thought as the world disintegrates..</span>")
	exposed.dust()
	//TODO: SCREEN EFFECT FOR UNRAVELLING

/datum/universal_state/cascade/proc/universe_end_handle_turfs()
	var/image/destroyed = icon('icons/effects/effects.dmi', icon_state = "static_base")
	for(var/turf/T in block(world.maxx, world.maxy, world.maxz))
		T.add_overlay(destroyed)
		CHECK_TICK
