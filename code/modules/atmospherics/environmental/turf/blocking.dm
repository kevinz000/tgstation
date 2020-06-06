/atom/var/CanAtmosPass = ATMOS_PASS_YES
/atom/var/CanAtmosPassVertical = ATMOS_PASS_YES

/atom/proc/CanAtmosPass(turf/T)
	switch (CanAtmosPass)
		if (ATMOS_PASS_PROC)
			return ATMOS_PASS_YES
		if (ATMOS_PASS_DENSITY)
			return !density
		else
			return CanAtmosPass

/turf/CanAtmosPass = ATMOS_PASS_NO
/turf/CanAtmosPassVertical = ATMOS_PASS_NO

/turf/open/CanAtmosPass = ATMOS_PASS_PROC
/turf/open/CanAtmosPassVertical = ATMOS_PASS_PROC

/turf/open/CanAtmosPass(turf/T, vertical = FALSE)
	var/dir = vertical? get_dir_multiz(src, T) : get_dir(src, T)
	var/opp = dir_inverse_multiz(dir)
	var/R = FALSE
	if(vertical && !(zAirOut(dir, T) && T.zAirIn(dir, src)))
		R = TRUE
	if(blocks_air || T.blocks_air)
		R = TRUE

	for(var/obj/O in contents+T.contents)
		var/turf/other = (O.loc == src ? T : src)
		if(!(vertical? (CANVERTICALATMOSPASS(O, other)) : (CANATMOSPASS(O, other))))
			R = TRUE
			if(O.BlockSuperconductivity()) 	//the direction and open/closed are already checked on CanAtmosPass() so there are no arguments
				atmos_supeconductivity |= dir
				T.atmos_supeconductivity |= opp
				return FALSE						//no need to keep going, we got all we asked

	atmos_supeconductivity &= ~dir
	T.atmos_supeconductivity &= ~opp

	return !R

/atom/movable/proc/BlockSuperconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return FALSE

