/obj/item/mech_part/arm
	name = "mech arm"
	desc = "What an armful."
	icon = 'icons/mecha/parts/arms/arms_item.dmi'
	mech_icon = 'icons/mecha/parts/arms/arms_mech.dmi'

	var/has_fine_manipulation = MECH_ARM_MANIPULATION_BASIC

/obj/item/mech_part/arm/proc/has_fine_manipulation()
	return has_fine_manipulation

/obj/item/mech_part/arm/left
	name = "left mech arm"

/obj/item/mech_part/arm/right
	name = "right mech arm"
