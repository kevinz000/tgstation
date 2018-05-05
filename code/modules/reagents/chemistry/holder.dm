
/datum/reagents
	var/list/reagent_list = list()				//id = reagent datum
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/chem_temp = 150
	var/pH = REAGENT_NORMAL_PH
	var/last_tick = 1
	var/addiction_tick = 1
	var/list/addiction_list = list()						//id = reagent datum
	var/reagents_holder_flags

	var/last_process_tick = 0
	var/reaction_multiplier_overrun = 0
	var/current_reaction_cycle = 0

/datum/reagents/New(maximum=100)
	maximum_volume = maximum

/datum/reagents/Destroy()
	. = ..()
	QDEL_LIST_ASSOC_VAL(reagent_list)
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null
	my_atom = null

/datum/reagents/proc/start_reacting()
	if(isprocessing)
		return
	last_tick = world.time
	current_reaction_cycle = 0
	START_PROCESSING(SSreagents, src)

/datum/reagents/proc/stop_reacting()
	STOP_PROCESSING(SSreagents, src)

/datum/reagents/proc/set_reacting(react = TRUE)
	if(react)
		reagents_holder_flags &= ~(REAGENT_NOREACT)
		start_reacting()
	else
		reagents_holder_flags |= REAGENT_NOREACT
		stop_reacting()

/datum/reagents/process()
	var/diff = world.time - last_process_tick
	last_process_tick = world.time
	handle_reactions(diff * SSreagents.global_reaction_multiplier)

/datum/reagents/proc/handle_reactions(multiplier = 1)
	multiplier += reaction_multiplier_overrun		//add old overrun
	reaction_multiplier_overrun = MODULUS(multiplier, 1)		//store current overrun
	multiplier -= reaction_multiplier_overrun		//cut overrun

	for(var/i in 1 to multiplier)
		if(!react(++current_reaction_cycle))			//If returning false that means we've processed without a reaction happening, meaning we should be done.
			stop_reacting()
			break

