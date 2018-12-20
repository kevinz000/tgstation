#define SDQL_qdel_datum(d) qdel(d)

/*
	Welcome admins, badmins and coders alike, to Structured Datum Query Language.
	SDQL allows you to powerfully run code on batches of objects (or single objects, it's still unmatched
	even there.)
	When I say "powerfully" I mean it you're in for a ride.

	Ok so say you want to get a list of every mob. How does one do this?
	"SELECT /mob"
	This will open a list of every object in world that is a /mob.
	And you can VV them if you need.

	What if you want to get every mob on a *specific z-level*?
	"SELECT /mob WHERE z == 4"

	What if you want to select every mob on even numbered z-levels?
	"SELECT /mob WHERE z % 2 == 0"

	Can you see where this is going? You can select objects with an arbitrary expression.
	These expressions can also do variable access and proc calls (yes, both on-object and globals!)
	Keep reading!

	Ok. What if you want to get every machine in the SSmachine process list? Looping through world is kinda
	slow.

	"SELECT * IN SSmachines.machinery"

	Here "*" as type functions as a wildcard.
	We know everything in the global SSmachines.machinery list is a machine.

	You can specify "IN <expression>" to return a list to operate on.
	This can be any list that you can wizard together from global variables and global proc calls.
	Every variable/proc name in the "IN" block is global.
	It can also be a single object, in which case the object is wrapped in a list for you.
	So yeah SDQL is unironically better than VV for complex single-object operations.

	You can of course combine these.
	"SELECT * IN SSmachines.machinery WHERE z == 4"
	"SELECT * IN SSmachines.machinery WHERE stat & 2" // (2 is NOPOWER, can't use defines from SDQL. Sorry!)
	"SELECT * IN SSmachines.machinery WHERE stat & 2 && z == 4"

	The possibilities are endless (just don't crash the server, ok?).

	Oh it gets better.

	You can use "MAP <expression>" to run some code per object and use the result. For example:

	"SELECT /obj/machinery/power/smes MAP [charge / capacity * 100, RCon_tag, src]"

	This will give you a list of all the APCs, their charge AND RCon tag. Useful eh?

	[] being a list here. Yeah you can write out lists directly without > lol lists in VV. Color matrix
	shenanigans inbound.

	After the "MAP" segment is executed, the rest of the query executes as if it's THAT object you just made
	(here the list).
	Yeah, by the way, you can chain these MAP / WHERE things FOREVER!

	"SELECT /mob WHERE client MAP client WHERE holder MAP holder"

	What if some dumbass admin spawned a bajillion spiders and you need to kill them all?
	Oh yeah you'd rather not delete all the spiders in maintenace. Only that one room the spiders were
	spawned in.

	"DELETE /mob/living/carbon/superior_animal/giant_spider WHERE loc.loc == marked"

	Here I used VV to mark the area they were in, and since loc.loc = area, voila.
	Only the spiders in a specific area are gone.

	Or you know if you want to catch spiders that crawled into lockers too (how even?)

	"DELETE /mob/living/carbon/superior_animal/giant_spider WHERE global.get_area(src) == marked"

	What else can you do?

	Well suppose you'd rather gib those spiders instead of simply flat deleting them...

	"CALL gib() ON /mob/living/carbon/superior_animal/giant_spider WHERE global.get_area(src) == marked"

	Or you can have some fun..

	"CALL forceMove(marked) ON /mob/living/carbon/superior_animal"

	You can also run multiple queries sequentially:

	"CALL forceMove(marked) ON /mob/living/carbon/superior_animal; CALL gib() ON
	/mob/living/carbon/superior_animal"

	And finally, you can directly modify variables on objects.

	"UPDATE /mob WHERE client SET client.color = [0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]"

	Don't crash the server, OK?

	A quick recommendation: before you run something like a DELETE or another query.. Run it through SELECT
	first.
	You'd rather not gib every player on accident.
	Or crash the server.

	By the way, queries are slow and take a while. Be patient.
	They don't hang the entire server though.

	With great power comes great responsability.

	Here's a slightly more formal quick reference.

	The 4 queries you can do are:

	"SELECT <selectors>"
	"CALL <proc call> ON <selectors>"
	"UPDATE <selectors> SET var=<value>,var2=<value>"
	"DELETE <selectors>"

	"<selectors>" in this context is "<type> [IN <source>] [chain of MAP/WHERE modifiers]"

	"IN" (or "FROM", that works too but it's kinda weird to read),
	is the list of objects to work on. This defaults to world if not provided.
	But doing something like "IN living_mob_list" is quite handy and can optimize your query.
	All names inside the IN block are global scope, so you can do living_mob_list (a global var) easily.
	You can also run it on a single object. Because SDQL is that convenient even for single operations.

	<type> filters out objects of, well, that type easily. "*" is a wildcard and just takes everything in
	the source list.

	And then there's the MAP/WHERE chain.
	These operate on each individual object being ran through the query.
	They're both expressions like IN, but unlike it the expression is scoped *on the object*.
	So if you do "WHERE z == 4", this does "src.z", effectively.
	If you want to access global variables, you can do `global.living_mob_list`.
	Same goes for procs.

	MAP "changes" the object into the result of the expression.
	WHERE "drops" the object if the expression is falsey (0, null or "")

	What can you do inside expressions?

	* Proc calls
	* Variable reads
	* Literals (numbers, strings, type paths, etc...)
	* \ref referencing: {0x30000cc} grabs the object with \ref [0x30000cc]
	* Lists: [a, b, c] or [a: b, c: d]
	* Math and stuff.
	* A few special variables: src (the object currently scoped on), usr (your mob),
		marked (your marked datum), global(global scope)
*/

