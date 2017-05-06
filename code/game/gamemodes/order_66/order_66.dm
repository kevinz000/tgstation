
/datum/game_mode/order_66
	name = "Order 66"
	config_tag = "order_66"
	required_players = 25
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 14
	announce_span = "danger"
	announce_text = "Nanotrasen has decided the station and its crew are no longer affordable to maintain!\n\
	<span class='danger'>Nanotrasen Loyalists</span>: Secure the list of objects sent to the NT_leader and ensure no one who is not implanted and loyal escapes. Detonate the onboard nuclear device to erase all evidence.\n\
	<span class='notice'>All others</span>: Prevent the NT_leader from exterminating the crew and detonating the station. Be aware that anyone loyalty implanted will be on his side!"
	var/list/datum/mind/NT_leaders = list()
	var/list/datum/mind/NT_loyalists = list()
	var/list/steal_objective_typecache = list()
	var/research_levels_to_steal = 0
	var/activated = FALSE

/datum/game_mode/order_66/announce()
	to_chat(world, "<span class='boldwarning'>The current game mode is - Order 66!</span>")
	to_chat(world, "<span class='boldnotice'>Nanotrasen has decided the venture is too expensive, and that all evidence of this failure must be erased. \
	<BR><span class='boldnotice'>Nanotrasen Loyalists: Secure the list of objects sent to the NT_leader of the station, and ensure only those truely loyal to Nanotrasen escapes alive and free. Detonate the onboard nuclear device to erase all evidence. Protect the Nanotrasen Leaders at all costs!</span> \
	<BR>All others: Prevent the Nanotrasen Loyalists from purging the crew.	Assassinate the NT_leader and prevent Nanotrasen from destroying the station. </span>")

/datum/game_mode/order_66/pre_setup()
	var/left = recommended_enemies
	while(left)
		if(!antag_candidates.len)
			if(left > (recommended_enemies - required_enemies))
				return FALSE
			else
				return TRUE
		var/datum/mind/vader = pick(antag_candidates)
		antag_candidates -= vader
		NT_leaders += vader
		if(!try_to_assign_captain(vader))
			try_to_assign_security(vader)
	return FALSE

/datum/game_mode/order_66/post_setup()
	//Convert the NT_leader and all implanted personnel.
	//Loyalty implant malfunction
	//Prevent all ways of getting loyalty implants outside of roundstart availability.

/datum/game_mode/order_66/process()
	//Check for NT_leader being alive

//CODE TO MAKE SURE NUCLEAR BOMB DOESN'T INSTANTLY END ROUND AND INSTEAD WAITS FOR SHUTTLE IF SHUTTLE IS IN TRANSIT!

/datum/game_mode/order_66/proc/get_all_loyalist_mobs(include_NT_leader = TRUE)
	var/list/ret = list()
	for(var/datum/mind/M in NT_loyalists)
		ret += M.current
	if(include_NT_leader)
		ret += NT_leader.current
	return ret

/datum/game_mode/order_66/proc/get_all_unloyal_mobs()
	var/list/ret = list()
	for(var/mob/living/L in GLOB.player_list)
		if(!order_66_is_NT_loyalist(L))
			ret += L
	return ret

/datum/game_mode/order_66/proc/prepare_NT_leaders()
	//Prepare NT_leaders, give objectives, list of things to retrieve, equip with items.

/datum/game_mode/order_66/proc/check_NT_leaders()
	//Check if all NT_leaders dead/gone/hiding/offlevel for too long.

/datum/game_mode/order_66/proc/auto_declare_completion_order_66()
	//Did the station get nuked
	//Did (And how many) non loyal survivors escape
	//How many items were stolen
	//How much research was stolen
	//Set news story.
	//Set blackbox

/datum/game_mode/order_66/proc/check_unloyal_escapees()
	var/list/L = get_all_unloyal_mobs()
	return L.len

/datum/game_mode/order_66/proc/check_stolen_items()
	//How many items were sucessfully stolen

/datum/game_mode/order_66/proc/check_nuke()
	//Was the station nuked

/datum/game_mode/order_66/proc/check_stolen_research()
	//How much research levels were stolen

/datum/game_mode/order_66/proc/set_news_story(nuked, escapees, item_percent, research_levels)
	//self explanatory
