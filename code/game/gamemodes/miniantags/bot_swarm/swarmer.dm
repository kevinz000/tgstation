////Deactivated swarmer shell////
/obj/item/device/unactivated_swarmer
	name = "unactivated swarmer"
	desc = "A currently unactivated swarmer. Swarmers can self activate at any time, it would be wise to immediately dispose of this."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_unactivated"
	origin_tech = "bluespace=4;materials=4;programming=7"
	materials = list(MAT_METAL=10000, MAT_GLASS=4000)


/obj/item/device/unactivated_swarmer/New()
	if(!crit_fail)
		notify_ghosts("An unactivated swarmer has been created in [get_area(src)]!", enter_link = "<a href=?src=\ref[src];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)
	..()

/obj/item/device/unactivated_swarmer/Topic(href, href_list)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/item/device/unactivated_swarmer/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/screwdriver) && !crit_fail)
		user.visible_message("<span class='warning'>[usr.name] deactivates [src].</span>",
			"<span class='notice'>After some fiddling, you find a way to disable [src]'s power source.</span>",
			"<span class='italics'>You hear clicking.</span>")
		name = "deactivated swarmer"
		desc = "A shell of swarmer that was completely powered down. It can no longer activate itself."
		crit_fail = 1

/obj/item/device/unactivated_swarmer/attack_ghost(mob/user)
	if(crit_fail)
		user << "This swarmer shell is completely depowered. You cannot activate it."
		return

	var/be_swarmer = alert("Become a swarmer? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_swarmer == "No")
		return
	if(crit_fail)
		user << "Swarmer has been depowered."
		return
	if(qdeleted(src))
		user << "Swarmer has been occupied by someone else."
		return
	var/mob/living/simple_animal/hostile/swarmer/S = new /mob/living/simple_animal/hostile/swarmer(get_turf(loc))
	S.key = user.key
	qdel(src)


/obj/item/device/unactivated_swarmer/deactivated
	name = "deactivated swarmer"
	desc = "A shell of swarmer that was completely powered down. It can no longer activate itself."
	crit_fail = 1


////The Mob itself////

/mob/living/simple_animal/hostile/swarmer
	name = "Swarmer"
	unique_name = 1
	icon = 'icons/mob/swarmer.dmi'
	desc = "A robot of unknown design, they seek only to consume materials and replicate themselves indefinitely."
	speak_emote = list("tones")
	bubble_icon = "swarmer"
	health = 40
	maxHealth = 40
	status_flags = CANPUSH
	icon_state = "swarmer"
	icon_living = "swarmer"
	icon_dead = "swarmer_unactivated"
	icon_gib = null
	wander = 0
	harm_intent_damage = 5
	minbodytemp = 0
	maxbodytemp = 500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_damage_type = STAMINA
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD)
	languages_spoken = SWARMER
	languages_understood = SWARMER
	obj_damage = 0
	environment_smash = 0
	attacktext = "shocks"
	attack_sound = 'sound/effects/EMPulse.ogg'
	friendly = "pinches"
	speed = 0
	faction = list("swarmer")
	AIStatus = AI_OFF
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	ranged = 1
	projectiletype = /obj/item/projectile/beam/disabler
	ranged_cooldown_time = 20
	projectilesound = 'sound/weapons/taser2.ogg'
	loot = list(/obj/effect/decal/cleanable/robot_debris, /obj/item/stack/bluespace_crystal)
	del_on_death = 1
	deathmessage = "explodes with a sharp pop!"
	var/resources = 0 //Resource points, generated by consuming metal/glass
	var/max_resources = 100
	var/login_text_dump = {"
	<b>You are a swarmer, a weapon of a long dead civilization. Until further orders from your original masters are received, you must continue to consume and replicate.</b>
	<b>Clicking on any object will try to consume it, either deconstructing it into its components, destroying it, or integrating any materials it has into you if successful.</b>
	<b>Ctrl-Clicking on a mob will attempt to remove it from the area and place it in a safe environment for storage.</b>
	<b>Objectives:</b>
	1. Consume resources and replicate until there are no more resources left.
	2. Ensure that this location is fit for invasion at a later date; do not perform actions that would render it dangerous or inhospitable.
	3. Biological resources will be harvested at a later date; do not harm them.
	"}

/mob/living/simple_animal/hostile/swarmer/Login()
	..()
	src << login_text_dump

/mob/living/simple_animal/hostile/swarmer/New()
	..()
	verbs -= /mob/living/verb/pulled
	var/datum/atom_hud/data/diagnostic/diag_hud = huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)


