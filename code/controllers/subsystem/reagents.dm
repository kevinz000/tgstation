
SUBSYSTEM_DEF(reagents)
	flags = SS_NO_FIRE

	var/list/reagents_by_type = list()			//type = reagent datum
	var/list/reactions_by_type = list()			//type = reaction datum

	var/list/reactions_by_reagent_type = list()

/datum/controller/subsystem/reagents/Initialize()
	initialize_reagents(TRUE)
	initialize_reactions(TRUE)
	generate_reaction_reagent_list()
	return ..()

/datum/controller/subsystem/reagents/proc/initialize_reagents(clear_all = FALSE)
	if(clear_all)
		reagents_by_type = list()
	else
		LAZYINITLIST(reagents_by_type)

	var/list/paths = subtypesof(/datum/reagent)

	for(var/i in paths)
		var/datum/reagent/D = new i
		reagents_by_type[i] = D

/datum/controller/subsystem/reagents/proc/initialize_reactions(clear_all = FALSE)
	if(clear_all)
		reactions_by_type = list()
	else
		LAZYINITLIST(reactions_by_type)

	var/list/paths = subtypesof(/datum/chemical_reaction)

	for(var/i in paths)
		var/datum/chemical_reaction/D = new i
		reactions_by_type[i] = D

/datum/controller/subsystem/reagents/proc/generate_reaction_reagent_list()
	reactions_by_reagent_type = list()

	for(var/id in reactions_by_type)
		var/datum/chemical_reaction/D = reactions_by_type[id]

		if(D.required_reagents && D.required_reagents.len)
			for(var/trigger_type in D.required_reagents)
				LAZYADD(reactions_by_reagent_type[trigger_type], D)
				break //Don't bother adding ourselves to other reagent ids, it is redundant
