
/datum/universal_state
	var/name = "All Systems Nominal"
	var/desc = "Everything's fine, go back to work."

	var/delay_init = 0
	var/delay_telegraph = 0
	var/delay_begin = 0
	var/delay_process = 1
	var/delay_end = 0
	var/delay_close = 0
	var/delay_reset = 0
	var/processTick = 1
	var/process = FALSE

	var/no_shuttle = FALSE
	var/force_shuttle = FALSE
	var/force_shuttle_timer = 0
	var/force_shuttle_reason = ""
	var/force_shuttle_recall = FALSE
	var/forced_shuttle = FALSE

	var/starting = FALSE
	var/started = FALSE
	var/ending = FALSE
	var/ended = FALSE

/datum/universal_state/New()
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
		SSshuttle.hostile_environments += (src)
		SSshuttle.emergency.cancel(null)

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
		SSshuttle.hostile_environments -= (src)
	if(force_shuttle && forced_shuttle && force_shuttle_recall)
		SSshuttle.emergency.cancel(null)

/datum/universal_state/proc/Reset()
	ending = FALSE
	ended = TRUE

/datum/universal_state/Destroy()
	..()

/datum/universal_state/proc/on_shuttle_call(mob/user)
	return TRUE
