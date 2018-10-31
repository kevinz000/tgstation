/datum/computer
	var/list/filesystems

/datum/computer/Destroy()
	filesystems.Cut()
	return ..()