/mob/living/simple_animal/hostile/swarmer/med_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/simple_animal/hostile/swarmer/med_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "hudstat"

/mob/living/simple_animal/hostile/swarmer/Stat()
	..()
	if(statpanel("Status"))
		stat("Resources:",resources)

/mob/living/simple_animal/hostile/swarmer/handle_inherent_channels(message, message_mode)
	if(message_mode == MODE_BINARY)
		swarmer_chat(message)
		return ITALICS | REDUCE_RANGE
	else
		. = ..()

/mob/living/simple_animal/hostile/swarmer/get_spans()
	return ..() | SPAN_ROBOT

/mob/living/simple_animal/hostile/swarmer/emp_act()
	if(health > 1)
		adjustHealth(health-1)
	else
		death()

/mob/living/simple_animal/hostile/swarmer/CanPass(atom/movable/O)
	if(istype(O, /obj/item/projectile/beam/disabler))//Allows for swarmers to fight as a group without wasting their shots hitting each other
		return 1
	if(isswarmer(O))
		return 1
	..()

////CTRL CLICK FOR SWARMERS AND SWARMER_ACT()'S////
/mob/living/simple_animal/hostile/swarmer/AttackingTarget()
	if(!isliving(target))
		target.swarmer_act(src)
	else
		..()

/mob/living/simple_animal/hostile/swarmer/CtrlClickOn(atom/A)
	face_atom(A)
	if(!isturf(loc))
		return
	if(next_move > world.time)
		return
	if(!A.Adjacent(src))
		return
	A.swarmer_act(src)

/atom/proc/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE //return TRUE/FALSE whether or not an AI swarmer should try this swarmer_act() again, NOT whether it succeeded.

/turf/closed/indestructible/swarmer_act()
	return FALSE

/obj/swarmer_act()
	if(resistance_flags & INDESTRUCTIBLE)
		return FALSE
	return ..()

/obj/item/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.Integrate(src)

/obj/item/weapon/gun/swarmer_act()//Stops you from eating the entire armory
	return FALSE

/turf/open/floor/swarmer_act()//ex_act() on turf calls it on its contents, this is to prevent attacking mobs by DisIntegrate()'ing the floor
	return FALSE

/obj/structure/lattice/catwalk/swarmer_catwalk/swarmer_act()
	return FALSE

/obj/structure/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	if(S.AIStatus == AI_ON)
		return FALSE
	else
		return ..()

/obj/effect/swarmer_act()
	return FALSE

/obj/effect/decal/cleanable/robot_debris/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	qdel(src)
	return TRUE

/obj/structure/flora/swarmer_act()
	return FALSE

/turf/open/floor/plating/lava/swarmer_act()
	if(!is_safe())
		new /obj/structure/lattice/catwalk/swarmer_catwalk(src)
	return FALSE

/obj/machinery/atmospherics/swarmer_act()
	return FALSE

/obj/structure/disposalpipe/swarmer_act()
	return FALSE

/obj/machinery/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DismantleMachine(src)
	return TRUE

/obj/machinery/light/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/door/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	for(var/turf/T in range(1, src))
		if(isspaceturf(T) || istype(T.loc, /area/space))
			S << "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>"
			S.target = null
			return FALSE
	return TRUE
	S.DisIntegrate(src)

/obj/machinery/camera/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	toggle_cam(S, 0)
	return TRUE

/obj/machinery/particle_accelerator/control_box/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/field/generator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/gravity_generator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/vending/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)//It's more visually interesting than dismantling the machine
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/turretid/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/chem_dispenser/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>The volatile chemicals in this machine would destroy us. Aborting.</span>"
	return FALSE

/obj/machinery/nuclearbomb/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This device's destruction would result in the extermination of everything in the area. Aborting.</span>"
	return FALSE

/obj/machinery/dominator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This device is attempting to corrupt our entire network; attempting to interact with it is too risky. Aborting.</span>"
	return FALSE

