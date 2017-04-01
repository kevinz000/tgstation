
/datum/beamline


	var/recalculation_delay = 2

	var/can_merge = TRUE	//Merge with other beams of the same type

	var/image/beam_image
	var/image/beam_hit_image


	//ACTUAL BEAM
	//STATIC VARIABLES
	var/turf/starting_point = null
	var/starting_direction = null

	//DYNAMICALLY RECALCULATED VARIABLES
	var/list/turf/beam_turfs = list()
	var/atom/hit = null
	var/list/atom/pierced_atoms = list()
	var/list/atom/passed_atoms = list()

/datum/beamline/New()
	..()

/datum/beamline/process()

/datum/beamline/proc/check_turf_hit(turf/T)
	if(isclosedturf(T))
		return TRUE
	return FALSE

/datum/beamline/proc/check_pass(atom/A)
	return FALSE

/datum/beamline/proc/check_pierce(atom/A)
	return FALSE

/datum/beamline/proc/apply_overlays(list/turf/apply)
	if(!isnull(beam_image))
		for(var/turf/T in apply)
			T.add_overlay(beam_image)

/datum/beamline/proc/remove_overlays(list/turf/remove)
	for(var/turf/T in remove)
		T.cut_overlay(beam_image)

/datum/beamline/proc/process_hit(atom/A)

/datum/beamline/proc/process_pierce(atom/A)

/datum/beamline/proc/process_pass(atom/A)



