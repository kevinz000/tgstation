#define COMPUTER_FILE_FLAGS_DEFAULT				NONE
#define COMPUTER_FILE_FLAG_UNDELETABLE			(1<<0)			//Can not be deleted.
#define COMPUTER_FILE_FLAG_SYSTEM_INCLUDED		(1<<1)			//Included on all new computers.

#define COMPUTER_PROGRAM_FLAGS_DEFAULT			NONE
#define COMPUTER_PROGRAM_FLAG_SYSTEM_INTERNAL		(1<<0)			//Accesses a cached copy, implies undeletable
#define COMPUTER_PROGRAM_FLAG_HIDDEN_GUI			(1<<1)
#define COMPUTER_PROGRAM_FLAG_HIDDEN_TERMINAL		(1<<2)