/datum/reagents/proc/react(cycle)
	if(reagents_holder_flags & REAGENT_NOREACT)
		return //Yup, no reactions here. No siree.

	//Cache for hyper speed!
	var/datum/cached_my_atom = my_atom

	//Find what reactions we can do at the time of calculation
	var/list/possible_reactions = get_possible_reactions()

	//Do reactions
	var/reaction_occurred = FALSE
	var/continue_processing = FALSE
	do
		reaction_occurred = FALSE
		if(possible_reactions.len)
			var/datum/chemical_reaction/selected_reaction = possible_reactions[1]

			//select the reaction with the most extreme temperature requirements
			for(var/V in possible_reactions)
				var/datum/chemical_reaction/competitor = V
				if(selected_reaction.is_cold_recipe) //if there are no recipe conflicts, everything in possible_reactions will have this same value for is_cold_reaction. warranty void if assumption not met.
					if(competitor.required_temp < selected_reaction.required_temp)
						selected_reaction = competitor
				else
					if(competitor.required_temp > selected_reaction.required_temp)
						selected_reaction = competitor

			//Cache reaction variables
			var/list/cached_required_reagents = selected_reaction.required_reagents
			var/list/cached_results = selected_reaction.results

			//How many times the formula can be applied to us
			var/multiplier = INFINITY

			//Limit by available reactants
			for(var/B in cached_required_reagents)
				multiplier = min(multiplier, get_reagent_amount(B) / cached_required_reagents[B])

			//Limit by rate
			multiplier = min(multiplier, selected_reaction.get_reaction_rate())

			//React!
			for(var/B in cached_required_reagents)
				remove_reagent(B, (multiplier * cached_required_reagents[B]), safety = 1)

			for(var/P in selected_reaction.results)
				SSblackbox.record_feedback("tally", "chemical_reaction", cached_results[P]*multiplier, P)
				add_reagent(P, cached_results[P] * multiplier, null, chem_temp)

			WIP_TAG		//Find a better way to do this

			if(cycle == 1)
				var/list/seen = viewers(4, get_turf(my_atom))
				var/iconhtml = icon2html(cached_my_atom, seen)
				if(cached_my_atom)
					if(!ismob(cached_my_atom)) // No bubbling mobs
						if(selected_reaction.mix_sound)
							playsound(get_turf(cached_my_atom), selected_reaction.mix_sound, 80, 1)

						for(var/mob/M in seen)
							to_chat(M, "<span class='notice'>[iconhtml] [selected_reaction.mix_message]</span>")

					if(istype(cached_my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/ME2 = my_atom
						ME2.Uses--
						if(ME2.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in seen)
								to_chat(M, "<span class='notice'>[iconhtml] \The [my_atom]'s power is consumed in the reaction.</span>")
								ME2.name = "used slime extract"
								ME2.desc = "This extract has been used up."

			//Finalize
			selected_reaction.on_reaction(src, multiplier)
			reaction_occurred = TRUE
			continue_processing = TRUE

			//Don't react this again this cycle
			possible_reactions -= selected_reaction

	//Keep going as long as this cycle is still going
	while(reaction_occurred)

	//Update total
	update_total()

	//Report if we should continue reacting.
	return continue_processing

/datum/reagents/proc/get_possible_reactions()
	var/list/possible_reactions = list()
	var/list/cached_reagents = reagent_list
	var/atom/cached_my_atom = my_atom
	var/list/cached_reactions = SSreagents.reactions_by_reagent_id
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		for(var/reaction in cached_reactions[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id
			if(!reaction)
				continue

			var/datum/chemical_reaction/C = reaction
			var/list/cached_required_reagents = C.required_reagents
			var/total_required_reagents = cached_required_reagents.len
			var/total_matching_reagents = 0
			var/list/cached_required_catalysts = C.required_catalysts
			var/total_required_catalysts = cached_required_catalysts.len
			var/total_matching_catalysts= 0
			var/matching_container = FALSE
			var/matching_other = FALSE
			var/required_temp = C.required_temp
			var/is_cold_recipe = C.is_cold_recipe
			var/meets_temp_requirement = FALSE

			for(var/B in cached_required_reagents)
				if(!has_reagent(B))
					break
				total_matching_reagents++
			for(var/B in cached_required_catalysts)
				if(!has_reagent(B, cached_required_catalysts[B]))
					break
				total_matching_catalysts++
			if(cached_my_atom)
				if(!C.required_container)
					matching_container = TRUE

				else
					if(cached_my_atom.type == C.required_container)
						matching_container = TRUE
				if (isliving(cached_my_atom) && !C.mob_react) //Makes it so certain chemical reactions don't occur in mobs
					return
				if(!C.required_other)
					matching_other = TRUE

				else if(istype(cached_my_atom, /obj/item/slime_extract))
					var/obj/item/slime_extract/M = cached_my_atom

					if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
						matching_other = TRUE
			else
				if(!C.required_container)
					matching_container = TRUE
				if(!C.required_other)
					matching_other = TRUE

			if(required_temp == 0 || (is_cold_recipe && chem_temp <= required_temp) || (!is_cold_recipe && chem_temp >= required_temp))
				meets_temp_requirement = TRUE

			if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && meets_temp_requirement)
				possible_reactions += C
	return possible_reactions

// Used in attack logs for reagents in pills and such
/datum/reagents/proc/log_list()
	if(!length(reagent_list))
		return "no reagents"

	var/list/data = list()
	for(var/id in reagent_list) //no reagents will be left behind
		var/datum/reagent/R = reagent_list[id]
		data += "[R.id] ([round(R.volume, 0.001)]u)"
		//Using IDs because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)

/datum/reagents/proc/remove_any(amount = 1)
	var/list/cached_reagents = reagent_list
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1, cached_reagents.len)

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break
		if(total_volume <= 0 || !cached_reagents.len)
			break

		if(current_list_element > cached_reagents.len)
			current_list_element = 1

		var/id = cached_reagents[current_list_element]
		var/datum/reagent/R = cached_reagents[id]
		remove_reagent(R.id, 1)

		current_list_element++
		total_transfered++
		update_total()

	start_reacting()
	return total_transfered

/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/id in cached_reagents)
			var/datum/reagent/R = cached_reagents[id]
			remove_reagent(R.id, R.volume * part)

		update_total()
		start_reacting()
		return amount

/datum/reagents/proc/get_master_reagent_name()
	var/list/cached_reagents = reagent_list
	var/name
	var/max_volume = 0
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		if(R.volume > max_volume)
			max_volume = R.volume
			name = R.name

	return name

/datum/reagents/proc/get_master_reagent_id()
	var/list/cached_reagents = reagent_list
	var/found
	var/max_volume = 0
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		if(R.volume > max_volume)
			max_volume = R.volume
			found = R.id

	return found

/datum/reagents/proc/get_master_reagent()
	var/list/cached_reagents = reagent_list
	var/datum/reagent/master
	var/max_volume = 0
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		if(R.volume > max_volume)
			max_volume = R.volume
			master = R

	return master

/datum/reagents/proc/trans_to(obj/target, amount=1, multiplier=1, preserve_data=1, no_react = 0)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return
	if(amount < 0)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for(var/id in cached_reagents)
		var/datum/reagent/T = cached_reagents[id]
		var/transfer_amount = T.volume * part
		if(preserve_data)
			trans_data = copy_data(T)
		R.add_reagent(T.id, transfer_amount * multiplier, trans_data, chem_temp, pH, T.purity, no_react = TRUE) //we only handle reaction after every reagent has been transfered.
		remove_reagent(T.id, transfer_amount)

	update_total()
	R.update_total()
	if(!no_react)
		R.start_reacting()
		start_reacting()
	return amount

/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1)
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents

	if(amount < 0)
		return
	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/id in cached_reagents)
		var/datum/reagent/T = cached_reagents[id]
		var/copy_amount = T.volume * part
		if(preserve_data)
			trans_data = T.data
		R.add_reagent(T.id, copy_amount * multiplier, trans_data, chem_temp, pH, T.purity, no_react = TRUE)

	update_total()
	R.update_total()
	R.start_reacting()
	start_reacting()
	return amount

