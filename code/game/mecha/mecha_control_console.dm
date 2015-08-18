/obj/machinery/computer/mecha
	name = "Exosuit Control"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "rd_key"
	icon_screen = "mecha"
	light_color = LIGHT_COLOR_FADEDPURPLE
	req_access = list(access_robotics)
	circuit = /obj/item/weapon/circuitboard/mecha_control
	var/list/located = list()
	var/screen = 0
	var/stored_data

/obj/machinery/computer/mecha/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/mecha/attack_hand(var/mob/user as mob)
	ui_interact(user)
	
/obj/machinery/computer/mecha/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	
	if(screen == 0)
		var/list/mechas[0]
		for(var/obj/item/mecha_parts/mecha_tracking/TR in world)
			var/answer = TR.get_mecha_info()
			mechas.Add(list(answer))
		data["mechas"] = mechas
	if(screen == 1)
		data["log"] = stored_data

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "exosuit_control.tmpl", "Exosuit Control Console", 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/mecha/Topic(href, href_list)
	if(..())
		return 1
	
	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	if(href_list["send_message"])
		var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("send_message")
		var/message = strip_html_simple(input(usr,"Input message","Transmit message") as text)
		if(!trim(message) || ..())
			return 1
		var/obj/mecha/M = MT.in_mecha()
		if(M)
			M.occupant_message(message)
		
	if(href_list["shock"])
		var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("shock")
		MT.shock()
		
	if(href_list["get_log"])
		var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("get_log")
		stored_data = MT.get_mecha_log()
		screen = 1
		
	if(href_list["return"])
		screen = 0
		
	nanomanager.update_uis(src)
	return

/obj/item/mecha_parts/mecha_tracking
	name = "Exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	origin_tech = "programming=2;magnets=2"
	construction_time = 50
	construction_cost = list("metal"=500)

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_info()
	if(!in_mecha())
		return 0
	var/obj/mecha/M = src.loc
	var/list/answer[0]
	answer["reference"] = "\ref[src]"
	answer["name"] = sanitize(M.name)
	answer["charge"] = M.get_charge()
	answer["integrity"] = "[M.health/initial(M.health)*100]%"
	answer["airtank"] = "[M.return_pressure()]kPa"
	answer["pilot"] = "[M.occupant||"None"]"
	answer["location"] = "[sanitize(get_area(M))||"Unknown"]"
	answer["equipment"] = "[M.selected||"None"]"
	
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		answer["cargo"] = "[RM.cargo.len/RM.cargo_capacity*100]%"
	
	return answer

/obj/item/mecha_parts/mecha_tracking/emp_act()
	qdel(src)
	return

/obj/item/mecha_parts/mecha_tracking/ex_act()
	qdel(src)
	return

/obj/item/mecha_parts/mecha_tracking/proc/in_mecha()
	if(istype(src.loc, /obj/mecha))
		return src.loc
	return 0

/obj/item/mecha_parts/mecha_tracking/proc/shock()
	var/obj/mecha/M = in_mecha()
	if(M)
		M.emp_act(2)
	qdel(src)

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_log()
	if(!src.in_mecha())
		return 0
	var/obj/mecha/M = src.loc
	return M.get_log_html()

/obj/item/weapon/storage/box/mechabeacons
	name = "Exosuit Tracking Beacons"
	New()
		..()
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
