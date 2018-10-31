/datum/file_system
	var/list/datum/computer_file/files
	var/size = 512

/datum/file_system/Destroy()
	QDEL_LIST_ASSOC(files)
	return ..()

/datum/file_system/proc/add(datum/computer_file/F, force = FALSE)
	if(F.holder && F.holder != src)
		return FALSE
	if(F.size > size - get_used_size())
		return FALSE
	LAZYOR(files, F)
	F.holder = src
	return TRUE

/datum/file_system/proc/remove(datum/computer_file/F)
	if(F.holder && F.holder != src)
		return FALSE
	if(!LAZYFIND(files, F))
		return FALSE
	files -= F
	F.holder = null
	return TRUE

/datum/file_system/proc/get_used_size()
	. = 0
	for(var/i in files)
		var/datum/computer_file/F = i
		if(istype(F))
			. += F.size