/obj/effect/decal/cleanable/crayon/gang/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Searching... sensor malfunction! Target lost. Aborting.</span>"
	return FALSE

/obj/effect/rune/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Searching... sensor malfunction! Target lost. Aborting.</span>"
	return FALSE

/obj/structure/reagent_dispensers/fueltank/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Destroying this object would cause a chain reaction. Aborting.</span>"
	return FALSE

/obj/structure/cable/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Disrupting the power grid would bring no benefit to us. Aborting.</span>"
	return FALSE

/obj/machinery/portable_atmospherics/canister/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>An inhospitable area may be created as a result of destroying this object. Aborting.</span>"
	return FALSE

/obj/machinery/telecomms/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This communications relay should be preserved, it will be a useful resource to our masters in the future. Aborting.</span>"
	return FALSE

/obj/machinery/message_server/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This communications relay should be preserved, it will be a useful resource to our masters in the future. Aborting.</span>"
	return FALSE

/obj/machinery/blackbox_recorder/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This machine has recorded large amounts of data on this structure and its inhabitants, it will be a useful resource to our masters in the future. Aborting. </span>"
	return FALSE

/obj/machinery/power/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Disrupting the power grid would bring no benefit to us. Aborting.</span>"
	return FALSE

/obj/machinery/gateway/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This bluespace source will be important to us later. Aborting.</span>"
	return FALSE

/turf/closed/wall/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	for(var/turf/T in range(1, src))
		if(isspaceturf(T) || istype(T.loc, /area/space))
			S << "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>"
			S.target = null
			return TRUE
	return ..()

/obj/structure/window/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	for(var/turf/T in range(1, src))
		if(isspaceturf(T) || istype(T.loc, /area/space))
			S << "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>"
			S.target = null
			return TRUE
	return ..()

/obj/item/stack/cable_coil/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)//Wiring would be too effective as a resource
	S << "<span class='warning'>This object does not contain enough materials to work with.</span>"
	return FALSE

/obj/machinery/porta_turret/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Attempting to dismantle this machine would result in an immediate counterattack. Aborting.</span>"
	return FALSE

/mob/living/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisperseTarget(src)
	return TRUE

/mob/living/simple_animal/slime/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This biological resource is somehow resisting our bluespace transceiver. Aborting.</span>"
	return FALSE

/obj/machinery/droneDispenser/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This object is receiving unactivated swarmer shells to help us. Aborting.</span>"
	return FALSE

/obj/item/device/unactivated_swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	if(S.resources + 50 > S.max_resources)
		S << "<span class='warning'>We have too many resources to reconsume this shell. Aborting.</span>"
	else
		..()
		S.resources += 49 //refund the whole thing
	return FALSE //would logically be TRUE, but we don't want AI swarmers eating player spawn chances.

////END CTRL CLICK FOR SWARMERS////

/mob/living/simple_animal/hostile/swarmer/proc/Fabricate(atom/fabrication_object,fabrication_cost = 0)
	if(!isturf(loc))
		src << "<span class='warning'>This is not a suitable location for fabrication. We need more space.</span>"
	if(resources >= fabrication_cost)
		resources -= fabrication_cost
	else
		src << "<span class='warning'>You do not have the necessary resources to fabricate this object.</span>"
		return 0
	return new fabrication_object(loc)


/mob/living/simple_animal/hostile/swarmer/proc/Integrate(obj/item/target)
	if(resources >= max_resources)
		src << "<span class='warning'>We cannot hold more materials!</span>"
		return TRUE
	if((target.materials[MAT_METAL]) || (target.materials[MAT_GLASS]))
		resources++
		do_attack_animation(target)
		changeNext_move(CLICK_CD_MELEE)
		var/obj/effect/overlay/temp/swarmer/integrate/I = PoolOrNew(/obj/effect/overlay/temp/swarmer/integrate, get_turf(target))
		I.pixel_x = target.pixel_x
		I.pixel_y = target.pixel_y
		I.pixel_z = target.pixel_z
		if(istype(target, /obj/item/stack))
			var/obj/item/stack/S = target
			S.use(1)
			if(S.amount)
				return TRUE
		qdel(target)
		return TRUE
	else
		src << "<span class='warning'>\the [target] is incompatible with our internal matter recycler.</span>"
	return FALSE


