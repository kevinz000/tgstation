
#define CASCADE_BAD_ENDING 1
#define CASCADE_GOOD_ENDING 2

/datum/universal_state/cascade
	name = "Supermatter Cascade"
	desc = "An unknown reaction caused by a large mass of supermatter achieving critical energy and causing a resonance that unravels reality at the quantum level."
	delay_telegraph = 10
	delay_begin = 10
	delay_process = 1
	delay_end = 10
	delay_close = 10
	delay_reset = 10
	process = TRUE
	level = PRIORITY_UNIVERSE
	no_shuttle = TRUE
	set_space_overlay = TRUE
	overlay_space = image()
	shuttle_fail_message = ""
	var/ending = CASCADE_BAD_ENDING

/datum/universal_state/cascade/Initialize()
	for(var/mob/M in world)
		if(M.ckey || (M in player_list))
			M << "<span class='userdanger'>A horrible silence overcomes you, as your ears start unbearably ringing!</span>"
			M.Weaken(10)
		else
			M.visible_message("<span class='warning'>[M] shudders violently as a piercing white fills their body, and falls limp...</span>")
			M.death()
	..()

/datum/universal_state/proc/Start()
	addtimer(CALLBACK(src, .proc/Initialize), delay_init)
	addtimer(CALLBACK(src, .proc/Telegraph), (delay_init + delay_telegraph))
	addtimer(CALLBACK(src, .proc/Begin), (delay_init + delay_telegraph + delay_begin))
	starting = TRUE

/datum/universal_state/proc/Initialize()

/datum/universal_state/proc/Telegraph()
	if(force_shuttle)
		var/coefficient = force_shuttle_timer/SSshuttle.emergencyCallTime
		forced_shuttle = SSshuttle.emergency.request(null, coefficient, null, force_shuttle_reason, FALSE)
	if(no_shuttle)
		SSshuttle.registerHostileEnvironment(src)
		SSshuttle.emergency.cancel(null)
	addtimer(CALLBACK(src, .proc/setSpace), 0)

/datum/universal_state/proc/processTick(wait)
	if(!process)
		return FALSE
	processTick += wait
	if(processTick >= delay_process)
		process()

/datum/universal_state/process()

/datum/universal_state/proc/Begin()
	starting = FALSE
	started = TRUE

/datum/universal_state/proc/Stop()
	addtimer(CALLBACK(src, .proc/End), delay_end)
	addtimer(CALLBACK(src, .proc/Close), (delay_end + delay_close))
	addtimer(CALLBACK(src, .proc/Reset), (delay_end + delay_close + delay_reset))
	ending = TRUE

/datum/universal_state/proc/End()

/datum/universal_state/proc/Close()
	if(no_shuttle)
		SSshuttle.clearHostileEnvironment(src)
	if(force_shuttle && forced_shuttle && force_shuttle_recall)
		SSshuttle.emergency.cancel(null)

/datum/universal_state/proc/Reset()
	ending = FALSE
	ended = TRUE

/datum/universal_state/Destroy()
	..()

/datum/universal_state/proc/on_shuttle_call(mob/user)
	return TRUE

/datum/universal_state/proc/setSpace()
	for(var/datum/universal_state/A in SSEndgame.current)
		if(A.level < level)
			return FALSE	//We're being overridden by a threat of higher nature.
	if(!overlay_space)
		return FALSE
	for(var/turf/open/space/S in world)
		if(level = PRIORITY_STATION)
			if(S.z != 1)
				continue
		CHECK_TICK
		S.overlays += overlay_space
		changed_turfs += S
	spaceset = TRUE

/datum/universal_state/proc/resetSpace()
	if(!reset_space_on_end)
		return FALSE
	if(!spaceset)
		return FALSE
	for(var/turf/open/space/S in changed_turfs)
		CHECK_TICK
		S.overlays -= overlay_space
	spaceset = FALSE
