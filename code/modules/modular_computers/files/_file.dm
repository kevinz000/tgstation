GLOBAL_DATUM_INIT

/proc/sanitize_computer_filename(text)

/proc/sanitize_computer_extension(text)

/datum/computer_file
	var/name = "Untitled"										//Name and extension are user-facing.
	var/extension = MODULAR_COMPUTERS_FILE_TYPE_DEFAULT
	var/size = 0					//Size in GQ (GigaQuads)
	var/datum/file_system/holder
	var/file_UID							//THIS MUST BE UNIQUE PER FILE. Assigned by SScomputers.
	var/_abstract_type = /datum/computer_file
	var/computer_file_flags = COMPUTER_FILE_FLAGS_DEFAULT

/datum/computer_file/New()
	file_UID = SScomputers.next_file_UID()

/datum/computer_file/Destroy()
	if(istype(holder))
		holder.remove(src)
	holder = null
	return ..()

/datum/computer_file/proc/copy()
	var/datum/computer_file/F = new type
	F.name = name
	F.size = size
	F.extension = extension
	return F

/datum/computer_file/proc/get_fs()
	return holder

/datum/computer_file/proc/get_computer_datum()
	return holder? holder.holder : null

/datum/computer_file/proc/get_computer_physical()
	return holder? (holder.holder? holder.holder.physical : null) : null

/datum/computer_file/proc/set_filename(newname)
	newname = sanitize_computer_filename(newname)
	if(!length(newname))
		return FALSE
	name = newname
	return TRUE

/datum/computer_file/proc/set_extension(new_extension)
	new_extension = sanitize_computer_extension(new_extension)
	if(!length(new_extension))
		return FALSE
	extension = new_extension
	return TRUE

/datum/computer_file/proc/get_display_name()
	return "[name].[extension]"

/*	var/

Some crap about file IDs here?

/datum/computer_file
	var/unsendable = 0										// Whether the file may be sent to someone via Exonet transfer or other means.
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