/mob/living/simple_animal/hostile/swarmer/proc/DisIntegrate(atom/movable/target)
	PoolOrNew(/obj/effect/overlay/temp/swarmer/disintegration, get_turf(target))
	do_attack_animation(target)
	changeNext_move(CLICK_CD_MELEE)
	target.ex_act(3)


/mob/living/simple_animal/hostile/swarmer/proc/DisperseTarget(mob/living/target)
	if(target == src)
		return

	if(z != ZLEVEL_STATION && z != ZLEVEL_LAVALAND)
		src << "<span class='warning'>Our bluespace transceiver cannot \
			locate a viable bluespace link, our teleportation abilities \
			are useless in this area.</span>"
		return

	src << "<span class='info'>Attempting to remove this being from \
		our presence.</span>"

	if(!do_mob(src, target, 30))
		return

	var/turf/open/floor/F
	switch(z) //Only the station/lavaland
		if(ZLEVEL_STATION)
			F =find_safe_turf(zlevels = ZLEVEL_STATION, extended_safety_checks = TRUE)
		if(ZLEVEL_LAVALAND)
			F = find_safe_turf(zlevels = ZLEVEL_LAVALAND, extended_safety_checks = TRUE)
	if(!F)
		return
	// If we're getting rid of a human, slap some energy cuffs on
	// them to keep them away from us a little longer

	var/mob/living/carbon/human/H = target
	if(ishuman(target) && (!H.handcuffed))
		H.handcuffed = new /obj/item/weapon/restraints/handcuffs/energy/used(H)
		H.update_handcuffed()
		add_logs(src, H, "handcuffed")

	var/datum/effect_system/spark_spread/S = new
	S.set_up(4,0,get_turf(target))
	S.start()
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	do_teleport(target, F, 0)

/mob/living/simple_animal/hostile/swarmer/proc/DismantleMachine(obj/machinery/target)
	do_attack_animation(target)
	src << "<span class='info'>We begin to dismantle this machine. We will need to be uninterrupted.</span>"
	var/obj/effect/overlay/temp/swarmer/dismantle/D = PoolOrNew(/obj/effect/overlay/temp/swarmer/dismantle, get_turf(target))
	D.pixel_x = target.pixel_x
	D.pixel_y = target.pixel_y
	D.pixel_z = target.pixel_z
	if(do_mob(src, target, 100))
		src << "<span class='info'>Dismantling complete.</span>"
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(target.loc)
		M.amount = 5
		for(var/obj/item/I in target.component_parts)
			I.loc = M.loc
		var/obj/effect/overlay/temp/swarmer/disintegration/N = PoolOrNew(/obj/effect/overlay/temp/swarmer/disintegration, get_turf(target))
		N.pixel_x = target.pixel_x
		N.pixel_y = target.pixel_y
		N.pixel_z = target.pixel_z
		target.dropContents()
		if(istype(target, /obj/machinery/computer))
			var/obj/machinery/computer/C = target
			if(C.circuit)
				C.circuit.loc = M.loc
		qdel(target)


/obj/effect/overlay/temp/swarmer //temporary swarmer visual feedback objects
	icon = 'icons/mob/swarmer.dmi'
	layer = BELOW_MOB_LAYER

/obj/effect/overlay/temp/swarmer/disintegration
	icon_state = "disintegrate"
	duration = 10

/obj/effect/overlay/temp/swarmer/disintegration/New()
	playsound(src.loc, "sparks", 100, 1)
	..()

/obj/effect/overlay/temp/swarmer/dismantle
	icon_state = "dismantle"
	duration = 25

/obj/effect/overlay/temp/swarmer/integrate
	icon_state = "integrate"
	duration = 5

/obj/structure/swarmer //Default swarmer effect object visual feedback
	name = "swarmer ui"
	desc = null
	gender = NEUTER
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "ui_light"
	layer = MOB_LAYER
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	luminosity = 1
	obj_integrity = 30
	max_integrity = 30
	anchored = 1

/obj/structure/swarmer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/Egloves.ogg', 80, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/structure/swarmer/emp_act()
	qdel(src)