/client/proc/SDQL2_query(query_text as message)
	set category = "Debug"
	if(!check_rights(R_DEBUG))  //Shouldn't happen... but just to be safe.
		message_admins("<span class='danger'>ERROR: Non-admin [key_name(usr)] attempted to execute a SDQL query!</span>")
		log_admin("Non-admin [key_name(usr)] attempted to execute a SDQL query!")
		return FALSE
	var/list/results = world.SDQL2_query(query_text, key_name_admin(usr), "[key_name(usr)]")
	for(var/I in 1 to 3)
		to_chat(usr, results[I])
	SSblackbox.record_feedback("nested tally", "SDQL query", 1, list(ckey, query_text))

/world/proc/SDQL2_query(query_text, log_entry1, log_entry2)
	var/query_log = "executed SDQL query: \"[query_text]\"."
	message_admins("[log_entry1] [query_log]")
	query_log = "[log_entry2] [query_log]"
	log_game(query_log)
	NOTICE(query_log)
	var/objs_all = 0
	var/objs_eligible = 0
	var/start_time = REALTIMEOFDAY

	if(!query_text || length(query_text) < 1)
		return


	var/list/query_list = SDQL2_tokenize(query_text)

	if(!query_list || query_list.len < 1)
		return

	var/list/querys = SDQL_parse(query_list)


	if(!querys || querys.len < 1)
		return

	var/list/refs = list()
	var/selectors_used = FALSE

	for(var/list/query_tree in querys)
		var/list/object_selectors = list()

		switch(query_tree[1])
			if("explain")
				SDQL_testout(query_tree["explain"])
				return

			if("call")
				object_selectors = query_tree["on"]

			if("select", "delete", "update")
				object_selectors = query_tree[query_tree[1]]

		var/list/selector_info = list(0, 0, FALSE)
		var/list/objs = SDQL_from_object_selectors(object_selectors, selector_info)
		selectors_used = selector_info[3]
		objs_all = selector_info[1]
		objs_eligible = selector_info[2]

		switch(query_tree[1])
			if("call")
				for(var/i in objs)
					if(!SDQL_is_proper_datum(i))
						continue
					world.SDQL_var(i, query_tree["call"][1], source = i)
					CHECK_TICK

			if("delete")
				for(var/datum/d in objs)
					SDQL_qdel_datum(d)
					CHECK_TICK

			if("select")
				var/list/text_list = list()
				for(var/i in objs)
					SDQL_print(i, text_list)
					refs[REF(i)] = TRUE
					CHECK_TICK
				var/text = text_list.Join()
				if (text)
					var/static/result_offset = 0
					usr << browse(text, "window=SDQL-result-[result_offset++]")

			if("update")
				if("set" in query_tree)
					var/list/set_list = query_tree["set"]
					for(var/d in objs)
						if(!SDQL_is_proper_datum(d))
							continue
						SDQL_internal_vv(d, set_list)
						CHECK_TICK

	var/end_time = REALTIMEOFDAY
	end_time -= start_time
	return list("<span class='admin'>SDQL query results: [query_text]</span>",\
		"<span class='admin'>SDQL query completed: [objs_all] objects selected by path, and [selectors_used ? objs_eligible : objs_all] objects executed on after WHERE filtering/MAPping if applicable.</span>",\
		"<span class='admin'>SDQL query took [DisplayTimeText(end_time)] to complete.</span>") + refs

