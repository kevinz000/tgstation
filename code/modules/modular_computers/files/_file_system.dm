/datum/file_system
	var/list/datum/computer_file/files
	var/size = 512
	var/used_size_cached = 0
	var/max_files = 128			//More to prevent OOMs and stuff.
	var/datum/component/computer/holder							//The PRIMARY computer on which this is "mounted".

/datum/file_system/Destroy()
	QDEL_LIST_ASSOC(files)
	return ..()

/datum/file_system/proc/add(datum/computer_file/F, force = FALSE)
	if(!istype(F))
		return FALSE
	if(LAZYLEN(files) > max_files)
		return FALSE
	if(F.holder && F.holder != src)
		return FALSE
	if(F.size > size - get_used_size())
		return FALSE
	LAZYOR(files, F)
	F.holder = src
	return TRUE

/datum/file_system/proc/remove(datum/computer_file/F)
	if(!istype(F))
		return FALSE
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
	used_size_cached = .
