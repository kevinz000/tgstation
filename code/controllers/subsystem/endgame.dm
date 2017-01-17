
var/datum/subsystem/endgame/SSEndgame
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
	if(istype(SSEndgame.processing))
		processing = SSEndgame.processing
	if(istype(SSEndgame.starting))
		starting = SSEndgame.starting
	if(istype(SSEndgame.current))
		current = SSEndgame.current
	if(istype(SSEndgame.cleaning_up))
		cleaning_up = SSEndgame.cleaning_up

/datum/subsystem/endgame/fire()
	for(var/datum/universal_state/A in starting)
		if(!A.starting)
			A.Start()
		if(A.started)
			current.Add(A)
			starting.Remove(A)
	for(var/datum/universal_state/B in current)
		if(B.ending)
			cleaning_up.Add(B)
			current.Remove(B)
			for(var/datum/universal_state/E in current)
				E.setSpace()
	for(var/datum/universal_state/C in processing)
		C.processTick(wait)
	for(var/datum/universal_state/D in cleaning_up)
		if(!D.ending)
			D.End()
		if(D.ended = TRUE)
			cleaning_up.Remove(D)
			processing.Remove(D)
			qdel(D)

/datum/subsystem/endgame/proc/addState(datum/universal_state/state)
	var/datum/universal_state/adding = new state()
	adding.Start()
	starting.Add(adding)
	processing.Add(adding)

/datum/subsystem/endgame/proc/endState(datum/universal_state/state)
	if(!state in current)
		return FALSE
	state.Stop()
