
/datum/field
	var/state = null
	var/list/turf/field_turfs = list()
	var/list/turf/currentrun_turfs = list()
	var/list/turf/field_edgeturfs = list()
	var/list/turf/currentrun_edgeturfs = list()
	var/list/turf/field_turfs_setup = list()
	var/list/turf/field_edgeturfs_setup = list()
	var/list/turf/field_turfs_cleanup = list()
	var/list/turf/field_edgeturfs_cleanup = list()
	var/turf_process = FALSE
	var/edgeturf_process = FALSE
	var/general_process = FALSE
	var/turf/center = null
	var/field_radius_type = null
	var/field_radius_1 = null
	var/field_radius_2 = null
	var/list/field_custom_turfs = null
	var/list/field_custom_edgeturfs = null
	var/cleaned_up = FALSE

/datum/field/proc/process_turf(turf/T)
	return

/datum/field/proc/process_edgeturf(turf/T)
	return

/datum/field/proc/process_general()
	return

/datum/field/proc/setup_turf(turf/T, new_setup = FALSE)
	T.fields += src
	return

/datum/field/proc/setup_edgeturf(turf/T, new_setup = FALSE)
	T.fields += src
	return

/datum/field/proc/cleanup_turf(turf/T, new_setup = FALSE)
	T.fields += src
	return

/datum/field/proc/cleanup_edgeturf(turf/T, new_setup = FALSE)
	T.fields += src
	return

/datum/field/proc/pause()
	if(state == FIELD_STATE_ACTIVE)
		state = FIELD_STATE_PAUSED

/datum/field/proc/resume()
	if(state = FIELD_STATE_PAUSED)
		state = FIELD_STATE_ACTIVE

//IF THE TYPE IS BLOCK, MAKE SURE RADIUS1 IS THE UPPER LEFT TURF AND RADIUS2 IS THE BOTTOM RIGHT TURF!!!
//MultiZ fields supported with CUSTOM and BLOCK.
/proc/field(type, turf/epicenter, radius_type, radius1 = null, radius2 = null, list/turf/turfs = list(), list/turf/edgeturfs = list(), duration = -1)
	new type(epicenter, radius_type, radius1, radius2, turfs, edgeturfs, duration)

/datum/field/proc/move_field(turf/new_center)
	recalculate_area(new_center, field_radius_type, field_radius_1, field_radius_2, field_custom_turfs, field_custom_edgeturfs, TRUE)

/datum/field/proc/recalculate_area(turf/epicenter, radius_type, radius1 = null, radius2 = null, list/turf/turfs = list(), list/turf/edgeturfs = list(), moving = FALSE)
	var/list/turf/oldturfs = list()
	var/list/turf/oldedgeturfs = list()
	var/list/turf/affected = list()
	var/list/turf/affected_innerturfs = list()
	var/list/turf/affected_edgeturfs = list()
	if((state != FIELD_STATE_SETUP) && moving)
		oldturfs = field_turfs.Copy()
		oldedgeturfs = field_edgeturfs.Copy()
	if(!istype(epicenter))
		return FALSE
	if(!isnull(radius1))
		if(radius1 <= 0)
			return FALSE
	if(!isnull(radius2))
		if(radius2 <= 0)
			return FALSE
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
			var/turf/radius1T = radius1
			var/turf/radius2T = radius2
			if((radius1T.x > radius2T.x)||(radius1T.y < radius2T.y))
				return FALSE
			affected = block(radius1T, radius2T)
			affected_innerturfs = block(locate((radius1T.x + 1), (radius1T.y - 1), (radius1T.z)), locate((radius2T.x - 1), (radius2T.y + 1), (radius2T.z)))
	if(radius_type != FIELD_RADIUS_CUSTOM)
		affected_edgeturfs = affected - affected_innerturfs
	else
		affected_edgeturfs = edgeturfs
	field_turfs = affected
	field_edgeturfs = affected_edgeturfs
	field_radius_type = radius_type
	field_radius_1 = radius1
	field_radius_2 = radius2
	field_custom_turfs = turfs
	field_custom_edgeturfs = edgeturfs
	if((state != FIELD_STATE_SETUP) && moving)
		field_turfs_cleanup = oldturfs - field_turfs
		field_edgeturfs_cleanup = oldedgeturfs - field_edgeturfs
		field_turfs_setup = field_turfs - oldturfs
		field_edgeturfs_setup = field_edgeturfs - oldedgeturfs

/datum/field/New(turf/epicenter, radius_type, radius1 = null, radius2 = null, list/turf/turfs = list(), list/turf/edgeturfs = list(), duration = -1)
	state = FIELD_STATE_SETUP
	recalculate_area(epicenter, radius_type, radius1, radius2, turfs, edgeturfs)
	field_turfs_setup = field_turfs
	field_edgeturfs_setup = field_edgeturfs
	if(SSfields)
		SSfields.new_field(src)
	if(duration != -1)
		QDEL_IN(src, duration)

/datum/field/Destroy()
	if(state != FIELD_STATE_CLEANUP)
		state = FIELD_STATE_CLEANUP
		field_turfs_cleanup = field_turfs + field_turfs_setup
		field_edgeturfs_cleanup = field_edgeturfs + field_edgeturfs_setup
		field_turfs_setup = list()
		field_edgeturfs_setup = list()
		if(SSfields)
			SSfields.destroy_field(src)
	if(cleaned_up)
		..()