/datum/reagents/proc/trans_id_to(obj/target, reagent, amount=1, preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	var/list/cached_reagents = reagent_list
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return
	if(amount < 0)
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for(var/id in cached_reagents)
		var/datum/reagent/current_reagent = cached_reagents[id]
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.id, amount, trans_data, src.chem_temp, pH, current_reagent.purity, no_react = TRUE)
			remove_reagent(current_reagent.id, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.start_reacting()
	return amount

/datum/reagents/proc/metabolize(mob/living/carbon/C, can_overdose = FALSE, liverless = FALSE)
	var/list/cached_reagents = reagent_list
	var/list/cached_addictions = addiction_list
	if(C)
		expose_temperature(C.bodytemperature, 0.25)
	var/need_mob_update = 0
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		if(QDELETED(R.holder))
			continue
		if(liverless && !R.self_consuming) //need to be metabolized
			continue
		if(!C)
			C = R.holder.my_atom
		if(C && R)
			if(C.reagent_check(R) != 1)
				if(can_overdose)
					if(R.overdose_threshold)
						if(R.volume >= R.overdose_threshold && !R.overdosed)
							R.overdosed = 1
							need_mob_update += R.overdose_start(C)
					if(R.addiction_threshold)
						if(R.volume >= R.addiction_threshold && !is_type_in_list(R, cached_addictions))
							var/datum/reagent/new_reagent = new R.type()
							cached_addictions.Add(new_reagent)
					if(R.overdosed)
						need_mob_update += R.overdose_process(C)
					if(is_type_in_list(R,cached_addictions))
						for(var/addiction in cached_addictions)
							var/datum/reagent/A = addiction
							if(istype(R, A))
								A.addiction_stage = -15 // you're satisfied for a good while.
				need_mob_update += R.on_mob_life(C)

	if(can_overdose)
		if(addiction_tick == 6)
			addiction_tick = 1
			for(var/addiction in cached_addictions)
				var/datum/reagent/R = addiction
				if(C && R)
					R.addiction_stage++
					switch(R.addiction_stage)
						if(1 to 10)
							need_mob_update += R.addiction_act_stage1(C)
						if(10 to 20)
							need_mob_update += R.addiction_act_stage2(C)
						if(20 to 30)
							need_mob_update += R.addiction_act_stage3(C)
						if(30 to 40)
							need_mob_update += R.addiction_act_stage4(C)
						if(40 to INFINITY)
							to_chat(C, "<span class='notice'>You feel like you've gotten over your need for [R.name].</span>")
							C.SendSignal(COMSIG_CLEAR_MOOD_EVENT, "[R.id]_addiction")
							cached_addictions.Remove(R)
		addiction_tick++
	if(C && need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		C.updatehealth()
		C.update_canmove()
		C.update_stamina()
	update_total()

/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	var/list/cached_reagents = reagent_list
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		R.on_move(A, Running)
	update_total()

/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		R.on_update(A)
	update_total()

/datum/reagents/proc/isolate_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/id in cached_reagents)
		if(id != reagent)
			del_reagent(id)
			update_total()

/datum/reagents/proc/del_reagent(reagent)
	var/list/cached_reagents = reagent_list
	var/datum/reagent/R = cached_reagents[reagent]
	if(!R)
		return TRUE
	if(my_atom && isliving(my_atom))
		var/mob/living/M = my_atom
		R.on_mob_delete(M)
	qdel(R)
	reagent_list -= reagent
	update_total()
	if(my_atom)
		my_atom.on_reagent_change(DEL_REAGENT)
	return TRUE

/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	total_volume = 0
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		if(R.volume < REAGENT_GC_MINIMUM_VOLUME)
			del_reagent(id)
		else
			total_volume += R.volume

	return 0

/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/id in cached_reagents)
		del_reagent(id)
	return 0

