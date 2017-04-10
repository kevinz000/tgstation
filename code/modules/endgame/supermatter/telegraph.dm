
/datum/universal_state/cascade/proc/telegraph_cascade()
	for(var/mob/M in world)
		if(M.ckey || (M in player_list))
			to_chat(M, "<span class='userdanger'>A horrible silence overcomes you, as your ears start unbearably ringing!</span>")
			M.Weaken(10)
			M.flash_act()
			M.Deafen(10)
			M << sound(null)
		else
			M.visible_message("<span class='warning'>[M] shudders violently as a piercing white fills their body, and falls limp...</span>")
			M.death()
		CHECK_TICK
	setMobColors()
	if(starting_turf)
		empulse(start_turf, 50, 250)

