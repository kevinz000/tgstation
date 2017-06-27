/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

*/

/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/weapon/circuitboard/computer/rdconsole
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/rnd/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/rnd/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/rnd/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	req_access = list(GLOB.access_tox)	//Data and setting manipulation requires scientist access.

	var/selected_category
	var/list/datum/design/matching_designs = list() //for the search function
	var/disk_slot_selected = 0
	var/datum/techweb_node/selected_node
	var/datum/design/selected_design
	var/locked = FALSE

/proc/CallMaterialName(ID)
	if (copytext(ID, 1, 2) == "$" && GLOB.materials_list[ID])
		var/datum/material/material = GLOB.materials_list[ID]
		return material.name

	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return "ERROR: Report This"

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/rnd/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/rnd/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src

/obj/machinery/computer/rdconsole/Initialize()
	. = ..()
	stored_research = SSresearch.science_tech
	matching_designs = list()
	if(!id)
		fix_noid_research_servers()
	SyncRDevices()

/obj/machinery/computer/rdconsole/attackby(obj/item/weapon/D, mob/user, params)

	//Loading a disk into it.
	if(istype(D, /obj/item/weapon/disk))
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/weapon/disk/tech_disk))
			t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk))
			d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		if(!user.drop_item())
			return
		D.loc = src
		to_chat(user, "<span class='notice'>You add the disk to the machine!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		. = ..()
	updateUsrDialog()

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	CRASH("RESEARCH NODE NOT CODED!")

/obj/machinery/computer/rdconsole/on_deconstruction()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	..()


/obj/machinery/computer/rdconsole/emag_act(mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")

/*
/obj/machinery/computer/rdconsole/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)

	if(href_list["disk_slot"])
		disk_slot_selected = text2num(href_list["disk_slot"])

	if(href_list["category"])
		selected_category = href_list["category"]

	else if(href_list["updt_tech"]) //Update the research holder with information from the technology disk.
		screen = SCICONSOLE_UPDATE_DATABASE
		var/wait = 50
		spawn(wait)
			screen = SCICONSOLE_TDISK
			if(t_disk)
				t_disk.stored_research.copy_research_to(stored_research)
				updateUsrDialog()
	else if(href_list["clear_tech"]) //Erase data on the technology disk.
		if(t_disk)
			qdel(t_disk.stored_research)
			t_disk.stored_research = new
	else if(href_list["eject_tech"]) //Eject the technology disk.
		if(t_disk)
			t_disk.loc = src.loc
			t_disk = null
		screen = SCICONSOLE_MENU

	else if(href_list["copy_tech"]) //Copy some technology data from the research holder to the disk.
		stored_research.copy_research_to(t_disk.stored_research)
		screen = SCICONSOLE_TDISK
	else if(href_list["updt_design"]) //Updates the research holder with design data from the design disk.
		var/n = text2num(href_list["updt_design"])
		screen = SCICONSOLE_UPDATE_DATABASE
		var/wait = 50
		if(!n)
			wait = 0
			for(var/D in d_disk.blueprints)
				if(D)
					wait += 50
		spawn(wait)
			screen = SCICONSOLE_DDISK
			if(d_disk)
				if(!n)
					for(var/D in d_disk.blueprints)
						if(D)
							stored_research.add_design(D)
				else
					stored_research.add_design(d_disk.blueprints[n])
				updateUsrDialog()

	else if(href_list["clear_design"]) //Erases data on the design disk.
		if(d_disk)
			var/n = text2num(href_list["clear_design"])
			if(!n)
				for(var/i in 1 to d_disk.max_blueprints)
					d_disk.blueprints[i] = null
			else
				d_disk.blueprints[n] = null

	else if(href_list["eject_design"]) //Eject the design disk.
		if(d_disk)
			d_disk.loc = src.loc
			d_disk = null
		screen = SCICONSOLE_MENU

	else if(href_list["copy_design"]) //Copy design data from the research holder to the design disk.
		var/slot = text2num(href_list["copy_design"])
		var/datum/design/D = stored_research.researched_designs[href_list["copy_design_ID"]]
		if(D)
			var/autolathe_friendly = 1
			if(D.reagents_list.len)
				autolathe_friendly = 0
				D.category -= "Imported"
			else
				for(var/x in D.materials)
					if( !(x in list(MAT_METAL, MAT_GLASS)))
						autolathe_friendly = 0
						D.category -= "Imported"

			if(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)) // Specifically excludes circuit imprinter and mechfab
				D.build_type = autolathe_friendly ? (D.build_type | AUTOLATHE) : D.build_type
				D.category |= "Imported"
			d_disk.blueprints[slot] = D
		screen = SCICONSOLE_DDISK

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				to_chat(usr, "<span class='danger'>The destructive analyzer is busy at the moment.</span>")

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.forceMove(linked_destroy.loc)
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = SCICONSOLE_MENU

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(!linked_destroy || linked_destroy.busy || !linked_destroy.loaded_item)
			updateUsrDialog()
			return
		var/choice = input("Are you sure you want to destroy [linked_destroy.loaded_item.name]?") in list("Proceed", "Cancel")
		if(choice == "Cancel" || !linked_destroy || !linked_destroy.loaded_item)
			return
		linked_destroy.busy = 1
		screen = SCICONSOLE_UPDATE_DATABASE
		updateUsrDialog()
		flick("d_analyzer_process", linked_destroy)
		spawn(24)
			stored_research.boost_with_path(SSresearch.techweb_nodes[href_list["destroy"]], linked_destroy.loaded_item.type)
			if(linked_destroy)
				linked_destroy.busy = 0
				if(!linked_destroy.loaded_item)
					screen = SCICONSOLE_MENU
					return
				//TODO: Add boost checking.
				if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
					for(var/material in linked_destroy.loaded_item.materials)
						linked_lathe.materials.insert_amount(min((linked_lathe.materials.max_amount - linked_lathe.materials.total_amount), (linked_destroy.loaded_item.materials[material]*(linked_destroy.decon_mod/10))), material)
					SSblackbox.add_details("item_deconstructed","[linked_destroy.loaded_item.type]")
				linked_destroy.loaded_item = null
				for(var/obj/I in linked_destroy.contents)
					for(var/mob/M in I.contents)
						M.death()
					if(istype(I,/obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
						var/obj/item/stack/sheet/S = I
						if(S.amount > 1)
							S.amount--
							linked_destroy.loaded_item = S
						else
							qdel(S)
							linked_destroy.icon_state = "d_analyzer"
					else
						if(!(I in linked_destroy.component_parts))
							qdel(I)
							linked_destroy.icon_state = "d_analyzer"
			screen = SCICONSOLE_MENU
			use_power(250)
			updateUsrDialog()

	else if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(src.allowed(usr))
			screen = text2num(href_list["lock"])
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["build"]) //Causes the Protolathe to build something.
		var/datum/design/being_built = stored_research.researched_designs[href_list["build"]]
		var/amount = text2num(href_list["amount"])

		if(being_built.make_reagents.len)
			return FALSE

		if(!linked_lathe || !being_built || !amount)
			updateUsrDialog()
			return

		if(linked_lathe.busy)
			to_chat(usr, "<span class='danger'>Protolathe is busy at the moment.</span>")
			return

		var/coeff = linked_lathe.efficiency_coeff
		var/power = 1000
		var/old_screen = screen

		amount = max(1, min(10, amount))
		for(var/M in being_built.materials)
			power += round(being_built.materials[M] * amount / 5)
		power = max(3000, power)
		screen = SCICONSOLE_UPDATE_PROTOLATHE
		var/key = usr.key	//so we don't lose the info during the spawn delay
		if (!(being_built.build_type & PROTOLATHE))
			message_admins("Protolathe exploit attempted by [key_name(usr, usr.client)]!")
			updateUsrDialog()
			return

		var/g2g = 1
		var/enough_materials = 1
		linked_lathe.busy = 1
		flick("protolathe_n",linked_lathe)
		use_power(power)

		var/list/efficient_mats = list()
		for(var/MAT in being_built.materials)
			efficient_mats[MAT] = being_built.materials[MAT]*coeff

		if(!linked_lathe.materials.has_materials(efficient_mats, amount))
			linked_lathe.say("Not enough materials to complete prototype.")
			enough_materials = 0
			g2g = 0
		else
			for(var/R in being_built.reagents_list)
				if(!linked_lathe.reagents.has_reagent(R, being_built.reagents_list[R]*coeff))
					linked_lathe.say("Not enough reagents to complete prototype.")
					enough_materials = 0
					g2g = 0

		if(enough_materials)
			linked_lathe.materials.use_amount(efficient_mats, amount)
			for(var/R in being_built.reagents_list)
				linked_lathe.reagents.remove_reagent(R, being_built.reagents_list[R]*coeff)

		var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.

		coeff *= being_built.lathe_time_factor

		spawn(32*coeff*amount**0.8)
			if(linked_lathe)
				if(g2g) //And if we only fail the material requirements, we still spend time and power
					var/already_logged = 0
					for(var/i = 0, i<amount, i++)
						var/obj/item/new_item = new P(src)
						if( new_item.type == /obj/item/weapon/storage/backpack/holding )
							new_item.investigate_log("built by [key]", INVESTIGATE_SINGULO)
						if(!istype(new_item, /obj/item/stack/sheet) && !istype(new_item, /obj/item/weapon/ore/bluespace_crystal)) // To avoid materials dupe glitches
							new_item.materials = efficient_mats.Copy()
						new_item.loc = linked_lathe.loc
						if(!already_logged)
							SSblackbox.add_details("item_printed","[new_item.type]|[amount]")
							already_logged = 1
				screen = old_screen
				linked_lathe.busy = 0
			else
				say("Protolathe connection failed. Production halted.")
				screen = SCICONSOLE_MENU
			updateUsrDialog()

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		var/datum/design/being_built = stored_research.researched_designs[href_list["imprint"]]

		if(!linked_imprinter || !being_built)
			updateUsrDialog()
			return

		if(linked_imprinter.busy)
			to_chat(usr, "<span class='danger'>Circuit Imprinter is busy at the moment.</span>")
			updateUsrDialog()
			return

		var/coeff = linked_imprinter.efficiency_coeff

		var/power = 1000
		var/old_screen = screen
		for(var/M in being_built.materials)
			power += round(being_built.materials[M] / 5)
		power = max(4000, power)
		screen = SCICONSOLE_UPDATE_CIRCUIT
		if (!(being_built.build_type & IMPRINTER))
			message_admins("Circuit imprinter exploit attempted by [key_name(usr, usr.client)]!")
			updateUsrDialog()
			return

		var/g2g = 1
		var/enough_materials = 1
		linked_imprinter.busy = 1
		flick("circuit_imprinter_ani", linked_imprinter)
		use_power(power)

		var/list/efficient_mats = list()
		for(var/MAT in being_built.materials)
			efficient_mats[MAT] = being_built.materials[MAT]/coeff

		if(!linked_imprinter.materials.has_materials(efficient_mats))
			linked_imprinter.say("Not enough materials to complete prototype.")
			enough_materials = 0
			g2g = 0
		else
			for(var/R in being_built.reagents_list)
				if(!linked_imprinter.reagents.has_reagent(R, being_built.reagents_list[R]/coeff))
					linked_imprinter.say("Not enough reagents to complete prototype.")
					enough_materials = 0
					g2g = 0

		if(enough_materials)
			linked_imprinter.materials.use_amount(efficient_mats)
			for(var/R in being_built.reagents_list)
				linked_imprinter.reagents.remove_reagent(R, being_built.reagents_list[R]/coeff)

		var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.
		spawn(16)
			if(linked_imprinter)
				if(g2g)
					var/obj/item/new_item = new P(src)
					new_item.loc = linked_imprinter.loc
					new_item.materials = efficient_mats.Copy()
					SSblackbox.add_details("circuit_printed","[new_item.type]")
				screen = old_screen
				linked_imprinter.busy = 0
			else
				say("Circuit Imprinter connection failed. Production halted.")
				screen = SCICONSOLE_MENU
			updateUsrDialog()

	//Protolathe Materials
	else if(href_list["disposeP"] && linked_lathe)  //Causes the protolathe to dispose of a single reagent (all of it)
		linked_lathe.reagents.del_reagent(href_list["disposeP"])

	else if(href_list["disposeallP"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.reagents.clear_reagents()

	else if(href_list["ejectsheet"] && linked_lathe) //Causes the protolathe to eject a sheet of material
		linked_lathe.materials.retrieve_sheets(text2num(href_list["eject_amt"]), href_list["ejectsheet"])

	//Circuit Imprinter Materials
	else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		linked_imprinter.reagents.del_reagent(href_list["disposeI"])

	else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
		linked_imprinter.reagents.clear_reagents()

	else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the imprinter to eject a sheet of material
		linked_imprinter.materials.retrieve_sheets(text2num(href_list["eject_amt"]), href_list["imprinter_ejectsheet"])


	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		screen = SCICONSOLE_UPDATE_DATABASE
		spawn(20)
			SyncRDevices()
			screen = SCICONSOLE_LINKING
			updateUsrDialog()

	else if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter = null

	else if(href_list["search"]) //Search for designs with name matching pattern
		var/compare

		matching_designs.Cut()

		if(href_list["type"] == "proto")
			compare = PROTOLATHE
			screen = SCICONSOLE_PROTOLATHE_SEARCH
		else
			compare = IMPRINTER
			screen = SCICONSOLE_CIRCUIT_SEARCH

		for(var/v in stored_research.researched_designs)
			var/datum/design/D = stored_research.researched_designs[v]
			if(!(D.build_type & compare))
				continue
			if(findtext(D.name,href_list["to_search"]))
				matching_designs.Add(D)
////////////////////////////////////////////////////////////	switch(screen)
		//////////////////////R&D CONSOLE SCREENS//////////////////
		if(SCICONSOLE_UPDATE_DATABASE)
			dat += "<div class='statusDisplay'>Processing and Updating Database...</div>"
		if(SCICONSOLE_LOCKED)
			dat += "<div class='statusDisplay'>SYSTEM LOCKED</div>"
			dat += "<A href='?src=\ref[src];lock=SCICONSOLE_SETTINGS'>Unlock</A>"
		if(SCICONSOLE_UPDATE_PROTOLATHE)
			dat += "<div class='statusDisplay'>Constructing Prototype. Please Wait...</div>"
		if(SCICONSOLE_UPDATE_CIRCUIT)
			dat += "<div class='statusDisplay'>Imprinting Circuit. Please Wait...</div>"
			dat += "</div>"
		if(SCICONSOLE_TDISK) //Technology Disk Menu
			dat += SCICONSOLE_HEADER
			dat += "Disk Operations: <A href='?src=\ref[src];clear_tech=0'>Clear Disk</A>"
			dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A>"
			dat += "<A href='?src=\ref[src];updt_tech=0'>Upload All</A>"
			dat += "<A href='?src=\ref[src];copy_tech=1'>Load Technology to Disk</A>"
			dat += "<div class='statusDisplay'><h3>Stored Technology Nodes:</h3>"
			for(var/i in t_disk.stored_research.researched_nodes)
				var/datum/techweb_node/N = t_disk.stored_research.researched_nodes[i]
				dat += "<A href='?src=\ref[src];view_node=[i];back_screen=[screen]'>[N.display_name]</A>"
			dat += "</div>"

		if(SCICONSOLE_DDISK) //Design Disk menu.
			dat += SCICONSOLE_HEADER
			dat += "Disk Operations: <A href='?src=\ref[src];clear_design=0'>Clear Disk</A><A href='?src=\ref[src];updt_design=0'>Upload All</A><A href='?src=\ref[src];eject_design=1'>Eject Disk</A>"
			for(var/i in 1 to d_disk.max_blueprints)
				dat += "<div class='statusDisplay'>"
				if(d_disk.blueprints[i])
					var/datum/design/D = d_disk.blueprints[i]
					dat += "<A href='?src=\ref[src];view_design=[D.id]'>[D.name]</A>"
					dat += "Operations: <A href='?src=\ref[src];updt_design=[i]'>Upload to Database</A> <A href='?src=\ref[src];clear_design=[i]'>Clear Slot</A>"
				else
					dat += "Empty SlotOperations: <A href='?src=\ref[src];menu=[SCICONSOLE_DDISKL];disk_slot=[i]'>Load Design to Slot</A>"
				dat += "</div>"
		if(SCICONSOLE_DDISKL) //Design disk submenu
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_DDISK];back_screen=[screen]'>Return to Disk Operations</A><div class='statusDisplay'>"
			dat += "<h3>Load Design to Disk:</h3>"
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				dat += "[D.name] "
				dat += "<A href='?src=\ref[src];copy_design=[disk_slot_selected];copy_design_ID=[D.id]'>Copy to Disk</A>"
			dat += "</div>"
		if(SCICONSOLE_LINKING) //R&D device linkage
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_SETTINGS]'>Settings Menu</A><div class='statusDisplay'>"
			dat += "<h3>R&D Console Device Linkage Menu:</h3>"
			dat += "<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Devices</A>"
			dat += "<h3>Linked Devices:</h3>"
			if(linked_destroy)
				dat += "* Destructive Analyzer <A href='?src=\ref[src];disconnect=destroy'>Disconnect</A>"
			else
				dat += "* No Destructive Analyzer Linked"
			if(linked_lathe)
				dat += "* Protolathe <A href='?src=\ref[src];disconnect=lathe'>Disconnect</A>"
			else
				dat += "* No Protolathe Linked"
			if(linked_imprinter)
				dat += "* Circuit Imprinter <A href='?src=\ref[src];disconnect=imprinter'>Disconnect</A>"
			else
				dat += "* No Circuit Imprinter Linked"
			dat += "</div>"

		////////////////////DESTRUCTIVE ANALYZER SCREENS////////////////////////////
		if(SCICONSOLE_DA_NONE)
			dat += SCICONSOLE_HEADER
			dat += "<div class='statusDisplay'>NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE</div>"

		if(SCICONSOLE_DA_UNLOADED)
			dat += SCICONSOLE_HEADER
			dat += "<div class='statusDisplay'>No Item Loaded. Standing-by...</div>"

		if(SCICONSOLE_DA_LOADED)
			dat += SCICONSOLE_HEADER
			dat += "<div class='statusDisplay'><h3>Deconstruction Menu</h3>"
			dat += "<A href='?src=\ref[src];eject_item=1'>Eject Item</A>"
			dat += "Name: [linked_destroy.loaded_item.name]"
			dat += "Select a node to boost by deconstructing this item."
			dat += "This item is able to boost:"
			var/list/input = techweb_item_boost_check(linked_destroy.loaded_item)
			for(var/datum/techweb_node/N in input)
				if(!stored_research.researched_nodes[N] && !stored_research.boosted_nodes[N])
					dat += "<A href='?src=\ref[src];deconstruct=[N.id]'>[N.display_name]: [input[N]] points</A>"
				else
					dat += "<span class='linkOff>[N.display_name]: [input[N]] points</span>"
		/////////////////////PROTOLATHE SCREENS/////////////////////////
		if(SCICONSOLE_PROTOLATHE_NONE)
			dat += SCICONSOLE_HEADER
			dat += "<div class='statusDisplay'>NO PROTOLATHE LINKED TO CONSOLE</div>"

		if(SCICONSOLE_PROTOLATHE_CAT)
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_PROTOLATHE_MATS]'>Material Storage</A>"
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_PROTOLATHE_CHEMS]'>Chemical Storage</A><div class='statusDisplay'>"
			dat += "<h3>Protolathe Menu:</h3>"
			dat += "<B>Material Amount:</B> [linked_lathe.materials.total_amount] / [linked_lathe.materials.max_amount]"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]"

			dat += "<form name='search' action='?src=\ref[src]'>\
			<input type='hidden' name='src' value='\ref[src]'>\
			<input type='hidden' name='search' value='to_search'>\
			<input type='hidden' name='type' value='proto'>\
			<input type='text' name='to_search'>\
			<input type='submit' value='Search'>\
			</form><HR>"

			dat += list_categories(linked_lathe.categories, SCICONSOLE_PROTOLATHE_CATVIEW)

		//Grouping designs by categories, to improve readability
		if(SCICONSOLE_PROTOLATHE_CATVIEW)
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_PROTOLATHE_CAT]'>Protolathe Menu</A>"
			dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3>"
			dat += "<B>Material Amount:</B> [linked_lathe.materials.total_amount] / [linked_lathe.materials.max_amount]"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]<HR>"

			var/coeff = linked_lathe.efficiency_coeff
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				if(!(selected_category in D.category)|| !(D.build_type & PROTOLATHE))
					continue
				var/temp_material
				var/c = 50
				var/t

				var/all_materials = D.materials + D.reagents_list
				for(var/M in all_materials)
					t = linked_lathe.check_mat(D, M)
					temp_material += " | "
					if (t < 1)
						temp_material += "<span class='bad'>[all_materials[M]*coeff] [CallMaterialName(M)]</span>"
					else
						temp_material += " [all_materials[M]*coeff] [CallMaterialName(M)]"
					c = min(c,t)

				if (c >= 1)
					dat += "<A href='?src=\ref[src];build=[D.id];amount=1'>[D.name]</A>"
					if(c >= 5)
						dat += "<A href='?src=\ref[src];build=[D.id];amount=5'>x5</A>"
					if(c >= 10)
						dat += "<A href='?src=\ref[src];build=[D.id];amount=10'>x10</A>"
					dat += "[temp_material]"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_material]"
				dat += ""
			dat += "</div>"

		if(SCICONSOLE_PROTOLATHE_SEARCH) //Display search result
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_PROTOLATHE_CAT]'>Protolathe Menu</A>"
			dat += "<div class='statusDisplay'><h3>Search results:</h3>"
			dat += "<B>Material Amount:</B> [linked_lathe.materials.total_amount] / [linked_lathe.materials.max_amount]"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]<HR>"

			var/coeff = linked_lathe.efficiency_coeff
			for(var/datum/design/D in matching_designs)
				var/temp_material
				var/c = 50
				var/t
				var/all_materials = D.materials + D.reagents_list
				for(var/M in all_materials)
					t = linked_lathe.check_mat(D, M)
					temp_material += " | "
					if (t < 1)
						temp_material += "<span class='bad'>[all_materials[M]*coeff] [CallMaterialName(M)]</span>"
					else
						temp_material += " [all_materials[M]*coeff] [CallMaterialName(M)]"
					c = min(c,t)

				if (c >= 1)
					dat += "<A href='?src=\ref[src];build=[D.id];amount=1'>[D.name]</A>"
					if(c >= 5)
						dat += "<A href='?src=\ref[src];build=[D.id];amount=5'>x5</A>"
					if(c >= 10)
						dat += "<A href='?src=\ref[src];build=[D.id];amount=10'>x10</A>"
					dat += "[temp_material]"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_material]"
				dat += ""
			dat += "</div>"

		if(SCICONSOLE_PROTOLATHE_MATS) //Protolathe Material Storage Sub-menu
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_PROTOLATHE_CAT]'>Protolathe Menu</A><div class='statusDisplay'>"
			dat += "<h3>Material Storage:</h3><HR>"
			if(!linked_lathe)
				dat += "ERROR: Protolathe connection failed."
			else
				for(var/mat_id in linked_lathe.materials.materials)
					var/datum/material/M = linked_lathe.materials.materials[mat_id]
					dat += "* [M.amount] of [M.name]: "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT) dat += "<A href='?src=\ref[src];ejectsheet=[M.id];eject_amt=1'>Eject</A> "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT*5) dat += "<A href='?src=\ref[src];ejectsheet=[M.id];eject_amt=5'>5x</A> "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT) dat += "<A href='?src=\ref[src];ejectsheet=[M.id];eject_amt=50'>All</A>"
					dat += ""
			dat += "</div>"

		if(SCICONSOLE_PROTOLATHE_CHEMS)
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_PROTOLATHE_CAT]'>Protolathe Menu</A>"
			dat += "<A href='?src=\ref[src];disposeallP=1'>Disposal All Chemicals in Storage</A><div class='statusDisplay'>"
			dat += "<h3>Chemical Storage:</h3><HR>"
			for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)
				dat += "[R.name]: [R.volume]"
				dat += "<A href='?src=\ref[src];disposeP=[R.id]'>Purge</A>"

		///////////////////CIRCUIT IMPRINTER SCREENS////////////////////
		if(SCICONSOLE_CIRCUIT_NONE)
			dat += SCICONSOLE_HEADER
			dat += "<div class='statusDisplay'>NO CIRCUIT IMPRINTER LINKED TO CONSOLE</div>"

		if(SCICONSOLE_CIRCUIT_CAT)
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_CIRCUIT_MATS]'>Material Storage</A>"
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_CIRCUIT_CHEMS]'>Chemical Storage</A><div class='statusDisplay'>"
			dat += "<h3>Circuit Imprinter Menu:</h3>"
			dat += "Material Amount: [linked_imprinter.materials.total_amount]"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			dat += "<form name='search' action='?src=\ref[src]'>\
			<input type='hidden' name='src' value='\ref[src]'>\
			<input type='hidden' name='search' value='to_search'>\
			<input type='hidden' name='type' value='imprint'>\
			<input type='text' name='to_search'>\
			<input type='submit' value='Search'>\
			</form><HR>"

			dat += list_categories(linked_imprinter.categories, SCICONSOLE_CIRCUIT_CATVIEW)

		if(SCICONSOLE_CIRCUIT_CATVIEW)
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_CIRCUIT_CAT]'>Circuit Imprinter Menu</A>"
			dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3>"
			dat += "Material Amount: [linked_imprinter.materials.total_amount]"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			var/coeff = linked_imprinter.efficiency_coeff
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				if(!(selected_category in D.category) || !(D.build_type & IMPRINTER))
					continue
				var/temp_materials
				var/check_materials = 1

				var/all_materials = D.materials + D.reagents_list

				for(var/M in all_materials)
					temp_materials += " | "
					if (!linked_imprinter.check_mat(D, M))
						check_materials = 0
						temp_materials += " <span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_materials += " [all_materials[M]/coeff] [CallMaterialName(M)]"
				if (check_materials)
					dat += "<A href='?src=\ref[src];imprint=[D.id]'>[D.name]</A>[temp_materials]"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_materials]"
			dat += "</div>"

		if(SCICONSOLE_CIRCUIT_SEARCH)
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_CIRCUIT_CAT]'>Circuit Imprinter Menu</A>"
			dat += "<div class='statusDisplay'><h3>Search results:</h3>"
			dat += "Material Amount: [linked_imprinter.materials.total_amount]"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			var/coeff = linked_imprinter.efficiency_coeff
			for(var/datum/design/D in matching_designs)
				var/temp_materials
				var/check_materials = 1
				var/all_materials = D.materials + D.reagents_list
				for(var/M in all_materials)
					temp_materials += " | "
					if (!linked_imprinter.check_mat(D, M))
						check_materials = 0
						temp_materials += " <span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_materials += " [all_materials[M]/coeff] [CallMaterialName(M)]"
				if (check_materials)
					dat += "<A href='?src=\ref[src];imprint=[D.id]'>[D.name]</A>[temp_materials]"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_materials]"
			dat += "</div>"

		if(SCICONSOLE_CIRCUIT_CHEMS) //Circuit Imprinter Material Storage Sub-menu
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_CIRCUIT_CAT]'>Circuit Imprinter Menu</A>"
			dat += "<A href='?src=\ref[src];disposeallI=1'>Disposal All Chemicals in Storage</A><div class='statusDisplay'>"
			dat += "<h3>Chemical Storage:</h3><HR>"
			for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
				dat += "[R.name]: [R.volume]"
				dat += "<A href='?src=\ref[src];disposeI=[R.id]'>Purge</A>"

		if(SCICONSOLE_CIRCUIT_MATS)
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_CIRCUIT_CAT]'>Circuit Imprinter Menu</A><div class='statusDisplay'>"
			dat += "<h3>Material Storage:</h3><HR>"
			if(!linked_imprinter)
				dat += "ERROR: Protolathe connection failed."
			else
				for(var/mat_id in linked_imprinter.materials.materials)
					var/datum/material/M = linked_imprinter.materials.materials[mat_id]
					dat += "* [M.amount] of [M.name]: "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[M.id];eject_amt=1'>Eject</A> "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT*5) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[M.id];eject_amt=5'>5x</A> "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[M.id];eject_amt=50'>All</A>"
			dat += "</div>"
		else
			CRASH("R&D console screen var corrupted!")
*/
/obj/machinery/computer/rdconsole/ui_data(mob/user)
	var/list/data = list()
	//Tabs
	data["tabs"] = list("Technology", "View Node", "View Design", "Disk Operations", "Deconstructive Analyzer", "Protolathe", "Circuit Imprinter", "Settings")
	//Locking
	data["locked"] = locked
	//General Access
	data["research_points_stored"] = stored_research.research_points
	data["protolathe_linked"] = linked_lathe? TRUE : FALSE
	data["circuit_linked"] = linked_imprinter? TRUE : FALSE
	data["destroy_linked"] = linked_destroy? TRUE : FALSE
	//Techweb Screen
	var/list/techweb_avail = list()
	var/list/techweb_locked = list()
	var/list/techweb_researched = list()
	for(var/id in stored_research.available_nodes)
		var/datum/techweb_node/N = stored_research.available_nodes[id]
		techweb_avail += list("id" = N.id, "display_name" = N.display_name)
	for(var/id in stored_research.visible_nodes)
		var/datum/techweb_node/N = stored_research.visible_nodes[id]
		techweb_locked += list("id" = N.id, "display_name" = N.display_name)
	for(var/id in stored_research.researched_nodes)
		var/datum/techweb_node/N = stored_research.researched_nodes[id]
		techweb_researched += list("id" = N.id, "display_name" = N.display_name)
	data["techweb_avail"] = techweb_avail
	data["techweb_locked"] = techweb_locked
	data["techweb_researched"] = techweb_researched
	//Node View
	data["node_selected"] = selected_node? TRUE : FALSE
	if(selected_node)
		data["snode_id"] = selected_node.id
		data["snode_researched"] = stored_research.researched_nodes[selected_node.id]? TRUE : FALSE
		data["snode_cost"] = selected_node.get_price()
		data["snode_export"] = selected_node.export_price
		data["snode_desc"] = selected_node.description
		var/list/prereqs = list()
		var/list/unlocks = list()
		var/list/designs = list()
		for(var/id in selected_node.prerequisites)
			var/datum/techweb_node/N = selected_node.prerequisites[id]
			prereqs += list("id" = N.id, "display_name" = N.display_name)
		for(var/id in selected_node.unlocks)
			var/datum/techweb_node/N = selected_node.unlocks[id]
			unlocks += list("id" = N.id, "display_name" = N.display_name)
		for(var/id in selected_node.designs)
			var/datum/design/D = selected_node.designs[id]
			designs += list("id" = D.id, "name" = D.name)
		data["node_prereqs"] = prereqs
		data["node_unlocks"] = unlocks
		data["node_designs"] = designs
	//Design View
	data["design_selected"] = selected_design? TRUE : FALSE
	if(selected_design)
		data["sdesign_id"] = selected_design.id
		data["sdesign_name"] = selected_design.name
		data["sdesign_desc"] = selected_design.desc
		data["sdesign_buildtype"] = selected_design.build_type
		data["sdesign_mats"] = list()
		for(var/M in selected_design.materials)
			data["sdesign_mats"]["[CallMaterialName(M)]"] = selected_design.materials[M]

	/*
	//Disk Operations


	*/




	return data

/obj/machinery/computer/rdconsole/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("select_node")
			selected_node = SSresearch.techweb_nodes[params["id"]]
		if("select_design")
			selected_design = SSresearch.techweb_designs[params["id"]]
		if("research_node")
			research_node(params["id"], usr)
		if("Lock")
			if(allowed(usr))
				lock_console(usr)
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
		if("Unlock")
			if(allowed(usr))
				unlock_console(usr)
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
		if("Resync")
			to_chat(usr, "<span class='boldnotice'>[bicon(src)]: Resyncing with nearby machinery.</span>")

/obj/machinery/computer/rdconsole/proc/lock_console(mob/user)
	locked = TRUE

/obj/machinery/computer/rdconsole/proc/unlock_console(mob/user)
	locked = FALSE

/obj/machinery/computer/rdconsole/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rdconsole_primary", "Research and Development", 880, 880, master_ui, state)
		ui.open()

//helper proc, which return a table containing categories
/obj/machinery/computer/rdconsole/proc/list_categories(list/categories, menu_num as num)
	if(!categories)
		return

	var/line_length = 1
	var/dat = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[menu_num]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	return dat

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	desc = "A console used to interface with R&D tools."
	id = 2
	req_access = null
	req_access_txt = "29"

/obj/machinery/computer/rdconsole/robotics/Initialize()
	. = ..()
	if(circuit)
		circuit.name = "R&D Console - Robotics (Computer Board)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	desc = "A console used to interface with R&D tools."
	id = 1

/obj/machinery/computer/rdconsole/experiment
	name = "E.X.P.E.R.I-MENTOR R&D Console"
	desc = "A console used to interface with R&D tools."
	id = 3
