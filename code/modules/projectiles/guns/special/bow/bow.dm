/obj/item/gun/ballistic/bow
	icon = 'icons/obj/guns/projectile/bow.dmi
	icon_state = "
	item_state = "
	fire_sound = '
	mag_type = /obj/item/ammo_box/internal/bow
	recoil = 1
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 15
	attack_verbs = list("whipped", "cracked")
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	pin = /obj/item/device/firing_pin
	canMouseDown = TRUE

	//General
	var/mob/current_user

	//Processing general
	var/last_tick = 0

	//Charge/draw vars
	var/drawing = FALSE
	var/draw_current = 0
	var/draw_max = 100
	//draw_per_ds - Removed - Arrows determine this.
	//draw_slowdown - Removed - Arrows determine this. Comments for this and similar left in for reference on why it's not here.

	//Zooming vars
	var/zooming = FALSE
	var/can_zoom = TRUE
	var/current_angle = 0
	var/zoom = TRUE
	var/zoom_view_increase = 0
	var/zoom_pixel_per_draw_percent = 1
	var/zooming_angle = 0
	var/current_zoom_x = 0
	var/current_zoom_y = 0
	var/zoom_animating = 0
	var/datum/action/item_action/zoom_lock_action/zoom_lock_action

/obj/item/gun/ballistic/bow/Initialize()
	. = ..()
	if(!zoom_lock_action)
		zoom_lock_action = new(src)
	START_PROCESSING(SSfastprocess, src)

/obj/item/gun/ballistic/bow/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_NULL(zoom_lock_action)
	set_user()
	return ..()

/obj/item/gun/ballistic/bow/pickup(mob/user)
	set_user(user)
	return ..()

/obj/item/gun/ballistic/bow/equipped(mob/user, slot)
	set_user(slot == slot_hands? user : null)
	return ..()

/obj/item/gun/ballistic/bow/dropped(mob/user)
	set_user()
	return ..()

/obj/item/gun/ballistic/bow/ui_action_click(owner, action)
	zoom = !zoom
	to_chat(owner, "<span class='boldnotice'>You will now [zoom? "no longer" : ""] use [src]'s integrated sights.</span>")
	reset_zooming()

/obj/item/gun/ballistic/bow/proc/reset_zooming(mob/user)
	if(!user)
		user = current_user
	if(!user || !user.client)
		return FALSE
	zoom_animating = 0
	animate(user.client, pixel_x = 0, pixel_y = 0, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)
	zoom_current_view_increase = 0
	user.client.change_view(CONFIG_GET(string/default_view))
	zooming_angle = 0
	current_zoom_x = 0
	current_zoom_y = 0

/obj/item/gun/ballistic/bow/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(current_user) || !isturf(current_user.loc) || !(src in current_user.held_items) || current_user.incapacitated())	//Doesn't work if you're not holding it!
		if(automatic_cleanup)
			drop_arrow()
			set_user(null)
		return FALSE
	return TRUE

/obj/item/gun/ballistic/bow/proc/process_aim()
	if(istype(current_user) && current_user.client && current_user.client.mouseParams)
		var/angle = mouse_angle_from_client(current_user.client)
		switch(angle)
			if(316 to 360)
				current_user.setDir(NORTH)
			if(0 to 45)
				current_user.setDir(NORTH)
			if(46 to 135)
				current_user.setDir(EAST)
			if(136 to 225)
				current_user.setDir(SOUTH)
			if(226 to 315)
				current_user.setDir(WEST)
		current_angle = angle

/obj/item/gun/ballistic/bow/proc/set_user(mob/user)
	if(user == current_user)
		return
	stop_aiming(current_user)
	if(istype(current_user))
		LAZYREMOVE(current_user.mousemove_intercept_objects, src)
		current_user = null
	if(istype(user))
		current_user = user
		LAZYADD(current_user.mousemove_intercept_objects, src)















/obj/item/gun/energy/beam_rifle/proc/smooth_zooming(delay_override = null)
	if(!check_user() || !zooming)
		return
	if(zoom_animating && delay_override != 0)
		return smooth_zooming(zoom_animating + delay_override)	//Automatically compensate for ongoing zooming actions.
	var/total_time = SSfastprocess.wait
	if(delay_override)
		total_time = delay_override
	zoom_animating = total_time
	animate(current_user.client, pixel_x = current_zoom_x, pixel_y = current_zoom_y , total_time, SINE_EASING, ANIMATION_PARALLEL)
	zoom_animating = 0