/datum/reagents/proc/reaction(atom/A, method = TOUCH, volume_modifier = 1, show_message = 1)
	var/react_type
	if(isliving(A))
		react_type = "LIVING"
		if(method == INGEST)
			var/mob/living/L = A
			L.taste(src)
	else if(isturf(A))
		react_type = "TURF"
	else if(isobj(A))
		react_type = "OBJ"
	else
		return
	var/list/cached_reagents = reagent_list
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		switch(react_type)
			if("LIVING")
				var/touch_protection = 0
				if(method == VAPOR)
					var/mob/living/L = A
					touch_protection = L.get_permeability_protection()
				R.reaction_mob(A, method, R.volume * volume_modifier, show_message, touch_protection)
			if("TURF")
				R.reaction_turf(A, R.volume * volume_modifier, show_message)
			if("OBJ")
				R.reaction_obj(A, R.volume * volume_modifier, show_message)

/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

//Returns the average specific heat for all reagents currently in this holder.
/datum/reagents/proc/specific_heat()
	. = 0
	var/cached_amount = total_volume		//cache amount
	var/list/cached_reagents = reagent_list		//cache reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.volume / cached_amount

WIP_TAG		//optimize performance
/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, other_temp = 300, other_pH = REAGENT_NORMAL_PH, other_purity = 1.000, no_react = 0)
	if(!isnum(amount) || !amount)
		return FALSE

	if(amount < 0)
		return FALSE

	var/datum/reagent/D = SSreagents.reagents_by_id[reagent]
	if(!D)
		WARNING("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
		return FALSE

	update_total()
	var/cached_total = total_volume
	if(cached_total + amount > maximum_volume)
		amount = (maximum_volume - cached_total) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.
	var/new_total = cached_total + amount
	var/cached_temp = chem_temp
	var/list/cached_reagents = reagent_list
	var/cached_pH = pH

	WIP_TAG		//check my maths for temperature and pH
	//Equalize temperature - Not using specific_heat() intentionally.
	var/specific_heat = 0
	var/thermal_energy = 0
	for(var/i in cached_reagents)
		var/datum/reagent/R = cached_reagents[i]
		specific_heat += R.specific_heat * (R.volume / new_total)
		thermal_energy += R.specific_heat * R.volume * cached_temp
	specific_heat += D.specific_heat * (amount / new_total)
	thermal_energy += D.specific_heat * amount * other_temp
	chem_temp = thermal_energy / (specific_heat * new_total)
	////

	//Neutralize pH
	pH = round(-log(10, ((cached_total * (10^(-cached_pH))) + (amount * (10^(-other_pH)))) / new_total), REAGENT_PH_ACCURACY)
	////

	if(cached_reagents[reagent])								//if it's already in us, merge
		var/datum/reagent/R = cached_reagents[reagent]

		WIP_TAG			//check my maths for purity calculations
		//Add amount and equalize purity
		var/our_pure_moles = R.volume * R.purity
		var/their_pure_moles = amount * other_purity
		R.volume += amount
		R.purity = (our_pure_moles + their_pure_moles) / (R.volume)
			////

		update_total()
		if(my_atom)
			my_atom.on_reagent_change(ADD_REAGENT)
		R.on_merge(data, amount)
		if(!no_react)
			start_reacting()
		return TRUE

	else
		var/datum/reagent/R = new D.type(data)
		cached_reagents[R.id] = R
		R.holder = src
		R.volume = amount
		R.purity = other_purity
		if(data)
			R.data = data
			R.on_new(data)

		update_total()
		if(my_atom)
			my_atom.on_reagent_change(ADD_REAGENT)
		if(!no_react)
			start_reacting()
		if(isliving(my_atom))
			R.on_mob_add(my_atom)
		return TRUE

	return FALSE

/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null) // Like add_reagent but you can enter a list. Format it like this: list("toxin" = 10, "beer" = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)

