
/datum/universal_state/cascade/proc/handleScreenEffects()
	handleScreenColors()

/datum/universal_state/cascade/proc/handleScreenColors()
	escalateColor()
	setMobColors()

/datum/universal_state/cascade/proc/setMobColors()
	for(var/mob/M in mob_list)
		setMobVisionColor(M)

/datum/universal_state/cascade/proc/escalateColor()
	oldColorR += 0.128
	oldColorG += 0.25
	oldColorB += 0.25
	oldColorR = min(oldColorR, 128)
	oldColorG = min(oldColorG, 255)
	oldcolorB = min(oldColorB, 255)
	mobVisionColor = rgb(round(oldColorR, 1), round(oldColorG, 1), round(oldColorB, 1))

/datum/universal_state/cascade/proc/setMobVisionColor(mob/M)
	if(!M.ckey)
		return	//Don't bother.
	M.hud_used.plane_masters["15"].color = mobVisionColor

//Todo: Escalating overlay that looks like the screen is cracking

//Todo: Ending effect that is the screen cracking and fading to white.
