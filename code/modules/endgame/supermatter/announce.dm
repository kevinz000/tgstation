
/datum/universal_state/cascade/proc/autoannounce(message)
	//TODO: Announcements shouldn't be command reports, should be way more.. emergency-oh-shit instead of normal reports.
	var/announce_text = "[station_name()]:<br>"
	switch(message)
		if(CASCADE_ANNOUCEMENT_BAD_ENDING_1)
			announce_text += "You have run out of time. The fabric of space-time has deteriorated to the point of no return.<br>"
			announce_text += "Your instructions are to proceed to the bluespace rift at [get_area(escape_rift)], and escape.<br>"
			announce_text += "You will very likely be the last humans alive.
			announce_text += "We estimate you will have about [CASCADE_UNIVERSE_END_DELAY/600] minutes to escape..<br>"
			announce_text += "Goodluck, and Central Command out!<br>"
		if(CASCADE_ANNOUNCEMENT_BAD_ENDING_2)
			announce_text += "AUTOMATED SYSTEM ALERT:<br>"
			announce_text += "Critical drop detected in crew lifesigns. Central command emergency overrides enabled<br>"
			announce_text += "EMERGENCY MESSAGE BROADCAST TO ALL STATIONS:<br>"
			announce_text += "If you are recieving this message, everyone here is already dead.<br>"
			announce_text += "As of this moment, the universe is no longer capable of supporting life, and will be incompatible with atomic structure as we know it in a matter of minutes.<br>"
			announce_text += "All employees are to find a bluespace escape rift at all costs, if applicable.<br>"
			announce_text += "Goodluck. Central command out, for the last tiIIIIAZSIZZZZZZZZZZZZZZZZZZZZ<br>"
		if(CASCADE_ANNOUNCEMENT_BAD_ENDING_3)
			announce_text += "AUTOMATED STATION ALLLLLLLLLLLLLLLLAFKZZZZ<br>"
			announce_text += "$!@#$%^^^^^%%% ERROR ERROR EVACUAAAAAAAA<br>"
			announce_text += "CATE IMMEDIATELY-Y-Y-Y-Y-Y-Y-BZZT*********<br>"
			announce_text += "SYST3M 3R0R @@@ZZ(((((((( DIE DIE DIE DIE DIE DIE<br>"
			announce_text += "DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE<br>"
			announce_text += "YOU WILL-LL-ILL-ILL SUFF-ER-ER-ER THE MIGHT OF THE<br>"
			announce_text += "ETERNALS-NALS-NALS-NALS DIE DIE DIE DIE DIE DIE DIE<br>"	//I don't fucking know.
		if(CASCADE_ANNOUNCEMENT_UNIVERSE_END)
			announce_text = "!$##$%F!$()AJ%(%KKKKE#@######<br>"
			for(var/i = 0, i < 10, i++)
				announce_text += Gibberish("#########################################################<br>")
	announce_text = Gibberish(announce_text, 20)
	print_command_report(text = announce_text, title = null, announce=TRUE)
