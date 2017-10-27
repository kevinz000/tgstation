
/datum/species/hologram
	name = "Hardlight Hologram"
	id = "hologram"
	say_mod = "states"
	species_traits = list(MUTCOLORS,LIPS,RESISTHOT,RESISTCOLD,RESISTPRESSURE,RADIMMUNE,NOBREATH,NOBLOOD,NOFIRE,VIRUSIMMUNE,PIERCEIMMUNE,NOTRANSSTING,NODISMEMBER,NOHUNGER,NOCRITDAMAGE,NOZOMBIE,NOLIVER,NOSTOMACH,NO_DNA_COPY,NO_UNDERWEAR,HAIR,FACEHAIR,EYECOLOR)
	default_features = list("mcolor" = "33F")
	default_color = "3333FF"
	hair_alpha = 190
	meat = null
	disliked_food = NONE
	toxic_food = NONE
	liked_food = NONE
	blacklisted = TRUE
	dangerous_existence = TRUE
	siemens_coeff = 0
	damage_overlay_type = ""	//hope we can get holographic effects later but for now none.
	sexes = TRUE
	force_cpr = TRUE
	punch_damage_type = STAMINA
	punchdamagelow = 0
	punchdamagehigh = 10
	punchstunthreshold = 11
	attack_verb = "shocked"
	sound/attack_sound = 'sound/weapons/egloves.ogg'
	sound/miss_sound = 'sound/effects/sparks1.ogg'

	var/mob/living/silicon/ai/mainframe
	var/deployed = FALSE

/datum/species/hologram/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	H.reagents.remove_all(H.reagents.maximum_volume)
	return FALSE

/datum/species/hologram/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	if(damagetype == TOX || damagetype == OXY || damagetype == CLONE || damagetype == STAMINA || damagetype == BRAIN)
		return FALSE

/datum/species/hologram/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
//	for(var/i in C.bodyparts)
//		var/obj/item/bodypart/BP = i
//		BP.status = BODYPART_HOLOGRAPHIC
	C.update_body()
	C.disabilities |= NOCLONE

/datum/species/hologram/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.disabilities &= ~NOCLONE

/datum/species/hologram/space_move(mob/living/carbon/human/H)
	return TRUE

/datum/species/hologram/negates_gravity(mob/living/carbon/human/H)
	return TRUE

/datum/species/hologram/handle_speech(message, mob/living/carbon/human/H)		//WIP: Disrupted speech when... disrupted by something!
	return message

/datum/species/hologram/get_spans()
	return list(SPAN_ROBOT)

/*/mob/living/carbon/human/holographic
	bodyparts = list(/obj/item/bodypart/chest/holographic, /obj/item/bodypart/head/holographic, /obj/item/bodypart/l_arm/holographic,
				 /obj/item/bodypart/r_arm/holographic, /obj/item/bodypart/r_leg/holographic, /obj/item/bodypart/l_leg/holographic)

/mob/living/carbon/human/holographic/Initialize()
	. = ..()
	set_species(new /datum/species/hologram)*/

/datum/species/hologram/handle_digestion(mob/living/carbon/human/H)
	return

/datum/species/hologram/proc/bind_to_ai(mob/living/silicon/ai/AI, mob/living/carbon/human/holder)
	if(QDELETED(AI) || (istype(AI.holoshell) && AI.holoshell != holder))
		return FALSE
	mainframe = AI
	AI.holoshell = holder

/datum/species/hologram/proc/bound_to()
	return mainframe

/datum/species/hologram/onHear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	if(istype(mainframe))
		mainframe.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)
	return ..()

/datum/species/hologram/spec_life(mob/living/carbon/human/H)
	return ..()

/datum/species/hologram/spec_death(gibbed, mob/living/carbon/human/H)
	return ..()

/datum/species/hologram/auto_equip(mob/living/carbon/human/H)
	//TODO: AI equipment...
	return ..()

/datum/species/hologram/check_weakness(obj/item, mob/living/attacker)
	//Maybe electrical/emp weapon checks
	return ..()

/datum/species/hologram/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	//Maybe grab state checks
	return ..()

/datum/species/hologram/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	//Maybe stamina loss checks.
	return ..()


/*

	var/obj/item/organ/brain/mutant_brain = /obj/item/organ/brain
	var/obj/item/organ/eyes/mutanteyes = /obj/item/organ/eyes
	var/obj/item/organ/ears/mutantears = /obj/item/organ/ears
	var/obj/item/mutanthands
	var/obj/item/organ/tongue/mutanttongue = /obj/item/organ/tongue

	var/obj/item/organ/liver/mutantliver
	var/obj/item/organ/stomach/mutantstomach

/datum/species/New()

	if(!limbs_id)	//if we havent set a limbs id to use, just use our own id
		limbs_id = id
	..()


/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	//maybe weapon weaknesses/ai interactions?


/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	//maybe weapon weaknesses/ai interactions?

/datum/species/proc/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	//stun/disable/emp weapons checks maybe?

/datum/species/proc/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	//stun/disable/emp weapons checks maybe?

*/