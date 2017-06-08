
/obj/item/weapon/gun/gloo
	name = "GLOO gun"
	desc = "A recent prototype by Nanotrasen that shoots globs of sticky, fast-hardening liquid intended for patching breaches, and strengthening things temporarily. \
	Although, most reports state that people like shooting them at each other for no reason, as it's hard to run around when you're covered in GLOO..."
	icon = 'icons/obj/guns/special.dmi'
	icon_state = "gloo"
	item_state = "gloo"
	needs_permit = FALSE	//HONK
	//fire_sound = //need something.
	var/glue_left = 100
	var/glue_max = 100

/obj/item/weapon/gun/gloo/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/gloo_canister))
		var/obj/item/gloo_canister/GC = I
		var/needed = glue_max - glue_left
		var/avail = GC.amount_left
		var/transferred = min(needed, avail)
		GC.amount_left -= transferred
		glue_left += transferred
		to_chat(user, "<span class='notice'>You transfer [transferred] units of GLOO from \the [I] to \the [src]</span>")
	else
		. = ..()

/obj/item/weapon/gun/gloo/examine(mob/user)
	..()
	to_chat(user, "Its ammo indicator shows [glue_left]/[glue_max].")

/obj/item/weapon/gun/gloo/can_shoot()
	if(glue_left)
		return TRUE
	return FALSE

/obj/item/weapon/gun/gloo/proc/shoot_gloo(mob/user, atom/target, params)
	glue_left--
	var/obj/item/projectile/gloo/BB = new
	BB.prepare_pixel_projectile(target, get_turf(target), user, params, 0)
	BB.firer = user
	BB.forceMove(user.loc)
	BB.fire()

/obj/item/weapon/gun/gloo/proc/reset_burstfire()
	firing_burst = FALSE

/obj/item/weapon/gun/gloo/proc/reset_semicd()
	semicd = FALSE

/obj/item/weapon/gun/gloo/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override, bonus_spread = 0)
	add_fingerprint(user)
	if(semicd)
		return
	if(!can_shoot())
		return
	user.visible_message("<span class='warning'>[user] shoots \the [src] at \the [target]!</span>")
	if(burst_size > 1)
		firing_burst = TRUE
		for(var/i = 1 to burst_size)
			addtimer(CALLBACK(src, .proc/shoot_gloo, user, target, params), i * fire_delay)
			addtimer(CALLBACK(src, .proc/reset_burstfire), burst_size * fire_delay)
	else
		semicd = TRUE
		addtimer(CALLBACK(src, .proc/reset_semicd), fire_delay)
		shoot_gloo(user, target, params)
	if(user)
		user.update_inv_hands()
	SSblackbox.add_details("gun_fired","[src.type]")
	return TRUE

/obj/item/projectile/gloo
	name = "glob of glue"
	desc = "A glob of sticky white liquid."
	icon_state = ""
	range = 8

/obj/item/projectile/gloo/on_hit(atom/target)
	gloo_hit(target)
	. = ..()

/obj/item/projectile/gloo/proc/gloo_hit(atom/target)
	set waitfor = FALSE		///Don't bog down projectile code.

/obj/item/projectile/gloo/proc/gloo_mob(mob/living/L)

/obj/item/projectile/gloo/proc/gloo_turf(turf/T)

/obj/item/projectile/gloo/proc/impact_object(obj/O)

/obj/item/projectile/gloo/proc/structure(turf/T)
	new /obj/structure/gloo_glob(T)

/obj/item/gloo_canister
	name = "gloo canister"
	desc = "A canister of gloo for refilling gloo guns with."
	icon_state= ""
	item_state = ""
	var/amount_max = 50
	var/amount_left = 50

#define GLOO_HARDEN_AMOUNT 4

/obj/structure/gloo_glob
	name = "blob of GLOO"
	desc = "A fast-hardening blob of GLOO."
	density = FALSE
	icon_state = "gloo_glob"
	max_integrity = 10
	obj_integrity = 10
	opacity = TRUE
	var/amount = 1

/obj/structure/gloo_glob/Initialize(mapload, duration = 600)	//1 minutes default
	. = ..()
	var/obj/structure/gloo_glob/GG = locate(/obj/structure/gloo_glob) in get_turf(src)
	if(istype(GG))
		if(GG.combine(src))
			. = INITIALIZE_HINT_QDEL
		else
			QDEL_IN(src, duration)

/obj/structure/gloo_glob/combine(obj/structure/gloo_glob/GG)
	if(!istype(GG))
		return FALSE
	amount++
	if(amount > GLOO_HARDEN_AMOUNT)
		harden()
		return FALSE
	if(amount == GLOO_HARDEN_AMOUNT)
		harden()
		return TRUE
	icon_state = "gloo_glob[amount]"
	return TRUE

/obj/structure/gloo_glob/proc/harden()
	//new /obj/structure/gloo_wall(get_turf(src))
	qdel(src)
