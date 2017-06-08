
//Intended for pathfinding operations like AStar

PROCESSING_SUBSYSTEM_DEF(pathing)
	name = "Pathfinding"
	wait = 1
	priority = 80		//No one cares about laggy pathfinding!
	stat_tag = "PF"
	runlevels = ALL

/datum/controller/subsystem/processing/pathing
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(thing)
			thing.process(wait)
		else
			processing -= thing
		if (MC_TICK_CHECK)
			return

