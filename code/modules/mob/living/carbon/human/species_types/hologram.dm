
/datum/species/hologram
	name = "Hardlight Hologram"
	id = "hologram"
	say_mod = "states"
	species_traits = list(MUTCOLORS,HAIR,FACEHAIR,EYECOLOR,LIPS,RESISTHOT,RESISTCOLD,RESISTPRESSURE,RADIMMUNE,NOBREATH,NOBLOOD,NOFIRE,VIRUSIMMUNE,PIERCEIMMUNE,NOTRANSSTING,NODISMEMBER,NOHUNGER,NOCRITDAMAGE,NOZOMBIE,NOLIVER,NOSTOMACH,NO_DNA_COPY,NO_UNDERWEAR)
	default_features = list("mcolor" = "88F")
	hair_alpha = 190
	meat = null
	disliked_food = NONE
	toxic_food = NONE
	liked_food = NONE
	blacklisted = TRUE
	dangerous_existence = TRUE
	siemens_coeff = 0
	damage_overlay_type = ""	//hope we can get holographic effects later but for now none.

	var/mob/living/silicon/ai/mainframe

/datum/species/hologram/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	H.reagents.remove_all(H.reagents.maximum_volume)
	return FALSE

/datum/species/hologram/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.disabilities |= NOCLONE.

/datum/species/hologram/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.disabilities &= ~NOCLONE

/datum/species/hologram/space_move(mob/living/carbon/human/H)
	return TRUE

/datum/species/hologram/negates_gravity(mob/living/carbon/human/H)
	return TRUE