/obj/item/gun/energy/beam_rifle/proc/set_autozoom_pixel_offsets_immediate(current_angle)
	if(zoom_lock == ZOOM_LOCK_CENTER_VIEW || zoom_lock == ZOOM_LOCK_OFF)
		return
	current_zoom_x = sin(current_angle) + sin(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_current_view_increase
	current_zoom_y = cos(current_angle) + cos(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_current_view_increase

/obj/item/gun/energy/beam_rifle/proc/handle_zooming()
	if(!zooming || !check_user())
		return
	current_user.client.change_view(world.view + zoom_target_view_increase)
	zoom_current_view_increase = zoom_target_view_increase
	set_autozoom_pixel_offsets_immediate(zooming_angle)
	smooth_zooming()

/obj/item/gun/energy/beam_rifle/proc/start_zooming()
	if(zoom_lock == ZOOM_LOCK_OFF)
		return
	zooming = TRUE

/obj/item/gun/energy/beam_rifle/proc/stop_zooming(mob/user)
	if(zooming)
		zooming = FALSE
		reset_zooming(user)



/obj/item/gun/energy/beam_rifle/update_icon()
	cut_overlays()
	var/obj/item/ammo_casing/energy/primary_ammo = ammo_type[1]
	if(cell.charge > primary_ammo.e_cost)
		add_overlay(charged_overlay)
	else
		add_overlay(drained_overlay)

/obj/item/gun/energy/beam_rifle/attack_self(mob/user)
	projectile_setting_pierce = !projectile_setting_pierce
	to_chat(user, "<span class='boldnotice'>You set \the [src] to [projectile_setting_pierce? "pierce":"impact"] mode.</span>")
	aiming_beam()

/obj/item/gun/energy/beam_rifle/proc/update_slowdown()
	if(aiming)
		slowdown = scoped_slow
	else
		slowdown = initial(slowdown)

/obj/item/gun/energy/beam_rifle/process()
	if(!aiming)
		last_process = world.time
		return
	check_user()
	handle_zooming()
	aiming_time_left = max(0, aiming_time_left - (world.time - last_process))
	aiming_beam(TRUE)
	last_process = world.time



/obj/item/gun/energy/beam_rifle/proc/start_aiming()
	aiming_time_left = aiming_time
	aiming = TRUE
	process_aim()
	aiming_beam(TRUE)
	zooming_angle = lastangle
	start_zooming()

/obj/item/gun/energy/beam_rifle/proc/stop_aiming(mob/user)
	set waitfor = FALSE
	aiming_time_left = aiming_time
	aiming = FALSE
	QDEL_LIST(current_tracers)
	stop_zooming(user)


/obj/item/gun/energy/beam_rifle/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	if(aiming)
		process_aim()
		aiming_beam()
		if(zoom_lock == ZOOM_LOCK_AUTOZOOM_FREEMOVE)
			zooming_angle = lastangle
			set_autozoom_pixel_offsets_immediate(zooming_angle)
			smooth_zooming(2)
	return ..()

/obj/item/gun/energy/beam_rifle/onMouseDown(object, location, params, mob/mob)
	if(istype(mob))
		set_user(mob)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if((object in mob.contents) || (object == mob))
		return
	start_aiming()
	return ..()

/obj/item/gun/energy/beam_rifle/onMouseUp(object, location, params, mob/M)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	process_aim()
	if(aiming_time_left <= aiming_time_fire_threshold && check_user())
		sync_ammo()
		afterattack(M.client.mouseObject, M, FALSE, M.client.mouseParams, passthrough = TRUE)
	stop_aiming()
	QDEL_LIST(current_tracers)
	return ..()

/obj/item/gun/energy/beam_rifle/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
			return
		if(target == user && user.zone_selected != "mouth") //so we can't shoot ourselves (unless mouth selected)
			return
	if(!passthrough && (aiming_time > aiming_time_fire_threshold))
		return
	if(lastfire > world.time + delay)
		return
	lastfire = world.time
	. = ..()
	stop_aiming()

/obj/item/gun/energy/beam_rifle/proc/sync_ammo()
	for(var/obj/item/ammo_casing/energy/beam_rifle/AC in contents)
		AC.sync_stats()

/obj/item/gun/energy/beam_rifle/proc/delay_penalty(amount)
	aiming_time_left = CLAMP(aiming_time_left + amount, 0, aiming_time)

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	var/wall_pierce_amount = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 1
	var/aoe_structure_damage = 30
	var/aoe_fire_range = 2
	var/aoe_fire_chance = 66
	var/aoe_mob_range = 1
	var/aoe_mob_damage = 20
	var/impact_structure_damage = 50
	var/projectile_damage = 40
	var/projectile_stun = 0
	var/structure_piercing = 2
	var/structure_bleed_coeff = 0.7
	var/do_pierce = TRUE
	var/obj/item/gun/energy/beam_rifle/host

/obj/item/ammo_casing/energy/beam_rifle/proc/sync_stats()
	var/obj/item/gun/energy/beam_rifle/BR = loc
	if(!istype(BR))
		stack_trace("Beam rifle syncing error")
	host = BR
	do_pierce = BR.projectile_setting_pierce
	wall_pierce_amount = BR.wall_pierce_amount
	wall_devastate = BR.wall_devastate
	aoe_structure_range = BR.aoe_structure_range
	aoe_structure_damage = BR.aoe_structure_damage
	aoe_fire_range = BR.aoe_fire_range
	aoe_fire_chance = BR.aoe_fire_chance
	aoe_mob_range = BR.aoe_mob_range
	aoe_mob_damage = BR.aoe_mob_damage
	impact_structure_damage = BR.impact_structure_damage
	projectile_damage = BR.projectile_damage
	projectile_stun = BR.projectile_stun
	delay = BR.delay
	structure_piercing = BR.structure_piercing
	structure_bleed_coeff = BR.structure_bleed_coeff

/obj/item/ammo_casing/energy/beam_rifle/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	. = ..()
	var/obj/item/projectile/beam/beam_rifle/hitscan/HS_BB = BB
	if(!istype(HS_BB))
		return
	HS_BB.impact_direct_damage = projectile_damage
	HS_BB.stun = projectile_stun
	HS_BB.impact_structure_damage = impact_structure_damage
	HS_BB.aoe_mob_damage = aoe_mob_damage
	HS_BB.aoe_mob_range = CLAMP(aoe_mob_range, 0, 15)				//Badmin safety lock
	HS_BB.aoe_fire_chance = aoe_fire_chance
	HS_BB.aoe_fire_range = aoe_fire_range
	HS_BB.aoe_structure_damage = aoe_structure_damage
	HS_BB.aoe_structure_range = CLAMP(aoe_structure_range, 0, 15)	//Badmin safety lock
	HS_BB.wall_devastate = wall_devastate
	HS_BB.wall_pierce_amount = wall_pierce_amount
	HS_BB.structure_pierce_amount = structure_piercing
	HS_BB.structure_bleed_coeff = structure_bleed_coeff
	HS_BB.do_pierce = do_pierce
	HS_BB.gun = host

/obj/item/ammo_casing/energy/beam_rifle/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	var/turf/curloc = get_turf(user)
	if(!istype(curloc) || !BB)
		return FALSE
	var/obj/item/gun/energy/beam_rifle/gun = loc
	if(!targloc && gun)
		targloc = get_turf_in_angle(gun.lastangle, curloc, 10)
	else if(!targloc)
		return FALSE
	var/firing_dir
	if(BB.firer)
		firing_dir = BB.firer.dir
	if(!BB.suppressed && firing_effect_type)
		new firing_effect_type(get_turf(src), firing_dir)
	BB.preparePixelProjectile(target, user, params, spread)
	BB.fire(gun? gun.lastangle : null, null)
	BB = null
	return TRUE

/obj/item/ammo_casing/energy/beam_rifle/hitscan
	projectile_type = /obj/item/projectile/beam/beam_rifle/hitscan
	select_name = "beam"
	e_cost = 5000
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/item/projectile/beam/beam_rifle
	name = "particle beam"
	icon = ""
	hitsound = 'sound/effects/explosion3.ogg'
	damage = 0				//Handled manually.
	damage_type = BURN
	flag = "energy"
	range = 150
	jitter = 10
	var/obj/item/gun/energy/beam_rifle/gun
	var/structure_pierce_amount = 0				//All set to 0 so the gun can manually set them during firing.
	var/structure_bleed_coeff = 0
	var/structure_pierce = 0
	var/do_pierce = TRUE
	var/wall_pierce_amount = 0
	var/wall_pierce = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 0
	var/aoe_structure_damage = 0
	var/aoe_fire_range = 0
	var/aoe_fire_chance = 0
	var/aoe_mob_range = 0
	var/aoe_mob_damage = 0
	var/impact_structure_damage = 0
	var/impact_direct_damage = 0
	var/turf/cached
	var/list/pierced = list()

/obj/item/projectile/beam/beam_rifle/proc/AOE(turf/epicenter)
	set waitfor = FALSE
	if(!epicenter)
		return
	new /obj/effect/temp_visual/explosion/fast(epicenter)
	for(var/mob/living/L in range(aoe_mob_range, epicenter))		//handle aoe mob damage
		L.adjustFireLoss(aoe_mob_damage)
		to_chat(L, "<span class='userdanger'>\The [src] sears you!</span>")
	for(var/turf/T in range(aoe_fire_range, epicenter))		//handle aoe fire
		if(prob(aoe_fire_chance))
			new /obj/effect/hotspot(T)
	for(var/obj/O in range(aoe_structure_range, epicenter))
		if(!isitem(O))
			if(O.level == 1)	//Please don't break underfloor items!
				continue
			O.take_damage(aoe_structure_damage * get_damage_coeff(O), BURN, "laser", FALSE)

/obj/item/projectile/beam/beam_rifle/proc/check_pierce(atom/target)
	if(!do_pierce)
		return FALSE
	if(pierced[target])		//we already pierced them go away
		forceMove(get_turf(target))
		return TRUE
	if(isclosedturf(target))
		if(wall_pierce++ < wall_pierce_amount)
			forceMove(target)
			if(prob(wall_devastate))
				if(iswallturf(target))
					var/turf/closed/wall/W = target
					W.dismantle_wall(TRUE, TRUE)
				else
					target.ex_act(EXPLODE_HEAVY)
			return TRUE
	if(ismovableatom(target))
		var/atom/movable/AM = target
		if(AM.density && !AM.CanPass(src, get_turf(target)) && !ismob(AM))
			if(structure_pierce < structure_pierce_amount)
				if(isobj(AM))
					var/obj/O = AM
					O.take_damage((impact_structure_damage + aoe_structure_damage) * structure_bleed_coeff * get_damage_coeff(AM), BURN, "energy", FALSE)
				pierced[AM] = TRUE
				forceMove(AM.drop_location())
				structure_pierce++
				return TRUE
	return FALSE

/obj/item/projectile/beam/beam_rifle/proc/get_damage_coeff(atom/target)
	if(istype(target, /obj/machinery/door))
		return 0.4
	if(istype(target, /obj/structure/window))
		return 0.5
	return 1

/obj/item/projectile/beam/beam_rifle/proc/handle_impact(atom/target)
	if(isobj(target))
		var/obj/O = target
		O.take_damage(impact_structure_damage * get_damage_coeff(target), BURN, "laser", FALSE)
	if(isliving(target))
		var/mob/living/L = target
		L.adjustFireLoss(impact_direct_damage)
		L.emote("scream")

/obj/item/projectile/beam/beam_rifle/proc/handle_hit(atom/target)
	set waitfor = FALSE
	if(!cached && !QDELETED(target))
		cached = get_turf(target)
	if(nodamage)
		return FALSE
	playsound(cached, 'sound/effects/explosion3.ogg', 100, 1)
	AOE(cached)
	if(!QDELETED(target))
		handle_impact(target)

/obj/item/projectile/beam/beam_rifle/Collide(atom/target)
	if(check_pierce(target))
		permutated += target
		return FALSE
	if(!QDELETED(target))
		cached = get_turf(target)
	. = ..()

/obj/item/projectile/beam/beam_rifle/on_hit(atom/target, blocked = FALSE)
	if(!QDELETED(target))
		cached = get_turf(target)
	handle_hit(target)
	. = ..()

/obj/item/projectile/beam/beam_rifle/hitscan
	icon_state = ""
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/tracer/beam_rifle
	var/constant_tracer = FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/generate_hitscan_tracers(cleanup = TRUE, duration = 5, highlander)
	set waitfor = FALSE
	if(isnull(highlander))
		highlander = constant_tracer
	if(highlander && istype(gun))
		QDEL_LIST(gun.current_tracers)
		for(var/datum/point/p in beam_segments)
			gun.current_tracers += generate_tracer_between_points(p, beam_segments[p], tracer_type, color, 0)
	else
		for(var/datum/point/p in beam_segments)
			generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration)
	if(cleanup)
		QDEL_LIST(beam_segments)
		beam_segments = null
		QDEL_NULL(beam_index)

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam
	tracer_type = /obj/effect/projectile/tracer/tracer/aiming
	name = "aiming beam"
	hitsound = null
	hitsound_wall = null
	nodamage = TRUE
	damage = 0
	constant_tracer = TRUE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/prehit(atom/target)
	qdel(src)
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/on_hit()
	qdel(src)
	return FALSE
