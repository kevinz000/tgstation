PROCESSING_SUBSYSTEM_DEF(computers)
	name = "Computers"
	wait = 1
	stat_tag = "COMP"
	flags = SS_KEEP_TIMING
	priority = FIRE_PRIORITY_COMPUTERS
	init_order = INIT_ORDER_COMPUTERS
	var/static/next_file_id = 0
	var/static/next_terminal_id = 0

	var/static/list/datum/computer/computers = list()

/datum/controller/subsystem/processing/computers/proc/next_file_UID()
	return "[num2text(next_file_id++)]"

/datum/controller/subsystem/processing/computers/proc/next_terminal_id()
	return "[num2text(next_termianl_id++)]"

/datum/controller/subsystem/processing/computers/proc/add_computer(datum/computer/C)
	START_PROCESSING(src, C)
	computers |= C

/datum/controller/subsystem/processing/computers/proc/remove_computer(datum/computer/C)
	STOP_PROCESSING(src, C)
	computers -= C





/*	var/static/next_hardware_ID = HID_RESTRICTED_END
	//var/static/next_file_ID = FID_RESTRICTED_END

/datum/controller/subsystem/processing/computers/proc/get_next_HID()
	var/string = "[num2text(assignment_hardware_id++, 12)]"
	return make_address(string)

/datum/controller/subsystem/processing/computers/proc/make_address(string)
	if(!string)
		return resolve_collisions? make_address("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]"):null
	var/hex = md5(string)
	if(!hex)
		return		//errored
	. = "[copytext(hex, 1, 9)]"		//16 ^ 8 possibilities I think.
	if(interfaces_by_id[.])
		return resolve_collisions? make_address("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]"):null
*/