/datum/reagents/proc/remove_reagent(reagent, amount, safety)//Added a safety check for the trans_id_to

	if(isnull(amount))
		amount = 0
		CRASH("null amount passed to reagent code")
		return FALSE

	if(!isnum(amount))
		return FALSE

	if(amount < 0)
		return FALSE

	var/list/cached_reagents = reagent_list

	var/datum/reagent/R = cached_reagents[reagent]
	if(!R)
		return FALSE
	//clamp the removal amount to be between current reagent amount
	//and zero, to prevent removing more than the holder has stored
	amount = CLAMP(amount, 0, R.volume)
	R.volume -= amount
	update_total()
	if(!safety)//So it does not handle reactions when it need not to
		start_reacting()
	if(my_atom)
		my_atom.on_reagent_change(REM_REAGENT)

	return TRUE

/datum/reagents/proc/has_reagent(reagent, amount)
	var/list/cached_reagents = reagent_list
	var/datum/reagent/R = cached_reagents[reagent]
	if(!R)
		return FALSE
	if(!amount)
		return R
	else
		if(R.volume >= amount)
			return R
		else
			return FALSE

/datum/reagents/proc/get_reagent_amount(reagent)
	var/list/cached_reagents = reagent_list
	var/datum/reagent/R = cached_reagents[reagent]
	if(R)
		return R.volume
	else
		return 0

/datum/reagents/proc/get_reagents()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/id in cached_reagents)
		var/datum/reagent/R = cached_reagents[id]
		names += R.name

	return jointext(names, ",")

/datum/reagents/proc/log_string()
	var/list/L = list()
	for(var/id in reagent_list)
		var/datum/reagent/R = reagent_list[id]
		L[id] = R.volume
	return json_encode(L)

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = FALSE, safety = TRUE) // Removes all reagent of X type. @strict set to TRUE determines whether the childs of the type are included.
	. = FALSE
	if(!isnum(amount))
		return
	var/list/cached_reagents = reagent_list
	if(strict)
		var/id_to_remove = SSreagents.reagent_ids_by_type[reagent_type]
		if(id_to_remove)
			. = remove_reagent(id_to_remove, amount, safety)
	else
		var/list/ids_to_remove = typesof(reagent_type)
		for(var/i in 1 to ids_to_remove.len)
			ids_to_remove[i] = SSreagents.reagent_ids_by_type[ids_to_remove[i]]
			ids_to_remove ^= cached_reagents
			for(var/id in ids_to_remove)
				var/datum/reagent/R = cached_reagents[id]
				if(!R)
					continue
				. |= remove_reagent(id, amount, safety)

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	var/datum/reagent/R = cached_reagents[reagent_id]
	if(R)
		return R.data
	return FALSE

