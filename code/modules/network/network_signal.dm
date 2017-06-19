
/datum/network_signal
	var/broadcast = FALSE
	var/source_id									//Hardware ID or "NETWORK"
	var/list/recipient_ids = list()
	var/list/text_data = list()						//Plaintext. Use this whenever possible for compatibility!
	var/list/datum/picture/picture_data = list()	//In game picture datums code/modules/paperwork/photography.dm
	var/list/audio_data = list()					//Plaintext, but meant to be used by audio devices (IE radios/recorders/audio players) and not to be readable otherwise.
	var/encryption									//Encryption [WIP]
	//Add more datatypes manually!

/datum/network_signal/proc/add_recipient(id)
	recipient_ids += ["[id]"]

/datum/network_signal/proc/remove_recipient(id)
	recipient_ids -= ["[id]"]

/datum/network_signal/proc/set_text_data_by_key(key, data)
	if(!istext(data))
		return FALSE
	text_data[key] = data
	return TRUE

/datum/network_signal/proc/add_text_data_by_key(key, data)
	if(!istext(data))
		return FALSE
	if(!text_data[key])
		return set_text_data_by_key(key, data)
	text_data[key] += data
	return TRUE

/datum/network_signal/proc/remove_text_data_by_key(key)
	if(!key || !text_data[key])
		return FALSE
	text_data -= key
	return TRUE

/datum/network_signal/proc/get_text_data_by_key(key)
	if(!key || !text_data[key])
		return FALSE
	return text_data[key]

/datum/network_signal/proc/get_all_text_data()
	. = ""
	for(var/I in text_data)
		. += "|"
		. += I
		. += " = "
		. += "\"[text_data[I]]\""

/datum/network_signal/proc/set_picture_data_by_key(key, datum/picture/picture)
	if(!istype(picture))
		return FALSE
	picture_data[key] = picture
	return TRUE

/datum/network_signal/proc/remove_picture_data_by_key(key)
	if(!key || !picture_data[key])
		return FALSE
	picture_data -= key
	return TRUE

/datum/network_signal/proc/get_picture_data_by_key(key)
	if(!key || !picture_data[key])
		return FALSE
	return picture_data[key]

/datum/network_signal/proc/get_all_picture_data()
	return picture_data

/datum/network_signal/proc/add_audio_data_by_key(key, data)
	if(!istext(data))
		return FALSE
	audio_data[key] = data
	return TRUE

/datum/network_signal/proc/remove_audio_data_by_key(key)
	if(!key || !audio_data[key])
		return FALSE
	audio_data -= key
	return TRUE

/datum/network_signal/proc/get_audio_data_by_key(key)
	if(!key || !audio_data[key])
		return FALSE
	return audio_data[key]

/datum/network_signal/proc/get_all_audio_data()
	. = ""
	for(var/I in audio_data)
		. += "|"
		. += I
		. += " = "
		. += "\"[audio_data[I]]\""
