
/obj/item/device/network_card/ntnet
	name = "\improper NTNet Networking Card"
	desc = "A network card with additional software to fully interface with Nanotrasen Networks."
	var/wireless_range = NTNET_WIRELESS_RANGE_NONE
	var/ethernet = FALSE
	var/ethernet_requires_apc = TRUE
	autoconnect_network_ids = list(NETWORK_ID_NTNET)

/obj/item/device/network_card/ntnet/all
	wireless_range = NTNET_WIRELESS_RANGE_LONG
	ethernet = TRUE

/obj/item/device/network_card/ntnet/wireless/short_range
	wireless_range = NTNET_WIRELESS_RANGE_SHORT

/obj/item/device/network_card/ntnet/wireless/long_range
	wireless_range = NTNET_WIRELESS_RANGE_LONG

/obj/item/device/network_card/ntnet/ethernet
	ethernet = TRUE

/obj/item/device/network_card/ntnet/proc/is_ethernet_connected()
	var/area/A = get_area(return_location())
	var/obj/machinery/power/apc/a = A.get_apc()
	if(istype(a))
		return TRUE
	return !ethernet_requires_apc

/obj/item/device/network_card/ntnet/proc/return_ntnet_signal()
	if(connected_networks[NETWORK_ID_NTNET])
		var/datum/network/N = connected_networks[NETWORK_ID_NTNET]
		return N.get_connection_strength_to_device(src)
	if(connect_to_network_id(NETWORK_ID_NTNET))
		return return_ntnet_signal()	//We can reconnect, try again.
	return NTNET_CONNECTION_NONE

/obj/item/device/network_card/ntnet/proc/return_ntnet_feature(featureflag)
	if(!return_ntnet_signal)
		return FALSE
	var/datum/network/ntnet/N = connected_networks[NETWORK_ID_NTNET]
	return N.check_ntnet_function(feature_flag)
