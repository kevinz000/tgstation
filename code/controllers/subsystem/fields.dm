
var/datum/subsystem/fields/SSfields

/datum/subsystem/fields
	name = "Fields"
	init_order = -70
	wait = 2
	priority = 50
	flags = SS_BACKGROUND|SS_KEEP_TIMING
	var/list/datum/field/processing = list()
	var/list/datum/field/currentrun = list()

/datum/subsystem/fields/New()
	NEW_SS_GLOBAL(SSfields)

/datum/subsystem/fields/Destroy()
	..()

/datum/subsystem/fields/fire(resumed = FALSE)
	if(!resumed)
		currentrun = processing.Copy()
		for(var/datum/field/F in processing)
			if(F.turf_process)
				F.currentrun_turfs = F.field_turfs.Copy()
			if(F.edgeturf_process)
				F.currentrun_edgeturfs = F.field_edgeturfs.Copy()
	while(currentrun.len)
		var/datum/field/F = currentrun[currentrun.len]
		if(F.general_process)
			F.process(wait)
		while(F.currentrun_edgeturfs.len)
			var/turf/T = F.currentrun_edgeturfs[F.currentrun_edgeturfs.len]
			F.process_edgeturf(T)
			F.currentrun_edgeturfs--
			if(MC_TICK_CHECK)
				return
		while(F.currentrun_turfs.len)
			var/turf/T = F.currentrun_turfs[F.currentrun_turfs.len]
			F.process_turf(T)
			F.currentrun_turfs.len--
			if(MC_TICK_CHECK)
				return
		currentrun.len--
		if(MC_TICK_CHECK)
			return

/datum/subsystem/fields/Recover()









