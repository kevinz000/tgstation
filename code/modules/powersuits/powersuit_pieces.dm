
//EARS

/obj/item/device/radio/headset/powersuit
	name = "integrated earpiece"
	desc = "A radio headset modified to directly interface with a powersuit control module."
	icon_state = "
	item_state = "

/obj/item/device/radio/headset/powersuit/New()
	..()
	powersuit_module = new
	powersuit_module.attach_to_clothing(src)

/obj/item/clothing/glasses/powersuit
	name = "integrated visor"
	desc = "An advanced visor connected to a powersuit interface."
	icon_state = "
	item_state = "

/obj/item/clothing/glasses/powersuit/New()
	..()
	powersuit_module = new
	powersuit_module.attach_to_clothing(src)

/obj/item/clothing/gloves/powersuit
	name = "powered gauntlets"
	desc = "A pair of insulated gauntlets outfitted with servos."
	icon_state = "
	item_state = "

/obj/item/clothing/gloves/powersuit/New()
	..()
	powersuit_module = new
	powersuit_module.attach_to_clothing(src)

/obj/item/clothing/head/powersuit
	name = "powersuit helmet"
	desc = "An advanced helmet designed to be part of a powersuit."
	icon_state = "
	item_state = "

/obj/item/clothing/head/powersuit/New()
	..()
	powersuit_module = new
	powersuit_module.attach_to_clothing(src)

/obj/item/clothing/mask/powersuit
	name = "integrated mask"
	desc = "An integrated breathing mask as part of a powersuit, able to fit electronic modules."
	icon_state = "
	item_state = "

/obj/item/clothing/mask/powersuit/New()
	..()
	powersuit_module = new
	powersuit_module.attach_to_clothing(src)

/obj/item/clothing/shoes/powersuit
	name = "powered boots"
	desc = "A pair of boots fitted with servos and electronic equipment slots."
	icon_state = "
	item_state = "

/obj/item/clothing/boots/powersuit/New()
	..()
	powersuit_module = new
	powersuit_module.attach_to_clothing(src)

/obj/item/clothing/suit/powersuit
	name = "powered rigsuit"
	desc = "A sealable hardsuit with mounting slots for electronic equipment modules."

/obj/item/clothing/suit/powersuit/New()
	..()
	powersuit_module = new
	powersuit_module.attach_to_clothing(src)

/obj/item/clothing/under/powersuit
	name = "electronic jumpsuit"
	desc = "A jumpsuit fitted with circuitry and module slots. Not all that useful..."	//Rare appearance and probably useless.

/obj/item/clothing/under/powersuit/New()
	..()
	powersuit_module = new
	powersuit_module.attach_to_clothing(src)