/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	var/datum/reagent/R = cached_reagents[reagent_id]
	if(R)
		R.data = new_data
		return TRUE
	return FALSE

/datum/reagents/proc/copy_data(datum/reagent/current_reagent)
	if(!current_reagent || !current_reagent.data)
		return null
	if(!istype(current_reagent.data, /list))
		return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if(trans_data["viruses"])
		var/list/v = trans_data["viruses"]
		trans_data["viruses"] = v.Copy()

	return trans_data

/datum/reagents/proc/return_reagents()
	. = list()
	for(var/id in reagent_list)
		var/datum/reagent/R = reagent_list[id]
		.[R] = R.volume

/datum/reagents/proc/get_reagent(type, strict = FALSE)
	var/list/cached_reagents = reagent_list
	if(strict)
		return cached_reagents[SSreagents.reagent_ids_by_type[type]]
	else
		var/list/ids = typesof(type)
		for(var/i in 1 to ids.len)
			return cached_reagents[SSreagents.reagent_ids_by_type[ids[i]]]

/datum/reagents/proc/get_reagent_list(type, strict = FALSE)
	var/list/cached_reagents = reagent_list
	if(strict)
		return list(cached_reagents[SSreagents.reagent_ids_by_type[type]])
	else
		. = list()
		var/list/ids = typesof(type)
		for(var/i in 1 to ids.len)
			var/c = cached_reagents[SSreagents.reagent_ids_by_type[ids[i]]]
			if(c)
				. += c

/datum/reagents/proc/generate_taste_message(minimum_percent=15)
	// the lower the minimum percent, the more sensitive the message is.
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/id in reagent_list)
			var/datum/reagent/R = reagent_list[id]
			if(!R.taste_mult)
				continue

			if(istype(R, /datum/reagent/consumable/nutriment))
				var/list/taste_data = R.data
				for(var/taste in taste_data)
					var/ratio = taste_data[taste]
					var/amount = ratio * R.taste_mult * R.volume
					if(taste in tastes)
						tastes[taste] += amount
					else
						tastes[taste] = amount
			else
				var/taste_desc = R.taste_description
				var/taste_amount = R.volume * R.taste_mult
				if(taste_desc in tastes)
					tastes[taste_desc] += taste_amount
				else
					tastes[taste_desc] = taste_amount
		//deal with percentages
		// TODO it would be great if we could sort these from strong to weak
		var/total_taste = counterlist_sum(tastes)
		if(total_taste > 0)
			for(var/taste_desc in tastes)
				var/percent = tastes[taste_desc]/total_taste * 100
				if(percent < minimum_percent)
					continue
				var/intensity_desc = "a hint of"
				if(percent > minimum_percent * 2 || percent == 100)
					intensity_desc = ""
				else if(percent > minimum_percent * 3)
					intensity_desc = "the strong flavor of"
				if(intensity_desc != "")
					out += "[intensity_desc] [taste_desc]"
				else
					out += "[taste_desc]"

	return english_list(out, "something indescribable")

/datum/reagents/proc/expose_temperature(var/temperature, var/coeff=0.02)
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	chem_temp = round(chem_temp)
	start_reacting()

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol)
	if(reagents)
		qdel(reagents)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src

/proc/get_random_reagent_id()	// Returns a random reagent ID minus blacklisted reagents
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing  in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.can_synth))
				random_reagents += initial(R.id)
	var/picked_reagent = pick(random_reagents)
	return picked_reagent
