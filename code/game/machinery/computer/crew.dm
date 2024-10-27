/// How often the sensor data is updated
#define SENSORS_UPDATE_PERIOD (10 SECONDS) //How often the sensor data updates.
/// The job sorting ID associated with otherwise unknown jobs
#define UNKNOWN_JOB_ID 81

/obj/machinery/computer/crew
	name = "crew monitoring console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/crew
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/crew/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/medical_console_data,
	))

/obj/item/circuit_component/medical_console_data
	display_name = "Crew Monitoring Data"
	desc = "Outputs the medical statuses of people on the crew monitoring computer, where it can then be filtered with a Select Query component."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The records retrieved
	var/datum/port/output/records

	var/obj/machinery/computer/crew/attached_console

/obj/item/circuit_component/medical_console_data/populate_ports()
	records = add_output_port("Crew Monitoring Data", PORT_TYPE_TABLE)

/obj/item/circuit_component/medical_console_data/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/crew))
		attached_console = shell

/obj/item/circuit_component/medical_console_data/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/medical_console_data/get_ui_notices()
	. = ..()
	. += create_table_notices(list(
		"name",
		"job",
		"life_status",
		"suffocation",
		"toxin",
		"burn",
		"brute",
		"location",
		"health",
	))


/obj/item/circuit_component/medical_console_data/input_received(datum/port/input/port)

	if(!attached_console || !GLOB.crewmonitor)
		return

	var/list/new_table = list()
	for(var/list/player_record as anything in GLOB.crewmonitor.update_data(attached_console.z))
		var/list/entry = list()
		entry["name"] = player_record["name"]
		entry["job"] = player_record["assignment"]
		entry["life_status"] = player_record["life_status"]
		entry["suffocation"] = player_record["oxydam"]
		entry["toxin"] = player_record["toxdam"]
		entry["burn"] = player_record["burndam"]
		entry["brute"] = player_record["brutedam"]
		entry["location"] = player_record["area"]
		entry["health"] = player_record["health"]
		new_table += list(entry)

	records.set_output(new_table)

/obj/machinery/computer/crew/syndie
	icon_keyboard = "syndie_key"

/obj/machinery/computer/crew/ui_interact(mob/user)
	. = ..()
	GLOB.crewmonitor.show(user,src)

GLOBAL_DATUM_INIT(crewmonitor, /datum/crewmonitor, new)

/datum/crewmonitor
	/// List of user -> UI source
	var/list/ui_sources = list()
	/// Cache of data generated by z-level, used for serving the data within SENSOR_UPDATE_PERIOD of the last update
	var/list/data_by_z = list()
	/// Cache of last update time for each z-level
	var/list/last_update = list()
	/// Map of job to ID for sorting purposes
	var/list/jobs = list(
		// Note that jobs divisible by 10 are considered heads of staff, and bolded
		// 00: Captain
		JOB_CAPTAIN = 00,
		// 10-19: Security
		JOB_HEAD_OF_SECURITY = 10,
		JOB_WARDEN = 11,
		JOB_SECURITY_OFFICER = 12,
		JOB_SECURITY_OFFICER_MEDICAL = 13,
		JOB_SECURITY_OFFICER_ENGINEERING = 14,
		JOB_SECURITY_OFFICER_SCIENCE = 15,
		JOB_SECURITY_OFFICER_SUPPLY = 16,
		JOB_DETECTIVE = 17,
		JOB_SECURITY_ASSISTANT = 18, // monkestation edit: add security assistants
		JOB_BRIG_PHYSICIAN = 19, // monkestation edit: add brig physician
		// 20-29: Medbay
		JOB_CHIEF_MEDICAL_OFFICER = 21,
		JOB_CHEMIST = 22,
		JOB_VIROLOGIST = 23,
		JOB_MEDICAL_DOCTOR = 24,
		JOB_PARAMEDIC = 25,
		// 30-39: Science
		JOB_RESEARCH_DIRECTOR = 30,
		JOB_SCIENTIST = 31,
		JOB_ROBOTICIST = 32,
		JOB_GENETICIST = 33,
		// 40-49: Engineering
		JOB_CHIEF_ENGINEER = 40,
		JOB_STATION_ENGINEER = 41,
		JOB_ATMOSPHERIC_TECHNICIAN = 42,
		// 50-59: Cargo
		JOB_QUARTERMASTER = 50,
		JOB_SHAFT_MINER = 51,
		JOB_CARGO_TECHNICIAN = 52,
		// 60+: Civilian/other
		JOB_HEAD_OF_PERSONNEL = 60,
		JOB_BARTENDER = 61,
		JOB_COOK = 62,
		JOB_BOTANIST = 63,
		JOB_CURATOR = 64,
		JOB_CHAPLAIN = 65,
		JOB_CLOWN = 66,
		JOB_MIME = 67,
		JOB_JANITOR = 68,
		JOB_LAWYER = 69,
		JOB_PSYCHOLOGIST = 71,
		// 200-239: Centcom 
		JOB_CENTCOM_ADMIRAL = 200,
		JOB_CENTCOM = 201,
		JOB_CENTCOM_OFFICIAL = 210,
		JOB_CENTCOM_COMMANDER = 211,
		JOB_CENTCOM_BARTENDER = 212,
		JOB_CENTCOM_CUSTODIAN = 213,
		JOB_CENTCOM_MEDICAL_DOCTOR = 214,
		JOB_CENTCOM_RESEARCH_OFFICER = 215,
		JOB_ERT_COMMANDER = 220,
		JOB_ERT_OFFICER = 221,
		JOB_ERT_ENGINEER = 222,
		JOB_ERT_MEDICAL_DOCTOR = 223,
		JOB_ERT_CLOWN = 224,
		JOB_ERT_CHAPLAIN = 225,
		JOB_ERT_JANITOR = 226,
		JOB_ERT_DEATHSQUAD = 227,
		JOB_NT_REP = 230,
		JOB_BLUESHIELD = 231,

		// ANYTHING ELSE = UNKNOWN_JOB_ID, Unknowns/custom jobs will appear after civilians, and before assistants
		JOB_PRISONER = 998,
		JOB_ASSISTANT = 999,
	)