/proc/SDQL_internal_vv(d, list/set_list)
	for(var/list/sets in set_list)
		var/datum/temp = d
		var/i = 0
		for(var/v in sets)
			if(++i == sets.len)
				temp.vv_edit_var(v, SDQL_expression(d, set_list[sets]))
				break
			if(temp.vars.Find(v) && (istype(temp.vars[v], /datum) || istype(temp.vars[v], /client)))
				temp = temp.vars[v]
			else
				break

/proc/SDQL_parse(list/query_list)
	var/datum/SDQL_parser/parser = new()
	var/list/querys = list()
	var/list/query_tree = list()
	var/pos = 1
	var/querys_pos = 1
	var/do_parse = 0

	for(var/val in query_list)
		if(val == ";")
			do_parse = 1
		else if(pos >= query_list.len)
			query_tree += val
			do_parse = 1

		if(do_parse)
			parser.query = query_tree
			var/list/parsed_tree
			parsed_tree = parser.parse()
			if(parsed_tree.len > 0)
				querys.len = querys_pos
				querys[querys_pos] = parsed_tree
				querys_pos++
			else //There was an error so don't run anything, and tell the user which query has errored.
				to_chat(usr, "<span class='danger'>Parsing error on [querys_pos]\th query. Nothing was executed.</span>")
				return list()
			query_tree = list()
			do_parse = 0
		else
			query_tree += val
		pos++

	qdel(parser)
	return querys

/proc/SDQL_testout(list/query_tree, indent = 0)
	var/static/whitespace = "&nbsp;&nbsp;&nbsp; "
	var/spaces = ""
	for(var/s = 0, s < indent, s++)
		spaces += whitespace

	for(var/item in query_tree)
		if(istype(item, /list))
			to_chat(usr, "[spaces](")
			SDQL_testout(item, indent + 1)
			to_chat(usr, "[spaces])")

		else
			to_chat(usr, "[spaces][item]")

		if(!isnum(item) && query_tree[item])

			if(istype(query_tree[item], /list))
				to_chat(usr, "[spaces][whitespace](")
				SDQL_testout(query_tree[item], indent + 2)
				to_chat(usr, "[spaces][whitespace])")

			else
				to_chat(usr, "[spaces][whitespace][query_tree[item]]")

/world/proc/SDQL_from_objs(list/tree)
	if("world" in tree)
		return src
	return SDQL_expression(src, tree)

/proc/SDQL_get_all(type, location)
	var/list/out = list()

// If only a single object got returned, wrap it into a list so the for loops run on it.
	if(!islist(location) && location != world)
		location = list(location)

	if(type == "*")
		for(var/i in location)
			var/datum/d = i
			if(d.can_vv_get())
				out += d
			CHECK_TICK
		return out
	if(istext(type))
		type = text2path(type)
	var/typecache = typecacheof(type)

	if(ispath(type, /mob))
		for(var/mob/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /turf))
		for(var/turf/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /obj))
		for(var/obj/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /area))
		for(var/area/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /atom))
		for(var/atom/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /datum))
		if(location == world) //snowflake for byond shortcut
			for(var/datum/d) //stupid byond trick to have it not return atoms to make this less laggy
				if(typecache[d.type] && d.can_vv_get())
					out += d
				CHECK_TICK
		else
			for(var/datum/d in location)
				if(typecache[d.type] && d.can_vv_get())
					out += d
				CHECK_TICK

	return out

/world/proc/SDQL_from_object_selectors(list/tree, list/info_out)
	var/type = tree[1]
	var/list/from = tree[2]

	var/list/objs = world.SDQL_from_objs(from)
	CHECK_TICK
	objs = SDQL_get_all(type, objs)
	CHECK_TICK

	var/use_info_out = info_out && info_out.len >= 3

	if(use_info_out)
		info_out[1] = objs.len

	// 1 and 2 are type and FROM.
	var/i = 3
	while (i <= tree.len)
		var/key = tree[i++]
		var/list/expression = tree[i++]
		switch (key)
			if ("map")
				if(use_info_out)
					info_out[3] = TRUE
				for(var/j = 1 to objs.len)
					var/x = objs[j]
					objs[j] = SDQL_expression(x, expression)
					CHECK_TICK

			if ("where")
				if(use_info_out)
					info_out[3] = TRUE
				var/list/out = list()
				for(var/x in objs)
					if(SDQL_expression(x, expression))
						out += x
					CHECK_TICK
				objs = out

	if(use_info_out)
		info_out[2] = objs.len

	return objs

