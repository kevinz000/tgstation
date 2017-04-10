
#define CASCADE_NO_ENDING 0
#define CASCADE_BAD_ENDING 1
#define CASCADE_GOOD_ENDING 2

#define CASCADE_TIME_TO_UNRAVEL 9000
#define CASCADE_ANNOUNCEMENT_BAD_ENDING_1_DELAY 300
#define CASCADE_ANNOUNCEMENT_BAD_ENDING_2_DELAY 900
#define CASCADE_ANNOUNCEMENT_BAD_ENDING_3_DELAY 2400
#define CASCADE_BAD_ENDING_HOSTILE_SPAWN_DELAY 2800
#define CASCADE_UNIVERSE_END_DELAY 3600

#define CASCADE_ANNOUNCEMENT_BAD_ENDING_1 0
#define CASCADE_ANNOUNCEMENT_BAD_ENDING_2 1
#define CASCADE_ANNOUNCEMENT_BAD_ENDING_3 2
#define CASCADE_ANNOUNCEMENT_UNIVERSE_END 3

//ZK Class Reality Failure
/datum/universal_state/cascade
	name = "Supermatter Cascade"
	desc = "An unknown harmonance caused by a large mass of supermatter achieving critical energy and causing a resonance that unravels reality at the quantum level."
	var/ending = CASCADE_NO_ENDING

	var/mobVisionColor = "#000000"
	var/oldColorR = 0
	var/oldColorG = 0
	var/oldColorB = 0

	var/process_tick = 0
	var/screen_escalation_delay = 10

	var/turf/starting_turf = null

	var/cascade_time_to_unravel = CASCADE_TIME_TO_UNRAVEL
	var/cascade_time_to_end = (CASCADE_TIME_TO_UNRAVEL + CASCADE_UNIVERSE_END_DELAY)
	var/list/turf/scramble_overlay_applied
	var/obj/effect/bluespace_escape_rift/escape_rift = null
	var/list/mob/living/hostile_spawned_mobs

/datum/universal_state/cascade/Setup()
	scramble_overlay_applied = list()
	hostile_spawned_mobs = list()
	..()
	oldColorR = 12.8
	oldColorG = 25
	oldColorB = 25
	telegraph_cascade()

/datum/universal_state/cascade/process()
	process_tick++
	if(process_tick >= screen_escalation_delay)
		handleScreenEffects()
		//TODO: UNRAVEL OVERLAY THAT SLOWLY ESCALATES/SCREEN CRACKING.
	if(state != UNIVERSAL_STATE_RUNNING)
		return
	if(getRunningDuration() >= cascade_time_to_unravel)
		ending = CASCADE_BAD_ENDING
		End()

/datum/universal_state/cascade/End()
	if(ending == CASCADE_BAD_ENDING)
		bad_end()
	else if(ending == CASCADE_GOOD_ENDING)
		good_end()
	..()

/datum/universal_state/cascade/proc/check_safe_area(mob/living/L)
	return FALSE

/proc/start_supermatter_cascade(turf/starting = null)
	var/datum/universal_state/cascade/C = new /datum/universal_state/cascade
	C.starting_turf = starting
	SSEndgame.set_current_state(C)

/proc/stop_supermatter_cascade(endtype)
	if(isnull(endtype))
		endtype = CASCADE_NO_ENDING
	if(SSEndgame && SSEndgame.current_state)
		var/datum/universal_state/cascade/C = SSEndgame.current_state
		if(istype(C))
			C.ending = endtype
			SSEndgame.EndCurrentState()