/datum/crewmonitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CrewConsole")
		ui.open()

/datum/crewmonitor/proc/show(mob/M, source)
	ui_sources[WEAKREF(M)] = WEAKREF(source)
	ui_interact(M)

/datum/crewmonitor/ui_host(mob/user)
	var/datum/weakref/host_ref = ui_sources[WEAKREF(user)]
	return host_ref?.resolve()

/datum/crewmonitor/ui_data(mob/user)
	var/z = user.z
	if(!z)
		var/turf/T = get_turf(user)
		z = T.z
	. = list(
		"sensors" = update_data(z),
		"link_allowed" = isAI(user)
	)

/datum/crewmonitor/proc/update_data(z)
	if(data_by_z["[z]"] && last_update["[z]"] && world.time <= last_update["[z]"] + SENSORS_UPDATE_PERIOD)
		return data_by_z["[z]"]

	var/list/results = list()
	for(var/tracked_mob in GLOB.suit_sensors_list | GLOB.nanite_sensors_list)
		if(!tracked_mob)
			stack_trace("Null entry in suit sensors or nanite sensors list.")
			continue

		var/mob/living/tracked_living_mob = tracked_mob

		// Check if z-level is correct
		var/turf/pos = get_turf(tracked_living_mob)

		// Is our target in nullspace for some reason?
		if(!pos)
			stack_trace("Tracked mob has no loc and is likely in nullspace: [tracked_living_mob] ([tracked_living_mob.type])")
			continue

		// Machinery and the target should be on the same level or different levels of the same station
		if(pos.z != z && (!is_station_level(pos.z) || !is_station_level(z)) && !HAS_TRAIT(tracked_living_mob, TRAIT_MULTIZ_SUIT_SENSORS))
			continue

		var/sensor_mode

		// Set sensor level based on whether we're in the nanites list or the suit sensor list.
		if(tracked_living_mob in GLOB.nanite_sensors_list)
			sensor_mode = SENSOR_COORDS
		else
			var/mob/living/carbon/human/tracked_human = tracked_living_mob

			// Check their humanity.
			if(!ishuman(tracked_human))
				stack_trace("Non-human mob is in suit_sensors_list: [tracked_living_mob] ([tracked_living_mob.type])")
				continue

			// Check they have a uniform
			var/obj/item/clothing/under/uniform = tracked_human.w_uniform
			if (!istype(uniform))
				stack_trace("Human without a suit sensors compatible uniform is in suit_sensors_list: [tracked_human] ([tracked_human.type]) ([uniform?.type])")
				continue

			// Check if their uniform is in a compatible mode.
			if((uniform.has_sensor <= NO_SENSORS) || !uniform.sensor_mode)
				stack_trace("Human without active suit sensors is in suit_sensors_list: [tracked_human] ([tracked_human.type]) ([uniform.type])")
				continue

			sensor_mode = uniform.sensor_mode

		// The entry for this human
		var/list/entry = list(
			"ref" = REF(tracked_living_mob),
			"name" = "Unknown",
			"ijob" = UNKNOWN_JOB_ID
		)

		// ID and id-related data
		var/obj/item/card/id/id_card = tracked_living_mob.get_idcard(hand_first = FALSE)
		if (id_card)
			entry["name"] = id_card.registered_name
			entry["assignment"] = id_card.assignment
			var/trim_assignment = id_card.get_trim_assignment()
			if (jobs[trim_assignment] != null)
				entry["ijob"] = jobs[trim_assignment]

		// Current status
		if (sensor_mode >= SENSOR_LIVING)
			entry["life_status"] = tracked_living_mob.stat

		// Damage
		if (sensor_mode >= SENSOR_VITALS)
			entry += list(
				"oxydam" = round(tracked_living_mob.getOxyLoss(), 1),
				"toxdam" = round(tracked_living_mob.getToxLoss(), 1),
				"burndam" = round(tracked_living_mob.getFireLoss(), 1),
				"brutedam" = round(tracked_living_mob.getBruteLoss(), 1),
				"health" = round(tracked_living_mob.health, 1),
			)

		// Location
		if (sensor_mode >= SENSOR_COORDS)
			entry["area"] = get_area_name(tracked_living_mob, format_text = TRUE)

		// Trackability
		entry["can_track"] = tracked_living_mob.can_track()

		results[++results.len] = entry

	// Cache result
	data_by_z["[z]"] = results
	last_update["[z]"] = world.time

	return results

/datum/crewmonitor/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch (action)
		if ("select_person")
			var/mob/living/silicon/ai/AI = usr
			if(!istype(AI))
				return
			AI.ai_tracking_tool.track_name(AI, params["name"])

#undef SENSORS_UPDATE_PERIOD
#undef UNKNOWN_JOB_ID
