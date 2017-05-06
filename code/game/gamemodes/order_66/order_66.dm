
/datum/game_mode/order_66
	name = "Order 66"
	config_tag = "order_66"
	required_players = 25
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 14
	announce_span = "danger"
	announce_text = "Nanotrasen has decided the station and its crew are no longer affordable to maintain!\n\
	<span class='danger'>Nanotrasen Loyalists</span>: Secure the list of objects sent to the Captain and ensure no one who is not implanted and loyal escapes. Detonate the onboard nuclear device to erase all evidence.\n\
	<span class='notice'>All others</span>: Prevent the Captain from exterminating the crew and detonating the station. Be aware that anyone loyalty implanted will be on his side!"
	var/datum/mind/NT_leader = null
	var/list/datum/mind/NT_loyalists = list()
	var/list/steal_objective_typecache = list()
	var/research_levels_to_steal = 0
	var/activated = FALSE

/datum/game_mode/order_66/announce()
	to_chat(world, "<span class='boldwarning'>The current game mode is - Order 66!</span>")
	to_chat(world, "<span class='boldnotice'>Nanotrasen has decided the venture is too expensive, and that all evidence of this failure must be erased. \
	<BR><span class='boldnotice'>Nanotrasen Loyalists: Secure the list of objects sent to the captain of the station, and ensure only those truely loyal to Nanotrasen escapes alive and free. Detonate the onboard nuclear device to erase all evidence.</span> \
	<BR>All others: Prevent the Nanotrasen Loyalists from purging the crew.	Assassinate the captain and prevent Nanotrasen from destroying the station. </span>")

/datum/game_mode/order_66/pre_setup()
	//Force someone to be captain

/datum/game_mode/order_66/post_setup()
	//Convert the captain and all implanted personnel.
	//Loyalty implant malfunction
	//Prevent all ways of getting loyalty implants outside of roundstart availability.

/datum/game_mode/order_66/process()
	//Check for captain being alive

//CODE TO MAKE SURE NUCLEAR BOMB DOESN'T INSTANTLY END ROUND AND INSTEAD WAITS FOR SHUTTLE IF SHUTTLE IS IN TRANSIT!

/datum/game_mode/order_66/proc/prepare_captain()
	//Prepare captain, give objectives, list of things to retrieve, equip with items.

/datum/game_mode/order_66/proc/check_captain()
	//Check if captain's dead/gone/hiding/offlevel for too long.

/datum/game_mode/order_66/declare_completion()
	declare_completion_order_66()
	..()

/datum/game_mode/order_66/proc/declare_completion_order_66()
	//Did the station get nuked
	//Did (And how many) non loyal survivors escape
	//How many items were stolen
	//How much research was stolen
	//Set news story.
	//Set blackbox

/datum/game_mode/order_66/proc/check_unloyal_escapees()
	//How many unloyal crew/lifeforms escaped

/datum/game_mode/order_66/proc/check_stolen_items()
	//How many items were sucessfully stolen

/datum/game_mode/order_66/proc/check_nuke()
	//Was the station nuked

/datum/game_mode/order_66/proc/check_stolen_research()
	//How much research levels were stolen

/datum/game_mode/order_66/proc/set_news_story(nuked, escapees, item_percent, research_levels)
	//self explanatory
