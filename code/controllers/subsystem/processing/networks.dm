
PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = 40
	wait = 2
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

/datum/controller/subsystem/processing/networks/Initialize()
	initialize_global_network_list()
