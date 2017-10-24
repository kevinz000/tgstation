
/datum/species/hologram
	name = "Hardlight Hologram"
	id = "hologram"
	say_mod = "states"
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NOHUNGER)
	var/mob/living/silicon/ai/mainframe

/datum/species/hologram/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	H.reagents.remove_all(H.reagents.maximum_volume)



