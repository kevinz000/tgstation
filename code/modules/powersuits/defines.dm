
#define POWERSUIT_PIECE_NONE 1
#define POWERSUIT_PIECE_EXOSUIT 2
#define POWERSUIT_PIECE_HEAD 3
#define POWERSUIT_PIECE_JUMPSUIT 4
#define POWERSUIT_PIECE_HANDS 5
#define POWERSUIT_PIECE_BOOTS 6
#define POWERSUIT_PIECE_EYES 7
#define POWERSUIT_PIECE_EARS 8
#define POWERSUIT_PIECE_MASK 9
#define POWERSUIT_PIECE_BELT 10
#define POWERSUIT_PIECE_BACK 11

#define POWERSUIT_CHAT_NOTICE 1
#define POWERSUIT_CHAT_WARNING 2
#define POWERSUIT_CHAT_DANGER 3
#define POWERSUIT_CHAT_FEEDBACK 4

/proc/powersuit_typedefine_to_slot(type)
	switch(type)
		if(POWERSUIT_PIECE_EXOSIUT)
			return "wear_suit"
		if(POWERSUIT_PIECE_HEAD)
			return "head"
		if(POWERSUIT_PIECE_JUMPSUIT)
			return "w_uniform"
		if(POWERSUIT_PIECE_HANDS)
			return "gloves"
		if(POWERSUIT_PIECE_BOOTS)
			return "shoes"
		if(POWERSUIT_PIECE_EYES)
			return "glasses"
		if(POWERSUIT_PIECE_EARS)
			return "ears"
		if(POWERSUIT_PIECE_MASK)
			return "wear_mask"
		if(POWERSUIT_PIECE_BELT)
			return "belt"
		if(POWERSUIT_PIECE_BACK)
			return "back"
	return null
