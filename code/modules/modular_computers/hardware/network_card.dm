/obj/item/weapon/computer_hardware/network_card
	name = "network card"
	desc = "A basic wireless network card for usage with standard NTNet frequencies."
	power_usage = 50
	origin_tech = "programming=2;engineering=1"
	icon_state = "radio_mini"
	var/obj/item/device/network_card/ntnet/interface = /obj/item/device/network_card/ntnet/wireless/short_range
	malfunction_probability = 1
	device_type = MC_NET

/obj/item/weapon/computer_hardware/network_card/on_network_recieve(card, sig, id)
	if(holder)
		holder.on_network_recieve(card, sig, id)

/obj/item/weapon/computer_hardware/network_card/promiscious_network_recieve(card, sig, id)
	if(holder)
		holder.promiscious_network_recieve(card, sig, id)

/obj/item/weapon/computer_hardware/network_card/diagnostics(var/mob/user)
	..()
	to_chat(user, "NIX Unique ID: [interface.get_hardware_id()]")
	to_chat(user, "NIX User Tag: [interface.return_network_nickname()]")
	to_chat(user, "Supported protocols:")
	if(interface.wireless_range == NTNET_WIRELESS_RANGE_SHORT)
		to_chat(user, "511.m SFS (Subspace) - Standard Frequency Spread")
	if(interface.wireless_range == NTNET_WIRELESS_RANGE_LONG)
		to_chat(user, "511.n WFS/HB (Subspace) - Wide Frequency Spread/High Bandiwdth")
	if(interface.ethernet)
		to_chat(user, "OpenEth (Physical Connection) - Physical network connection port")

/obj/item/weapon/computer_hardware/network_card/Initialize()
	. = ..()
	interface = new interface(src)

/obj/item/weapon/computer_hardware/network_card/proc/network_send(datum/network_signal/sig)
	return interface.network_send(sig, NETWORK_ID_NTNET)

/obj/item/weapon/computer_hardware/network_card/proc/set_network_name(newname)
	return interface.set_network_nickname(newname)

// Returns a string identifier of this network card
/obj/item/weapon/computer_hardware/network_card/proc/get_network_tag()
	return interface.get_full_identifier()

/obj/item/weapon/computer_hardware/network_card/proc/get_signal()
	if(!holder) // Hardware is not installed in anything. No signal. How did this even get called?
		CRASH("NTnet network card (holder) attempted to get signal while not installed.")
		return NTNET_CONNECTION_NONE
	if(!check_functionality())
		return NTNET_CONNECTION_NONE
	return interface.return_ntnet_signal()

/obj/item/weapon/computer_hardware/network_card/proc/get_ntnet_feature(feature_flag)
	return interface.return_ntnet_feature(feature_flag)

/obj/item/weapon/computer_hardware/network_card/advanced
	name = "advanced network card"
	desc = "An advanced network card for usage with standard NTNet frequencies. Its transmitter is strong enough to connect even off-station."
	origin_tech = "programming=4;engineering=2"
	power_usage = 100 // Better range but higher power usage.
	icon_state = "radio"
	w_class = WEIGHT_CLASS_TINY
	interface = /obj/item/device/network_card/ntnet/wireless/long_range

/obj/item/weapon/computer_hardware/network_card/wired
	name = "wired network card"
	desc = "An advanced network card for usage with standard NTNet frequencies. This one also supports wired connection."
	origin_tech = "programming=5;engineering=3"
	power_usage = 100 // Better range but higher power usage.
	icon_state = "net_wired"
	w_class = WEIGHT_CLASS_NORMAL
	interface = /obj/item/device/network_card/ntnet/ethernet
