
//Only supports one, designed to be used wtih supermatter cascades. Could be made better in the future.
var/datum/subsystem/endgame/SSEndgame
/datum/subsystem/endgame
	name = "Universal State"
	priority = 30
	flags = SS_KEEP_TIMING	//Not exactly high priority, but still not to be ignored.
	wait = 1

	var/datum/universal_state/current_state = null

/datum/subsystem/endgame/New()
	NEW_SS_GLOBAL(SSEndgame)

/datum/subsystem/endgame/Initialize()
	..()

/datum/subsystem/endgame/Recover()
	current_state = SSEndgame.current_state

/datum/subsystem/endgame/fire()
	current_state.process()

/datum/subsystem/endgame/proc/setCurrentState(datum/universal_state/state)
	if(current_state)
		current_state.End()
	current_state = state
	current_state.Setup()

/datum/subsystem/endgame/proc/endCurrentState()
	current_state.End()