/obj/structure/swarmer/trap
	name = "swarmer trap"
	desc = "A quickly assembled trap that electrifies living beings and overwhelms machine sensors. Will not retain its form if damaged enough."
	icon_state = "trap"
	obj_integrity = 10
	max_integrity = 10
	density = 0

/obj/structure/swarmer/trap/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(!istype(L, /mob/living/simple_animal/hostile/swarmer))
			playsound(loc,'sound/effects/snap.ogg',50, 1, -1)
			L.electrocute_act(0, src, 1, 1, 1)
			if(iscyborg(L))
				L.Weaken(5)
			qdel(src)
	..()

/mob/living/simple_animal/hostile/swarmer/proc/CreateTrap()
	set name = "Create trap"
	set category = "Swarmer"
	set desc = "Creates a simple trap that will non-lethally electrocute anything that steps on it. Costs 5 resources"
	if(locate(/obj/structure/swarmer/trap) in loc)
		src << "<span class='warning'>There is already a trap here. Aborting.</span>"
		return
	Fabricate(/obj/structure/swarmer/trap, 5)


/mob/living/simple_animal/hostile/swarmer/proc/CreateBarricade()
	set name = "Create barricade"
	set category = "Swarmer"
	set desc = "Creates a barricade that will stop anything but swarmers and disabler beams from passing through."
	if(locate(/obj/structure/swarmer/blockade) in loc)
		src << "<span class='warning'>There is already a blockade here. Aborting.</span>"
		return
	if(resources < 5)
		src << "<span class='warning'>We do not have the resources for this!</span>"
		return
	if(do_mob(src, src, 10))
		Fabricate(/obj/structure/swarmer/blockade, 5)


/obj/structure/swarmer/blockade
	name = "swarmer blockade"
	desc = "A quickly assembled energy blockade. Will not retain its form if damaged enough, but disabler beams and swarmers pass right through."
	icon_state = "barricade"
	luminosity = 1
	obj_integrity = 50
	max_integrity = 50

/obj/structure/swarmer/blockade/CanPass(atom/movable/O)
	if(isswarmer(O))
		return 1
	if(istype(O, /obj/item/projectile/beam/disabler))
		return 1

/mob/living/simple_animal/hostile/swarmer/proc/CreateSwarmer()
	set name = "Replicate"
	set category = "Swarmer"
	set desc = "Creates a shell for a new swarmer. Swarmers will self activate."
	src << "<span class='info'>We are attempting to replicate ourselves. We will need to stand still until the process is complete.</span>"
	if(resources < 50)
		src << "<span class='warning'>We do not have the resources for this!</span>"
		return
	if(!isturf(loc))
		src << "<span class='warning'>This is not a suitable location for replicating ourselves. We need more room.</span>"
		return
	if(do_mob(src, src, 100))
		var/createtype = SwarmerTypeToCreate()
		if(createtype && Fabricate(createtype, 50))
			playsound(loc,'sound/items/poster_being_created.ogg',50, 1, -1)


/mob/living/simple_animal/hostile/swarmer/proc/SwarmerTypeToCreate()
	return /obj/item/device/unactivated_swarmer


/mob/living/simple_animal/hostile/swarmer/proc/RepairSelf()
	set name = "Self Repair"
	set category = "Swarmer"
	set desc = "Attempts to repair damage to our body. You will have to remain motionless until repairs are complete."
	if(!isturf(loc))
		return
	src << "<span class='info'>Attempting to repair damage to our body, stand by...</span>"
	if(do_mob(src, src, 100))
		adjustHealth(-100)
		src << "<span class='info'>We successfully repaired ourselves.</span>"

/mob/living/simple_animal/hostile/swarmer/proc/ToggleLight()
	if(!luminosity)
		SetLuminosity(3)
	else
		SetLuminosity(0)

/mob/living/simple_animal/hostile/swarmer/proc/swarmer_chat(msg)
	var/rendered = "<B>Swarm communication - [src]</b> [say_quote(msg, get_spans())]"
	for(var/mob/M in mob_list)
		if(isswarmer(M))
			M << rendered
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			M << "[link] [rendered]"

/mob/living/simple_animal/hostile/swarmer/proc/ContactSwarmers()
	var/message = input(src, "Announce to other swarmers", "Swarmer contact")
	// TODO get swarmers their own colour rather than just boldtext
	if(message)
		swarmer_chat(message)