/proc/SDQL_expression(datum/object, list/expression, start = 1)
	var/result = 0
	var/val

	for(var/i = start, i <= expression.len, i++)
		var/op = ""

		if(i > start)
			op = expression[i]
			i++

		var/list/ret = SDQL_value(object, expression, i)
		val = ret["val"]
		i = ret["i"]

		if(op != "")
			switch(op)
				if("+")
					result = (result + val)
				if("-")
					result = (result - val)
				if("*")
					result = (result * val)
				if("/")
					result = (result / val)
				if("&")
					result = (result & val)
				if("|")
					result = (result | val)
				if("^")
					result = (result ^ val)
				if("%")
					result = (result % val)
				if("=", "==")
					result = (result == val)
				if("!=", "<>")
					result = (result != val)
				if("<")
					result = (result < val)
				if("<=")
					result = (result <= val)
				if(">")
					result = (result > val)
				if(">=")
					result = (result >= val)
				if("and", "&&")
					result = (result && val)
				if("or", "||")
					result = (result || val)
				else
					to_chat(usr, "<span class='danger'>SDQL2: Unknown op [op]</span>")
					result = null
		else
			result = val

	return result

/proc/SDQL_value(datum/object, list/expression, start = 1)
	var/i = start
	var/val = null

	if(i > expression.len)
		return list("val" = null, "i" = i)

	if(istype(expression[i], /list))
		val = SDQL_expression(object, expression[i])

	else if(expression[i] == "!")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = !ret["val"]
		i = ret["i"]

	else if(expression[i] == "~")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = ~ret["val"]
		i = ret["i"]

	else if(expression[i] == "-")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = -ret["val"]
		i = ret["i"]

	else if(expression[i] == "null")
		val = null

	else if(isnum(expression[i]))
		val = expression[i]

	else if(ispath(expression[i]))
		val = expression[i]

	else if(copytext(expression[i], 1, 2) in list("'", "\""))
		val = copytext(expression[i], 2, length(expression[i]))

	else if(expression[i] == "\[")
		var/list/expressions_list = expression[++i]
		val = list()
		for(var/list/expression_list in expressions_list)
			var/result = SDQL_expression(object, expression_list)
			var/assoc
			if(expressions_list[expression_list] != null)
				assoc = SDQL_expression(object, expressions_list[expression_list])
			if(assoc != null)
				// Need to insert the key like this to prevent duplicate keys fucking up.
				var/list/dummy = list()
				dummy[result] = assoc
				result = dummy
			val += result
	else
		val = world.SDQL_var(object, expression, i, object)
		i = expression.len

	return list("val" = val, "i" = i)

/world/proc/SDQL_var(object, list/expression, start = 1, source)
	var/v
	var/static/list/exclude = list("usr", "src", "marked", "global")
	var/long = start < expression.len
	var/datum/D
	if(SDQL_is_proper_datum(object))
		D = object

	if (object == world && (!long || expression[start + 1] == ".") && !(expression[start] in exclude))
		to_chat(usr, "<span class='danger'>World variables are not allowed to be accessed. Use global.</span>")
		return null

	else if(expression [start] == "{" && long)
		if(lowertext(copytext(expression[start + 1], 1, 3)) != "0x")
			to_chat(usr, "<span class='danger'>Invalid pointer syntax: [expression[start + 1]]</span>")
			return null
		v = locate("\[[expression[start + 1]]]")
		if(!v)
			to_chat(usr, "<span class='danger'>Invalid pointer: [expression[start + 1]]</span>")
			return null
		start++
		long = start < expression.len
	else if(D != null && (!long || expression[start + 1] == ".") && (expression[start] in D.vars))
		if(D.can_vv_get(expression[start]))
			v = D.vars[expression[start]]
		else
			v = "SECRET"
	else if(D != null && long && expression[start + 1] == ":" && hascall(D, expression[start]))
		v = expression[start]
	else if(!long || expression[start + 1] == ".")
		switch(expression[start])
			if("usr")
				v = usr
			if("src")
				v = source
			if("marked")
				if(usr.client && usr.client.holder && usr.client.holder.marked_datum)
					v = usr.client.holder.marked_datum
				else
					return null
			if("world")
				v = world
			if("global")
				v = GLOB
			else
				return null
	else if(object == GLOB) // Shitty ass hack kill me.
		v = expression[start]
	if(long)
		if(expression[start + 1] == ".")
			return SDQL_var(v, expression[start + 2], source = source)
		else if(expression[start + 1] == ":")
			return SDQL_function(object, v, expression[start + 2], source)
		else if(expression[start + 1] == "\[" && islist(v))
			var/list/L = v
			var/index = SDQL_expression(source, expression[start + 2])
			if(isnum(index) && (!ISINTEGER(index) || L.len < index))
				to_chat(usr, "<span class='danger'>Invalid list index: [index]</span>")
				return null
			return L[index]
	return v

