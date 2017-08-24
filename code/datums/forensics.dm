//////////////////////FORENSICS DATUM
/datum/forensics
	var/list/gsr
	var/list/prints
	var/list/hiddenprints
	var/list/fibers
	var/list/blood
	var/maxSize = 5

//GETTERS
/datum/forensics/proc/has_blood()
	return LAZYLEN(blood)? TRUE : FALSE

/datum/forensics/proc/has_prints()
	return LAZYLEN(prints)? TRUE : FALSE

/datum/forensics/proc/has_hiddenprints()
	return LAZYLEN(prints)? TRUE : FALSE

/datum/forensics/proc/has_fibers()
	return LAZYLEN(fibers)? TRUE : FALSE

/datum/forensics/proc/has_gsr()
	return LAZYLEN(gsr)? TRUE : FALSE

/datum/forensics/proc/return_blood()
	return blood

/datum/forensics/proc/return_fibers()
	return fibers

/datum/forensics/proc/return_hiddenprints()
	return hiddenprints

/datum/forensics/proc/return_prints()
	return prints

/datum/forensics/proc/return_gsr()
	return gsr

/atom/proc/has_blood()
	return forensics? forensics.has_blood() : FALSE

/atom/proc/has_prints()
	return forensics? forensics.has_prints() : FALSE

/atom/proc/has_hiddenprints()
	return forensics? forensics.has_hiddenprints() : FALSE

/atom/proc/has_fibers()
	return forensics? forensics.has_fibers() : FALSE

/atom/proc/has_gsr()
	return forensics? forensics.has_gsr() : FALSE

/atom/proc/return_blood()
	return forensics? forensics.return_blood() : null

/atom/proc/return_fibers()
	return forensics? forensics.return_fibers() : null

/atom/proc/return_hiddenprints()
	return forensics? forensics.return_hiddenprints() : null

/atom/proc/return_prints()
	return forensics? forensics.return_prints() : null

/atom/proc/return_gsr()
	return forensics? forensics.return_gsr() : null

//CLEANING
/datum/forensics/proc/clean_blood()
	if(islist(blood))
		blood = null
		return TRUE
	return FALSE

/atom/proc/clean_blood()
	if(!forensics)
		return TRUE
	return = forensics.clean_blood()

/datum/forensics/proc/clean_prints()
	if(islist(prints))
		prints = null
		return TRUE
	return FALSE

/atom/proc/clean_prints()
	if(!forensics)
		return TRUE
	return forensics.clean_prints()

/datum/forensics/proc/clean_fibers()
	if(islist(fibers))
		fibers = null
		return TRUE
	return FALSE

/atom/proc/clean_fibers()
	if(!forensics)
		return TRUE
	return forensics.clean_fibers()

//ADD FIBERS

/datum/forensics/proc/add_fiber_direct(fiberstring)
	if(!islist(fibers))
		fibers = list(fiberstring)
	else
		fibers += fiberstring
	return TRUE

/atom/proc/add_fiber_direct(fiberstring)
	if(!forensics)
		forensics = new
	forensics.add_fiber_direct(fiberstring)

/datum/forensics/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves && istype(M.gloves, /obj/item/clothing))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(M.add_blood(G.return_blood())) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands > 1)
		if(M.add_blood(M.return_blood())))
			M.bloody_hands--
	var/item_multiplier = isitem(src)?1.2:1
	if(M.wear_suit)
		if(prob(10*item_multiplier) && !(fibertext in M.return_fibers()))
			M.add_fiber_direct("Material from \a [M.wear_suit].")
		if(!(M.wear_suit.body_parts_covered & CHEST))
			if(M.w_uniform)
				if(prob(12*item_multiplier) && !(fibertext in M.return_fibers())) //Wearing a suit means less of the uniform exposed.
					M.add_fiber_direct(fibertext = "Fibers from \a [M.w_uniform].")
		if(!(M.wear_suit.body_parts_covered & HANDS))
			if(M.gloves)
				M.set_fibers(list("Material from a pair of [M.gloves.name]."))
				if(prob(20*item_multiplier) && !(fibertext in M.return_fibers()))
					M.add_fiber_direct(fibertext)
	else if(M.w_uniform)
		if(prob(15*item_multiplier) && !(fibertext in M.return_fibers()))
			// "Added fibertext: [fibertext]"
			M.add_fiber_direct(fibertext = "Fibers from \a [M.w_uniform].")
		if(M.gloves)
			if(prob(20*item_multiplier) && !(fibertext in M.return_fibers()))
				M.add_fiber_direct(fibertext = "Material from a pair of [M.gloves.name].")
	else if(M.gloves)
		if(prob(20*item_multiplier) && !(fibertext in M.return_fibers()))
			M.add_fiber_direct("Material from a pair of [M.gloves.name].")

