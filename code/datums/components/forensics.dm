/datum/component/forensics
	var/list/fingerprints		//assoc print = print
	var/list/hiddenprints		//assoc ckey = realname/gloves/ckey
	var/list/blood_DNA			//assoc dna = bloodtype
	var/list/fibers				//assoc print = print

/datum/component/forensics/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_act)

/datum/component/forensics/proc/return_fingerprints()
	return length(fingerprints)? fingerprints.Copy() : list()

/datum/component/forensics/proc/return_hiddenprints()
	return length(hiddenprints)? hiddenprints.Copy() : list()

/datum/component/forensics/proc/return_blood_DNA()
	return length(blood_DNA)? blood_DNA.Copy() : list()

/datum/component/forensics/proc/return_fibers()
	return length(fibers)? fibers.Copy() : list()

/datum/component/forensics/proc/has_fingerprints()
	return length(fingerprints)? TRUE : FALSE

/datum/component/forensics/proc/has_hiddenprints()
	return length(hiddenprints)? TRUE : FALSE

/datum/component/forensics/proc/has_blood_DNA()
	return length(blood_DNA)? TRUE : FALSE

/datum/component/forensics/proc/has_fibers()
	return length(fibers)? TRUE : FALSE

/datum/component/forensics/proc/wipe_fingerprints()
	fingerprints = null
	gc()
	return TRUE

/datum/component/forensics/proc/wipe_hiddenprints()
	return	//no.

/datum/component/forensics/proc/wipe_blood_DNA()
	blood_DNA = null
	gc()
	return TRUE

/datum/component/forensics/proc/wipe_fibers()
	fibers = null
	gc()
	return TRUE

/datum/component/forensics/proc/clean_act(strength)
	if(strength >= CLEAN_STRENGTH_FINGERPRINTS)
		wipe_fingerprints()
	if(strength >= CLEAN_STRENGTH_BLOOD)
		wipe_blood_DNA()
	if(strength >= CLEAN_STRENGTH_FIBERS)
		wipe_fibers()

/datum/component/forensics/proc/gc()	//unlikely to happen due to hiddenprints always persisting but you never know.
	if(!length(hiddenprints) && !length(fingerprints) && !length(blood_DNA) && !length(fibers))
		qdel(src)

/datum/component/forensics/proc/add_fingerprints(list/_fingerprints)	//list(text)
	if(!length(_fingerprints))
		return
	LAZYINITLIST(fingerprints)
	for(var/i in _fingerprints)	//We use an associative list, make sure we don't just merge a non-associative list into ours.
		fingerprints[i] = i
	return TRUE

/datum/component/forensics/proc/add_fingerprint_from_mob(mob/living/M, ignoregloves = FALSE)
	if(!M)
		return
	add_hiddenprint_from_mob(M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		add_fibers_from_mob(H)
		if(H.gloves) //Check if the gloves (if any) hide fingerprints
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.transfer_prints)
				ignoregloves = TRUE
			if(!ignoregloves)
				H.gloves.add_fingerprint_from_mob(H, TRUE) //ignoregloves = 1 to avoid infinite loop.
				return
		var/full_print = md5(H.dna.uni_identity)
		LAZYSET(fingerprints, full_print, full_print)
	return TRUE

/datum/component/forensics/proc/add_fibers(list/_fibertext)		//list(text)
	if(!length(_fibertext))
		return
	LAZYINITLIST(fibers)
	for(var/i in _fibertext)	//We use an associative list, make sure we don't just merge a non-associative list into ours.
		fibers[i] = i
	return TRUE

/datum/component/forensics/proc/add_fibers_from_mob(mob/living/carbon/human/M)
	var/fibertext
	var/item_multiplier = isitem(src)?1.2:1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && !LAZYACCESS(fibers, fibertext))
			LAZYSET(fibers, fibertext, fibertext)
		if(!(M.wear_suit.body_parts_covered & CHEST))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12*item_multiplier) && !LAZYACCESS(fibers, fibertext)) //Wearing a suit means less of the uniform exposed.
					LAZYSET(fibers, fibertext, fibertext)
		if(!(M.wear_suit.body_parts_covered & HANDS))
			if(M.gloves)
				fibertext = "Material from a pair of [M.gloves.name]."
				if(prob(20*item_multiplier) && !LAZYACCESS(fibers, fibertext))
					LAZYSET(fibers, fibertext, fibertext)
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && !LAZYACCESS(fibers, fibertext))
			// "Added fibertext: [fibertext]"
			LAZYSET(fibers, fibertext, fibertext)
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20*item_multiplier) && !LAZYACCESS(fibers, fibertext))
				LAZYSET(fibers, fibertext, fibertext)
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && !LAZYACCESS(fibers, fibertext))
			LAZYSET(fibers, fibertext, fibertext)
	return TRUE

/datum/component/forensics/proc/add_hiddenprints(list/_hiddenprints)	//list(ckey = text)
	if(!length(_hiddenprints))
		return
	LAZYINITLIST(hiddenprints)
	for(var/i in _hiddenprints)	//We use an associative list, make sure we don't just merge a non-associative list into ours.
		hiddenprints[i] = _hiddenprints[i]
	return TRUE

/datum/component/forensics/proc/add_hiddenprint_from_mob(mob/living/M)
	if(!M || !M.key)
		return
	var/hasgloves = ""
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			hasgloves = "(gloves)"
	var/current_time = time_stamp()
	if(!LAZYACCESS(hiddenprints, M.key))
		LAZYSET(hiddenprints, M.key, "First: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]")
	else
		var/laststamppos = findtext(LAZYACCESS(hiddenprints, M.key), " Last: ")
		if(laststamppos)
			LAZYSET(hiddenprints, M.key, copytext(hiddenprints[M.key], 1, laststamppos))
		hiddenprints[M.key] += " Last: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]"	//made sure to be existing by if(!LAZYACCESS);else
	fingerprintslast = M.ckey
	return TRUE

/datum/component/forensics/proc/add_blood_DNA(list/dna)		//list(dna_enzymes = type)
	if(!length(dna))
		return
	LAZYINITLIST(blood_DNA)
	for(var/i in dna)
		blood_DNA[i] = dna[i]
	return TRUE
