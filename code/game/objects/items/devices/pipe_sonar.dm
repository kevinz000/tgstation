/proc/atmos_return_connected(obj/machinery/atmospherics/A)
	. = list()
	if(istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = A
		. |= P.parent.members
		. |= P.parent.other_atmosmch
	if(istype(A, /obj/machinery/atmospherics/components))
		var/obj/machinery/atmospherics/components/C = A
		for(var/datum/pipeline/L in C.parents)
			. |= L.members
			. |= L.other_atmosmch

#define PIPEMAP_COLOR_BACKGROUND rgb(0, 0, 0)
#define PIPEMAP_COLOR_BASIC rgb(177, 255, 255)
#define PIPEMAP_COLOR_MOB rgb(255, 177, 177)

//inputlist = list(color = list(list(x,y,z))), centerxy = list(x,y)
/proc/generate_layered_pixel_map(list/inputlist)
	var/list/icon/generated = list()
	var/list/sorted = list()		//sorted = list(layer = list(color = list(x,y)))
	var/_maxx = 0
	var/_maxy = 0
	var/_minx = world.maxx
	var/_miny = world.maxy
	var/_centerx
	var/_centery
	var/override_center = FALSE
	if(islist(centerxy) && (length(centerxy) == 2))
		override_center = TRUE
		_centerx = centerxy[1]
		_centery = centerxy[2]
	for(var/color in inputlist)
		var/list/coordlist = inputlist[color]
		for(var/_coordset in coordlist)
			var/list/coordset = _coordset
			if(length(coordset) != 3)		//invalid.
				continue
			var/_x = coordset[1]
			var/_y = coordset[2]
			var/_z = coordset[3]
			_maxx = max(_maxx, _x)
			_minx = min(_minx, _x)
			_maxy = max(_maxy, _y)
			_miny = min(_miny, _y)
			LAZYINITLIST(sorted["[_z]"])
			LAZYADD(sorted["[_z]"][color], list(_x, _y))
	for(var/_layer in sorted)


/proc/render_atmos_pipenet_map(list/obj/machinery/atmospherics/rendering, list/mob/crawlers = list())
	var/list/obj/machinery/atmospherics/zsorted_rendering = list()
	var/list/mob/zsorted_crawlers = list()
	var/list/icon/rendered = list()
	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 0
	var/max_y = 0
	for(var/i in rendering)
		var/obj/machinery/atmospherics/_a = i
		LAZYADD(zsorted_rendering["[_a.z]"], _a)
		min_x = min(min_x, _a.x)
		min_y = min(min_y, _a.y)
		max_x = max(max_x, _a.x)
		max_y = max(max_y, _a.y)
	for(var/i in crawlers)
		var/mob/m = i
		LAZYADD(zsorted_crawlers["[m.z]"], m)
	var/shift_x = world.maxx - max_x
	var/shift_y = world.maxy - max_y
	for(var/zlevel in zsorted_rendering)
		var/icon/canvas = icon('icons/effects/effects.dmi', "nothing")
		canvas.Crop(1, 1, max_x - min_x + 1, max_y - min_y + 1)
		canvas.DrawBox(PIPEMAP_COLOR_BACKGROUND, 1, 1, canvas.Width(), canvas.Height())
		for(var/i in zsorted_rendering[zlevel])
			var/obj/machinery/atmospherics/A = i
			canvas.DrawBox(PIPEMAP_COLOR_BASIC, A.x - shift_x, A.y - shift_y)
			for(var/mob/m in A)
				LAZYADD(zsorted_crawlers[zlevel], A)
		for(var/i in zsorted_crawlers[zlevel])
			var/mob/m = i
			canvas.DrawBox(PIPEMAP_COLOR_MOB, m.x - shift_x, m.y - shift_y)
		rendered[zlevel] = canvas
	return rendered

/obj/machinery/atmospherics/pipe/proc/rendertest()
	var/list/icon/rendered = render_atmos_pipenet_map(atmos_return_connected(src))
	var/dat = ""
	var/index = world.time
	dat += "<html><head><title>rendertesting</title></head><body style='overflow:hidden;margin:0;text-align:center'>"
	for(var/i in rendered)
		var/str = "PIPEMAP_[index]_[i]"
		var/icon/iii = rendered[i]
		usr << browse_rsc(rendered[i], str)
		dat += "<img src='[str]' width='[iii.Width()]'  style='-ms-interpolation-mode:nearest-neighbor' />"
	dat += "</body></html>"
	usr << browse(dat, "window=pipemaprender;size=255x255")

//disposals support when disposals code isn't garbage.

/obj/item/device/pipe_sonar
	name = "Sonar Pipenet Mapper"
	desc = "A high-tech device used by technicians to map out piping networks by pinging them with sonar pulses. It can also detect certain things travelling through pipes."

/obj/item/device/pipe_sonar
