//Status effects are used to apply temporary or permanent effects to mobs. Mobs are aware of their status effects at all times.
//This file contains their code, plus code for applying and removing them.
//When making a new status effect, add a define to status_effects.dm in __DEFINES for ease of use!

/datum/status_effect
	var/id = "effect"			//Used for screen alerts, and making the status effect unique. Do not change at runtime.
	var/duration = -1 //How long the status effect lasts in DECISECONDS. Enter -1 for an effect that never ends unless removed through some means.
	var/tick_interval = 10 //How many deciseconds between ticks, approximately. Leave at 10 for every second.
	var/mob/living/owner //The mob affected by the status effect.
	var/status_type = STATUS_EFFECT_UNIQUE //How many of the effect can be on one mob, and what happens when you try to add another
	var/on_remove_on_mob_delete = FALSE //if we call on_remove() when the mob is deleted
	var/alert_type = /obj/screen/alert/status_effect //the alert thrown by the status effect, contains name and description
	var/obj/screen/alert/status_effect/linked_alert = null //the alert itself, if it exists

/datum/status_effect/New(list/arguments)
	on_creation(arglist(arguments))

/datum/status_effect/proc/_on_creation(mob/living/new_owner, ...)
	if(new_owner)
		owner = new_owner
	if(owner)
		LAZYINITLIST(owner.status_effects)
		LAZYINITLIST(owner.status_effects[id])
		LAZYADD(owner.status_effects[id], src)
	if(!owner || !on_apply())
		qdel(src)
		return
	if(duration != -1)
		duration = world.time + duration
	tick_interval = world.time + tick_interval
	if(alert_type)
		var/obj/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
		A.attached_effect = src //so the alert can reference us, if it needs to
		linked_alert = A //so we can reference the alert, if we need to
	START_PROCESSING(SSfastprocess, src)
	return TRUE

/datum/status_effect/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		owner.clear_alert(id)
		LAZYREMOVE(owner.status_effects[id], src)
		UNSETEMPTY(owner.status_effects[id])
		UNSETEMPTY(owner.status_effects)
		on_remove()
		owner = null
	return ..()

/datum/status_effect/process()
	if(!owner)
		qdel(src)
		return
	if(tick_interval < world.time)
		tick()
		tick_interval = world.time + initial(tick_interval)
	if(duration != -1 && duration < world.time)
		qdel(src)

/datum/status_effect/proc/on_apply() //Called whenever the buff is applied; returning FALSE will cause it to autoremove itself.
	return TRUE
/datum/status_effect/proc/tick() //Called every tick.
/datum/status_effect/proc/on_remove() //Called whenever the buff expires or is removed; do note that at the point this is called, it is out of the owner's status_effects but owner is not yet null
/datum/status_effect/proc/_be_replaced() //Called instead of on_remove when a status effect is replaced by itself or when a status effect with on_remove_on_mob_delete = FALSE has its mob deleted
	owner.clear_alert(id)
	LAZYREMOVE(owner.status_effects[id], src)
	UNSETEMPTY(owner.status_effects[id])
	UNSETEMPTY(owner.status_effects)
	owner = null
	qdel(src)

////////////////
// ALERT HOOK //
////////////////

/obj/screen/alert/status_effect
	name = "Curse of Mundanity"
	desc = "You don't feel any different..."
	var/datum/status_effect/attached_effect

//////////////////
// HELPER PROCS //
//////////////////

/mob/living/proc/_apply_status_effect(effect, ...) //applies a given status effect to this mob, returning the effect if it was successful
	. = FALSE
	var/datum/status_effect/S1 = effect
	LAZYINITLIST(status_effects)
	LAZYINITLIST(status_effects[S1.ID])
	if(length(status_effects[S1.ID]))
		var/datum/status_effect/S = status_effects[S1.ID][1]
		if(S.status_type)
			if(S.status_type == STATUS_EFFECT_REPLACE)
				S.be_replaced()
			else
				return
	var/list/arguments = args.Copy()
	arguments[1] = src
	S1 = new effect(arguments)
	. = S1

/mob/living/proc/_remove_status_effect(effect) //removes all of a given status effect from this mob, returning TRUE if at least one was removed
	. = FALSE
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects[S1.id])
			qdel(S)
			. = TRUE

/mob/living/proc/_has_status_effect(effect) //returns the effect if the mob calling the proc owns the given status effect
	. = FALSE
	if(status_effects)
		var/datum/status_effect/S1 = effect
		if(!status_effects[S1.id])
			return
		for(var/s in status_effects[S1.id])
			var/datum/status_effect/S = s
			if(initial(S1.id) == S.id)
				return S

/mob/living/proc/_has_status_effect_list(effect) //returns a list of effects with matching IDs that the mod owns; use for effects there can be multiple of
	. = list()
	if(status_effects)
		var/datum/status_effect/S1 = effect
		if(!status_effects[S1.id])
			return
		for(var/s in status_effects)
			var/datum/status_effect/S = s
			if(initial(S1.id) == S.id)
				. += S
