
/datum/component/decal/blood
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/decal/blood/Initialize(_icon, _icon_state, _dir, _cleanable=CLEAN_STRENGTH_BLOOD, _color, _layer=ABOVE_OBJ_LAYER)
	if(isitem(parent))
		return ..()
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/decal/blood/generate_appearance(_icon, _icon_state, _dir, _layer, _color)
	var/obj/item/I = parent
	if(initial(I.icon) && initial(I.icon_state))
		//try to find a pre-processed blood-splatter. otherwise, make a new one
		var/index = I.blood_splatter_index()
		var/icon/blood_splatter_icon = GLOB.blood_splatter_icons[index]
		if(!blood_splatter_icon)
			blood_splatter_icon = icon(initial(I.icon), initial(I.icon_state), , 1)		//we only want to apply blood-splatters to the initial icon_state for each object
			blood_splatter_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
			blood_splatter_icon.Blend(icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
			GLOB.blood_splatter_icons[index] = blood_splatter_icon
		pic = image(blood_splatter_icon, null, initial(I.icon_state), I.layer + 1, null)
		return TRUE
	else
		return FALSE
