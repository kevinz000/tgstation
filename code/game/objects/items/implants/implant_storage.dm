/obj/item/implant/storage
	name = "storage implant"
	desc = "Stores up to two big items in a bluespace pocket."
	icon_state = "storage"
	item_color = "r"

/obj/item/implant/storage/activate()
	SendSignal(COMSIG_TRY_STORAGE_SHOW, imp_in, TRUE)

/obj/item/implant/storage/removed(source, silent = 0, special = 0)
	. = ..()
	if(.)
		if(!special)
			qdel(GetComponent(/datum/component/storage/concrete/implant))

/obj/item/implant/storage/implant(mob/living/target, mob/user, silent = 0)
	for(var/X in target.implants)
		if(istype(X, type))
			var/obj/item/implant/storage/imp_e = X
			imp_e.AddComponent(/datum/component/storage/concrete/implant)
			qdel(src)
			return TRUE
	AddComponent(/datum/component/storage/concrete/implant)

	return ..()

/obj/item/implanter/storage
	name = "implanter (storage)"
	imp_type = /obj/item/implant/storage
