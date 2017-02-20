
#define FIELD_STATE_ACTIVE 1
#define FIELD_STATE_SETUP 2
#define FIELD_STATE_CLEANUP 3
#define FIELD_STATE_PAUSED 4

#define FIELD_RADIUS_SQUARE 1
#define FIELD_RADIUS_RECTANGE 2
#define FIELD_RADIUS_CUSTOM 3
#define FIELD_RADIUS_BLOCK 4

/datum/field
	var/state = null
	var/turf/center = null
	var/list/turf/field_turfs = list()
	var/list/turf/currentrun_turfs = list()
	var/list/turf/field_edgeturfs = list()
	var/list/turf/currentrun_edgeturfs = list()
	var/turf_process = FALSE
	var/edgeturf_process = FALSE
	var/general_process = FALSE

/datum/field/proc/process_turf(turf/T)
	return

/datum/field/proc/process_edgeturf(turf/T)
	return

/datum/field/proc/process_general()
	return

/proc/field(type, turf/epicenter, radius_type, radius1 = null, radius2 = null, list/turf/turfs = list(), /list/turf/edgeturfs = list(), duration = -1)
	new type(epicenter, radius_type, radius1, radius2, turfs, edgeturfs, duration)

/datum/field/proc/New(turf/epicenter, radius_type, radius1 = null, radius2 = null, list/turf/turfs = list(), /list/turf/edgeturfs = list(), duration = -1)
	state = FIELD_STATE_SETUP
	var/list/turf/affected = list()
	var/list/turf/affected_edgeturfs = list()
	var/list/turf/affected_innerturfs = list()
	switch(radius_type)
		if(FIELD_RADIUS_SQUARE)
			if(isnull(radius1))
				return FALSE
			affected = block(locate((epicenter.x - radius1), (epicenter.y - radius1), (epicenter.z)), locate((epicenter.x + radius1), (epicenter.y + radius1), (epicenter.z)))
			affected_innerturfs = block(locate((epicenter.x - (radius1 - 1)), (epicenter.y - (radius1 - 1)), (epicenter.z)), locate((epicenter.x + (radius1 - 1)), (epicenter.y + (radius1 - 1)), (epicenter.z)))
		if(FIELD_RADIUS_RECTANGE)
			if(isnull(radius1) || isnull(radius2))
				return FALSE
			affected = block(locate((epicenter.x - radius1), (epicenter.y - radius2), (epicenter.z)), locate((epicenter.x + radius1), (epicenter.y + radius2), (epicenter.z)))
			affected_innerturfs = block(locate((epicenter.x - (radius1 - 1)), (epicenter.y - (radius2 - 1)), (epicenter.z)), locate((epicenter.x + (radius1 - 1)), (epicenter.y + (radius2 - 1)), (epicenter.z)))
		if(FIELD_RADIUS_CUSTOM)
			affected = turfs
			affected_innerturfs = turfs - edgeturfs
		if(FIELD_RADIUS_BLOCK)
			if(!isturf(radius1)||!isturf(radius2))
				return FALSE
			affected = block(radius1, radius2)
			affected_innerturfs = block(radius1
	if(radius_type != FIELD_RADIUS_CUSTOM)
		affected_edgeturfs = affected - affected_innerturfs
	else
		affected_edgeturfs = edgeturfs

	if(duration != -1)
		QDEL_IN(src, duration)



