
#define FIELD_STATE_ACTIVE 1
#define FIELD_STATE_SETUP 2
#define FIELD_STATE_CLEANUP 3
#define FIELD_STATE_PAUSED 4

#define FIELD_RADIUS_SQUARE 1
#define FIELD_RADIUS_RECTANGE 2
#define FIELD_RADIUS_CUSTOM 3
#define FIELD_RADIUS_BLOCK 4

var/datum/subsystem/fields/SSfields

/datum/subsystem/fields
	name = "Fields"
	init_order = -70
	wait = 2
	priority = 50
	flags = SS_BACKGROUND|SS_KEEP_TIMING
	var/list/datum/field/processing = list()
	var/list/datum/field/currentrun = list()
	var/list/datum/field/setting_up = list()
	var/list/datum/field/cleaning_up = list()

/datum/subsystem/fields/New()
	NEW_SS_GLOBAL(SSfields)

/datum/subsystem/fields/Destroy()
	..()

/datum/subsystem/fields/proc/new_field(datum/field)
	setting_up += field

/datum/subsystem/fields/proc/destroy_field(datum/field)
	cleaning_up += field

/datum/subsystem/fields/fire(resumed = FALSE)
	if(!resumed)
		currentrun = processing.Copy()
		currentrun += setting_up
		currentrun += cleaning_up
		for(var/datum/field/F in processing)
			if(F.turf_process)
				F.currentrun_turfs = F.field_turfs.Copy()
			if(F.edgeturf_process)
				F.currentrun_edgeturfs = F.field_edgeturfs.Copy()
	while(currentrun.len)
		var/datum/field/F = currentrun[currentrun.len]
		if(F.state == FIELD_STATE_SETUP)
			while(F.field_edgeturfs_setup.len)
				var/turf/T = F.field_edgeturfs_setup[F.field_edgeturfs_setup.len]
				F.field_edgeturfs_setup.len--
				if(!istype(T))
					continue
				F.setup_edgeturf(T)
				if(MC_TICK_CHECK)
					return
			while(F.field_turfs_setup.len)
				var/turf/T = F.field_turfs_setup[F.field_turfs_setup.len]
				F.field_turfs_setup.len--
				F.setup_turf(T)
				if(MC_TICK_CHECK)
					return
			if(!F.field_edgeturfs_setup.len && !F.field_turfs_setup.len)
				processing += F
				setting_up -= F
				F.state = FIELD_STATE_ACTIVE
		else if(F.state == FIELD_STATE_CLEANUP)
			while(F.field_edgeturfs_cleanup.len)
				var/turf/T = F.field_edgeturfs_cleanup[F.field_edgeturfs_cleanup.len]
				F.field_edgeturfs_cleanup.len--
				if(!istype(T))
					continue
				F.cleanup_edgeturf(T)
				if(MC_TICK_CHECK)
					return
			while(F.field_turfs_cleanup.len)
				var/turf/T = F.field_turfs_cleanup[F.field_turfs_cleanup.len]
				F.field_turfs_cleanup.len--
				if(!istype(T))
					continue
				F.cleanup_edgeturf(T)
				if(MC_TICK_CHECK)
					return
			if(!F.field_edgeturfs_cleanup.len && !F.field_turfs_cleanup.len)
				F.cleaned_up = TRUE
				qdel(F)
				cleaning_up -= F
		else if(F.state == FIELD_STATE_ACTIVE)
			if(F.general_process && !(F.state == FIELD_STATE_PAUSED))
				F.process(wait)
			while(F.field_edgeturfs_setup.len)
				var/turf/T = F.field_edgeturfs_setup[F.field_edgeturfs_setup.len]
				F.field_edgeturfs_setup--
				if(!istype(T))
					continue
				F.setup_edgeturf(T, TRUE)
				if(MC_TICK_CHECK)
					return
			while(F.field_edgeturfs_cleanup.len)
				var/turf/T = F.field_edgeturfs_cleanup[F.field_edgeturfs_cleanup.len]
				F.field_edgeturfs_cleanup--
				if(!istype(T))
					continue
				F.cleanup_edgeturf(T, TRUE)
				if(MC_TICK_CHECK)
					return
			if(F.state != FIELD_STATE_PAUSED)
				while(F.currentrun_edgeturfs.len)
					var/turf/T = F.currentrun_edgeturfs[F.currentrun_edgeturfs.len]
					F.currentrun_edgeturfs--
					if(!istype(T))
						continue
					F.process_edgeturf(T)
					if(MC_TICK_CHECK)
						return
			while(F.field_turfs_setup.len)
				var/turf/T = F.field_turfs_setup[F.field_turfs_setup.len]
				F.field_turfs_setup--
				if(!istype(T))
					continue
				F.setup_turf(T, TRUE)
				if(MC_TICK_CHECK)
					return
			while(F.field_turfs_cleanup.len)
				var/turf/T = F.field_turfs_cleanup[F.field_turfs_cleanup.len]
				F.field_turfs_cleanup--
				if(!istype(T))
					continue
				F.cleanup_turf(T, TRUE)
				if(MC_TICK_CHECK)
					return
			if(F.state != FIELD_STATE_PAUSED)
				while(F.currentrun_turfs.len)
					var/turf/T = F.currentrun_turfs[F.currentrun_turfs.len]
					F.currentrun_turfs.len--
					if(!istype(T))
						continue
					F.process_turf(T)
					if(MC_TICK_CHECK)
						return
			currentrun.len--
			if(MC_TICK_CHECK)
				return

/datum/subsystem/fields/Recover()
	if(istype(SSfields.processing))
		processing = SSfields.processing
	if(istype(SSfields.currentrun))
		currentrun = SSfields.currentrun
	..()








