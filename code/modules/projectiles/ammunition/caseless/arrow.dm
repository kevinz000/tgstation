/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stabby Stabman!"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "arrow"
	flags_1 = NONE
	throwforce = 1			//Pokey poke!
	//fire_sound = ''
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	firing_effect_type = null
	caliber = "arrow"
	heavy_metal = FALSE

	var/drawn_weight = 80
	var/drawn_percent = 0.8

	//Arrow stats
	var/arrow_draw_weight_min = 30		//Minimum draw. Any less than this and it will just fall down.
	var/arrow_draw_weight_max = 100		//Maximum draw. Full strength!
	var/damage_min = 10					//Damage at minimum draw.
	var/damage_max = 25					//Damage at maximum draw.
	var/speed_min = 1					//Speed at minimum draw.
	var/speed_max = 0.75				//Speed at maximum draw.

/obj/item/ammo_casing/caseless/arrow/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, firing_object)
	var/obj/item/gun/ballistic/bow/B = firing_object
	if(istype(B))
		drawn_weight = B.draw_current
		calculate_draw_percentage(drawn_weight)
	return ..()

/obj/item/ammo_casing/caseless/arrow/proc/calculate_draw_percentage(arrow_draw_weight)
	if(isnull(arrow_draw_weight))
		arrow_draw_weight = drawn_weight
	var/draw_percentage = 0.80
	if(arrow_draw_weight < arrow_draw_weight_min)
		draw_percentage = 0.00
		. = drawn_percent = draw_percentage
	else if(arrow_draw_weight_min == arrow_draw_weight_max)		//No dividing by zero this time.
		draw_percentage = 1.00
		. = drawn_percent = draw_percentage
	else
		draw_percentage = arrow_draw_weight / (arrow_draw_weight_max - arrow_draw_weight_min)
		. = drawn_percent = draw_percentage

/obj/item/ammo_casing/caseless/arrow/proc/ready_arrow(obj/item/projectile/bullet/reusable/arrow/A)
	if(!istype(A))
		return
	A.damage = damage_min + (damage_max - damage_min) * drawn_percent
	A.speed = speed_min + (speed_max - speed_min) * drawn_percent

/obj/item/ammo_casing/caseless/arrow/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	if(!BB)
		return ..()
	ready_arrow(BB)
	return ..()
