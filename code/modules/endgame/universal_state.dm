
#define UNIVERSAL_STATE_INACTIVE 0
#define UNIVERSAL_STATE_SETUP 1
#define UNIVERSAL_STATE_RUNNING 2
#define UNIVERSAL_STATE_ENDING 3
#define UNIVERSAL_STATE_ENDED 4

/datum/universal_state
	var/name = "All Systems Nominal"
	var/desc = "Everything's fine, go back to work."

	var/state = UNIVERSAL_STATE_INACTIVE

	var/setupTime = 0
	var/startTime = 0
	var/endTime = 0
	var/finishTime = 0

/datum/universal_state/proc/Setup()
	state = UNIVERSAL_STATE_SETUP
	setupTime = world.time

/datum/universal_state/proc/afterSetup()
	state = UNIVERSAL_STATE_RUNNING
	startTime = world.time

/datum/universal_state/process()

/datum/universal_state/proc/End()
	state = UNIVERSAL_STATE_ENDING
	endTime = world.time

/datum/universal_state/proc/afterEnd()
	state = UNIVERSAL_STATE_ENDED
	finishTime = world.time

/datum/universal_state/proc/getSetupDuration()
	if(state == UNIVERSAL_STATE_SETUP)
		return (world.time - setupTime)
	else
		return (startTime - setupTime)

/datum/universal_state/proc/getRunningDuration()
	if(state == UNIVERSAL_STATE_RUNNING)
		return (world.time - startTime)
	else
		return (endTime - startTime)

/datum/universal_state/proc/getEndingDuration()
	if(state == UNIVERSAL_STATE_ENDING)
		return (world.time - endTime)
	else
		return (finishTime - endTime)

/datum/universal_state/proc/processTurfOverlay(turf/T)
	return

/*


#define PRIORITY_UNIVERSE 1	//What levels of fucked are we?
#define PRIORITY_SOLAR 2
#define PRIORITY_STATION 3
#define PRIORITY_CLEAR 4

	var/delay_init = 0
	var/delay_telegraph = 0
	var/delay_begin = 0
	var/delay_process = 1
	var/delay_end = 0
	var/delay_close = 0
	var/delay_reset = 0
	var/processTick = 1
	var/process = FALSE
	var/level = PRIORITY_CLEAR

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

	var/set_space_overlay = FALSE
	var/reset_space_on_end = TRUE
	var/image/overlay_space = null
	var/spaceset = FALSE
	var/list/turf/changed_turfs = list()

	var/fluff_report_sound = 'sound/AI/attention.ogg'
	var/fluff_report_sender = "Central Command Report"
	var/fluff_report_title = "All Systems Nominal"
	var/fluff_message = "All systems nominal. Please return to work, and have a secure day."
	var/fluff_autoannounce = FALSe

	var/shuttle_fail_message = ""
/datum/universal_state/proc/Start()
	addtimer(CALLBACK(src, .proc/Initialize), delay_init)
	addtimer(CALLBACK(src, .proc/Telegraph), (delay_init + delay_telegraph))
	addtimer(CALLBACK(src, .proc/Begin), (delay_init + delay_telegraph + delay_begin))
	starting = TRUE

/datum/universal_state/proc/Initialize()
	if(set_space_overlay)
		setSpace()

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
	if(fluff_autoannounce)
		commandAnnounce(fluff_report_sender, fluff_report_title, fluff_message, fluff_report_sound)

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

/datum/universal_state/proc/commandAnnounce(sender, title, text, sound = 'sound/AI/attention.ogg')
	var/announcement
	announcement += "<h1 class='alert'>[html_encode(sender)]</h1>"
	announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	announcement += "<br>"
	for(var/mob/M in player_list)
		if(!isnewplayer(M) && !M.ear_deaf)
			M << announcement
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				M << sound(sound)
*/