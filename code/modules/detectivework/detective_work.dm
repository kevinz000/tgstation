//CONTAINS: Suit fibers and Detective's Scanning Computer



/atom/proc/return_fingerprints()
	GET_COMPONENT(D, /datum/component/forensics)
	return D? D.return_fingerprints() : list()

/atom/proc/return_hiddenprints()
	GET_COMPONENT(D, /datum/component/forensics)
	return D? D.return_hiddenprints() : list()

/atom/proc/return_blood_DNA()
	GET_COMPONENT(D, /datum/component/forensics)
	return D? D.return_blood_DNA() : list()

/atom/proc/return_fibers()
	GET_COMPONENT(D, /datum/component/forensics)
	return D? D.return_fibers() : list()

/atom/proc/has_fingerprints()
	GET_COMPONENT(D, /datum/component/forensics)
	return D.has_fingerprints()

/atom/proc/has_hiddenprints()
	GET_COMPONENT(D, /datum/component/forensics)
	return D.has_hiddenprints()

/atom/proc/has_blood_DNA()
	GET_COMPONENT(D, /datum/component/forensics)
	return D.has_blood_DNA()

/atom/proc/has_fibers()
	GET_COMPONENT(D, /datum/component/forensics)
	return D.has_fibers()

/atom/proc/_wipe_fingerprints()
	GET_COMPONENT(D, /datum/component/forensics)
	return D? D.wipe_fingerprints() : TRUE

/atom/proc/wipe_hiddenrprints()
	GET_COMPONENT(D, /datum/component/forensics)
	return D? D.wipe_fingerprints() : TRUE

/atom/proc/_wipe_blood_DNA()
	GET_COMPONENT(D, /datum/component/forensics)
	return D? D.wipe_blood_DNA() : TRUE

/atom/proc/_wipe_fibers()
	GET_COMPONENT(D, /datum/component/forensics)
	return D? D.wipe_fibers() : TRUE

/atom/proc/add_fingerprints(list/fingerprints)
	if(length(fingerprints))
		var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
		. = D.add_fingerprints(fingerprints)

//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint_from_mob(mob/living/M, ignoregloves = FALSE)
	var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
	. = D.add_fingerprint_from_mob(M, ignoregloves)

/atom/proc/add_fibers(list/fibertext)
	if(length(fibertext))
		var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
		. = D.add_fibers(fibertext)

/atom/proc/add_fibers_from_mob(mob/living/carbon/human/M)
	var/old = 0
	if(M.gloves && istype(M.gloves, /obj/item/clothing))
		var/obj/item/clothing/gloves/G = M.gloves
		old = length(G.return_blood_DNA())
		if(G.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(add_blood_DNA(G.return_blood_DNA()) && length(G.return_blood_DNA()) > old) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands > 1)
		old = length(M.return_blood_DNA())
		if(add_blood_DNA(M.return_blood_DNA()) && length(M.return_blood_DNA()) > old)
			M.bloody_hands--
	var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
	. = D.add_fibers_from_mob(M)

/atom/proc/add_hiddenprints(list/hiddenprints)	//NOTE: THIS IS FOR ADMINISTRATION FINGERPRINTS, YOU MUST CUSTOM SET THIS TO INCLUDE CKEY/REAL NAMES!
	if(length(hiddenprints))
		var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
		. = D.add_hiddenprints(hiddenprints)

/atom/proc/add_hiddenprint_from_mob(mob/living/M)
	var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
	. = D.add_hiddenprint_from_mob(M)

/atom/proc/add_blood_DNA(list/dna)
	return FALSE

/obj/add_blood_DNA(list/dna)
	. = ..()
	if(length(dna))
		var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
		. = D.add_blood_DNA(dna)

/obj/item/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	if(!.)
		return FALSE
	if(has_blood_DNA())
		LoadComponent(/datum/component/decal/blood)
	return TRUE	//we applied blood to the item

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src, diseases)
	B.add_blood_DNA(blood_dna) //give blood info to the blood decal.
	return TRUE //we bloodied the floor

/mob/living/carbon/human/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	if(wear_suit)
		wear_suit.add_blood_DNA(blood_dna)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood_DNA(blood_dna)
		update_inv_w_uniform()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood_DNA(blood_dna)
	else if(length(blood_dna))
		var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
		. = D.add_blood_DNA(dna)
		bloody_hands = rand(2, 4)
	update_inv_gloves()	//handles bloody hands overlays and updating
	return TRUE

/atom/proc/transfer_fingerprints_to(atom/A)
	A.add_fingerprints(return_fingerprints())
	A.add_hiddenprints(return_hiddenprints())
	A.fingerprintslast = fingerprintslast