/proc/SDQL_function(datum/object, procname, list/arguments, source)
	set waitfor = FALSE
	var/list/new_args = list()
	for(var/arg in arguments)
		new_args[++new_args.len] = SDQL_expression(source, arg)
	if(object == GLOB) // Global proc.
		procname = "/proc/[procname]"
		return WrapAdminProcCall(GLOBAL_PROC, procname, new_args)
	return WrapAdminProcCall(object, procname, new_args)

/proc/SDQL2_tokenize(query_text)

	var/list/whitespace = list(" ", "\n", "\t")
	var/list/single = list("(", ")", ",", "+", "-", ".", "\[", "]", "{", "}", ";", ":")
	var/list/multi = list(
					"=" = list("", "="),
					"<" = list("", "=", ">"),
					">" = list("", "="),
					"!" = list("", "="))

	var/word = ""
	var/list/query_list = list()
	var/len = length(query_text)

	for(var/i = 1, i <= len, i++)
		var/char = copytext(query_text, i, i + 1)

		if(char in whitespace)
			if(word != "")
				query_list += word
				word = ""

		else if(char in single)
			if(word != "")
				query_list += word
				word = ""

			query_list += char

		else if(char in multi)
			if(word != "")
				query_list += word
				word = ""

			var/char2 = copytext(query_text, i + 1, i + 2)

			if(char2 in multi[char])
				query_list += "[char][char2]"
				i++

			else
				query_list += char

		else if(char == "'")
			if(word != "")
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unexpected ' in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.")
				return null

			word = "'"

			for(i++, i <= len, i++)
				char = copytext(query_text, i, i + 1)

				if(char == "'")
					if(copytext(query_text, i + 1, i + 2) == "'")
						word += "'"
						i++

					else
						break

				else
					word += char

			if(i > len)
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unmatched ' in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.")
				return null

			query_list += "[word]'"
			word = ""

		else if(char == "\"")
			if(word != "")
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unexpected \" in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.")
				return null

			word = "\""

			for(i++, i <= len, i++)
				char = copytext(query_text, i, i + 1)

				if(char == "\"")
					if(copytext(query_text, i + 1, i + 2) == "'")
						word += "\""
						i++

					else
						break

				else
					word += char

			if(i > len)
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unmatched \" in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.")
				return null

			query_list += "[word]\""
			word = ""

		else
			word += char

	if(word != "")
		query_list += word
	return query_list

/proc/SDQL_is_proper_datum(thing)
	return istype(thing, /datum) || istype(thing, /client)

/proc/SDQL_print(object, list/text_list, print_nulls = TRUE)
	if(SDQL_is_proper_datum(object))
		text_list += "<A HREF='?_src_=vars;[HrefToken()];Vars=[REF(object)]'>[REF(object)]</A> : [object]"
		if(istype(object, /atom))
			var/atom/A = object
			var/turf/T = A.loc
			var/area/a
			if(istype(T))
				text_list += " <font color='gray'>at</font> [T] [ADMIN_COORDJMP(T)]"
				a = T.loc
			else
				var/turf/final = get_turf(T)		//Recursive, hopefully?
				if(istype(final))
					text_list += " <font color='gray'>at</font> [final] [ADMIN_COORDJMP(final)]"
					a = final.loc
				else
					text_list += " <font color='gray'>at</font> nonexistant location"
			if(a)
				text_list += " <font color='gray'>in</font> area [a]"
				if(T.loc != a)
					text_list += " <font color='gray'>inside</font> [T]"
		text_list += "<br>"
	else if(islist(object))
		var/list/L = object
		var/first = TRUE
		text_list += "\["
		for (var/x in L)
			if (!first)
				text_list += ", "
			first = FALSE
			SDQL_print(x, text_list)
			if (!isnull(x) && !isnum(x) && L[x] != null)
				text_list += " -> "
				SDQL_print(L[L[x]])
		text_list += "]<br>"
	else
		if(isnull(object) && print_nulls)
			text_list += "NULL<br>"
		else
			text_list += "[object]<br>"
