
/obj/item/weapon/gun/gloo
	name = "GLOO gun"
	desc = "A recent prototype by Nanotrasen that shoots globs of sticky, fast-hardening liquid intended for patching breaches, and strengthening things temporarily. \
	Although, most reports state that people like shooting them at each other for no reason, as it's hard to run around when you're covered in GLOO..."
	icon = 'icons/obj/guns/special.dmi'
	icon_state = "gloo"
	item_state = "gloo"
	needs_permit = FALSE	//HONK
	fire_sound = //need something.
	var/glue_left = 50
	var/glue_max = 50
	var/glue_per_cartridge = 25

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
			addtimer(CALLBACK(src, ./proc/shoot_gloo, user, target, params), i * fire_delay)
			addtimer(CALLBACK(src, ./proc/reset_burstfire), burst_size * fire_delay)
	else
		semicd = TRUE
		addtimer(CALLBACK(src, ./proc/reset_semicd), fire_delay)
		shoot_gloo(user, target, params)
	if(user)
		user.update_inv_hands()
	SSblackbox.add_details("gun_fired","[src.type]")
	return TRUE

/obj/item/projectile/gloo
	name = "glob of glue"
	desc = "A glob of sticky white liquid."
	icon_state = ""

/obj/item/projectile/gloo/on_hit(atom/target)

/obj/item/projectile/gloo/proc/gloo_mob(mob/living/L)

/obj/item/projectile/gloo/proc/gloo_turf(turf/T)

/obj/item/projectile/gloo/proc/impact_object(obj/O)

/obj/item/projectile/gloo/proc/structure(turf/T)

/obj/item/gloo_canister
	name = "gloo canister"
	desc = "A canister of gloo for refilling gloo guns with."
	icon_state= ""
	item_state = "'

/obj/structure/gloo
	name = "blob of GLOO"
	desc = "A fast-hardening blob of GLOO."
	density = TRUE
	icon_state = ""
	max_integrity = 10
	obj_integrity = 10
	opacity = TRUE

/obj/structure/gloo/Initialize(mapload, duration = 1200)	//2 minutes default
	. = ..()
	QDEL_IN(src, duration)

/obj/structure/gloo/proc/harden()
	name =
	desc =
	max_integrity =
	obj_integrity =
	opactiy =