/atom/proc/add_fibers(mob/living/carbon/human/M)
	if(!forensics)
		forensics = new
	return forensics.add_fibers(M)

//ADD BLOOD
//to add blood from a mob onto something, and transfer their dna info
/datum/forensics/proc/add_mob_blood(mob/living/M)
	return add_blood(M.return_blood())

/atom/proc/add_mob_blood(mob/living/M)
	if(!forensics)
		forensics = new
	return forensics.add_mob_blood(M)

/datum/forensics/proc/add_blood(list/blood_dna)
	return FALSE

/atom/proc/add_blood(list/blood_dna)
	if(!forensics)
		forensics = new
	return forensics.transfer_blood_dna(blood_dna)

/obj/item/add_blood(list/blood_dna)
	var/blood_count = !has_blood()
	if(!..())
		return FALSE
	if(!blood_count)//apply the blood-splatter overlay if it isn't already in there
		add_blood_overlay()
	return TRUE //we applied blood to the item

/datum/forensics/proc/transfer_mob_blood_dna(mob/living/L)
	if(!islist(blood))
		blood = list()
	var/old_length = blood.len
	blood |= new_blood_dna
	if(blood.len == old_length)
		return FALSE
	return TRUE

/atom/proc/transfer_mob_blood_dna(mob/living/L)
	if(!forensics)
		forensics = new
	return forensics.transfer_mob_blood_dna(L)

//to add blood dna info to the object's blood_DNA list
/datum/forensics/proc/transfer_blood_dna(list/blood_dna)
	var/old_length = blood.len
	blood |= blood_dna
	if(blood.len > old_length)
		return TRUE //some new blood DNA was added
	return FALSE

/atom/proc/transfer_blood_dna(list/blood_dna)
	if(!forensics)
		forensics = new
	return forensics.transfer_blood_dna(blood_dna)


/datum/forensics/proc/add_hiddenprint(mob/living/M)
	if(!M || !M.key)
		return

	if(M.forensics.hiddenprints) //Add the list if it does not exist
		M.forensics.hiddenprints = list()

	var/hasgloves = ""
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			hasgloves = "(gloves)"

	var/current_time = time_stamp()
	if(!M.forensics.hiddenprints[M.key])
		M.forensics.hiddenprints[M.key] = "First: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]"
	else
		var/laststamppos = findtext(M.forensics.hiddenprints[M.key], " Last: ")
		if(laststamppos)
			M.forensics.hiddenprints[M.key] = copytext(M.forensics.hiddenprints[M.key], 1, laststamppos)
		M.forensics.hiddenprints[M.key] += " Last: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]"

	fingerprintslast = M.ckey

/atom/proc/add_hiddenprint(mob/living/M)
	if(!forensics)
		forensics = new
	return forensics.add_hiddenprint(M)

//Set ignoregloves to add prints irrespective of the mob having gloves on.
/datum/forensics/proc/add_fingerprint(mob/living/M, ignoregloves = FALSE)
	if(!M || !M.key)
		return

	M.add_hiddenprint(M)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		M.forensics.add_fibers(H)

		if(H.gloves) //Check if the gloves (if any) hide fingerprints
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.transfer_prints)
				ignoregloves = TRUE

			if(!ignoregloves)
				H.gloves.add_fingerprint(H, TRUE) //ignoregloves = 1 to avoid infinite loop.
				return

		if(!M.forensics.prints) //Add the list if it does not exist
			M.forensics.prints = list()
		var/full_print = md5(H.dna.uni_identity)
		M.forensics.prints[full_print] = full_print

/atom/proc/add_fingerprint(mob/living/M, ignoregloves = FALSE)
	if(!forensics)
		forensics = new
	return forensics.add_fingerprint(M, ignoregloves)

/datum/forensics/proc/transfer_fingerprints_to(atom/A)

	// Make sure everything are lists.
	if(!islist(A.forensics.prints))
		A.forensics.prints = list()
	if(!islist(A.forensics.hiddenprints))
		A.forensics.hiddenprints = list()

	if(!islist(prints))
		prints = list()
	if(!islist(hiddenprints))
		hiddenprints = list()

	// Transfer
	if(LAZYLEN(prints))
		A.forensics.prints |= prints.Copy()            //detective
	if(LAZYLEN(hiddenprints))
		A.forensics.hiddenprints |= hiddenprints.Copy()    //admin
	A.fingerprintslast = fingerprintslast


/atom/proc/transfer_fingerprints_to(atom/A)
	return forensics.transfer_fingerprints_to(A)
