//Used to process objects. Fires once every second.

var/datum/subsystem/SSEndgame
/datum/subsystem/endgame
	name = "Universal State"
	priority = 30
	flags = SS_KEEP_TIMING|SS_TICKER
	wait = 1

	var/list/datum/universal_state/processing = list()
	var/list/datum/universal_state/starting = list()
	var/list/datum/universal_state/current = list()
	var/list/datum/universal_state/cleaning_up = list()

/datum/subsystem/endgame/New()
	NEW_SS_GLOBAL(SSEndgame)

/datum/subsystem/endgame/Recover()
	if(istype(SSEndgame))
		processing = SSEndgame.processing
		starting = SSEndgame.starting
		current = SSEndgame.current
		cleaning_up = SSEndgame.cleaning_up

/datum/subsystem/endgame/fire()
	for(/datum/universal_state/A in starting)
		if(!A.starting)
			A.Start()
		if(A.started)
			current.Add(A)
			starting.Remove(A)
	for(/datum/universal_state/B in current)
		if(B.ending)
			cleaning_up.Add(B)
			current.Remove(B)
	for(/datum/universal_state/C in processing)
		C.processTick(wait)
	for(/datum/universal_state/D in cleaning_up)
		if(!D.ending)
			D.End()
		if(D.ended = TRUE)
			cleaning_up.Remove(D)
			processing.Remove(D)
			qdel(D)

/datum/subsystem/endgame/proc/addStateNow(datum/universal_state/state)
	var/adding = new state()
	adding.Start()
	starting.Add(adding)
	processing.Add(adding)

/datum/subsystem/endgame/proc/endState(datum/universal_state/state)
	if(!state in current)
		return FALSE
	state.Stop()
