/datum/computer_file
	var/name = "Untitled"
	var/extension = MODULAR_COMPUTERS_FILE_TYPE_DEFAULT
	var/size = 0					//Size in GQ (GigaQuads)
	var/datum/file_system/holder

/datum/computer_file/Destroy()
	if(istype(holder))
		holder.remove(src)
	holder = null
	return ..()

/*	var/

Some crap about file IDs here?

/datum/computer_file
	var/unsendable = 0										// Whether the file may be sent to someone via NTNet transfer or other means.
	var/undeletable = 0										// Whether the file may be deleted. Setting to 1 prevents deletion/renaming/etc.

/datum/computer_file/New()
	..()
	uid = file_uid++

/datum/computer_file/Destroy()
	if(!holder)
		return ..()

	holder.remove_file(src)
	// holder.holder is the computer that has drive installed. If we are Destroy()ing program that's currently running kill it.
	if(holder.holder && holder.holder.active_program == src)
		holder.holder.kill_program(forced = TRUE)
	holder = null
	return ..()

// Returns independent copy of this file.
/datum/computer_file/proc/clone(rename = 0)
	var/datum/computer_file/temp = new type
	temp.unsendable = unsendable
	temp.undeletable = undeletable
	temp.size = size
	if(rename)
		temp.filename = filename + "(Copy)"
	else
		temp.filename = filename
	temp.filetype = filetype
	return temp*/