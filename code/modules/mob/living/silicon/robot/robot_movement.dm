/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0)
	if(ionpulse())
		return 1
	return ..()

/mob/living/silicon/robot/movespeed_ds()
	. = 32
	var/static/datum/config_entry/number/config_robot_mod
	var/static/datum/config_entry/number/config_robot_adj
	if(isnull(config_robot_delay) || isnull(config_robot_adj))
		config_robot_mod = CONFIG_GET_DATUM(number/movespeed_mod_robot)
		config_robot_adj = CONFIG_GET_DATUM(number/movespeed_adj_robot)
	. = ((..() * speed_mod) * config_robot_mod) + config_robot_adj

/mob/living/silicon/robot/mob_negates_gravity()
	return magpulse

/mob/living/silicon/robot/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()
