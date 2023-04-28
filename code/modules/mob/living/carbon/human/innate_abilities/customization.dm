/datum/action/innate/ability/humanoid_customization
	name = "Alter Form"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "alter_form" //placeholder
	icon_icon = 'modular_citadel/icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/ability/humanoid_customization/Activate()
	if(owner.get_ability_property(INNATE_ABILITY_HUMANOID_CUSTOMIZATION, PROPERTY_CUSTOMIZATION_SILENT))
		owner.visible_message("<span class='notice'>[owner] gains a look of \
		concentration while standing perfectly still.\
			Their body seems to shift and starts getting more goo-like.</span>",
		"<span class='notice'>You focus intently on altering your body while \
		standing perfectly still...</span>")
	change_form()

///////
/////// NOTICE: This currently doens't support skin tone - if anyone wants to add this to non slimes, it's up to YOU to do this.
////// (someone should also add genital color switching, more mutant color selection)
///// maybe just make this entire thing tgui based. maybe.
///////

/datum/action/innate/ability/humanoid_customization/proc/change_form()
	var/mob/living/carbon/human/H = owner

	var/select_alteration = input(owner, "Select what part of your form to alter", "Form Alteration", "cancel") in list("Body Color", "Eye Color","Hair Style", "Genitals", "Tail", "Snout", "Wings", "Markings", "Ears", "Taur body", "Penis", "Vagina", "Penis Length", "Breast Size", "Breast Shape", "Butt Size", "Belly Size", "Balls Size", "Cancel")

	if(select_alteration == "Body Color")
		var/new_color = input(owner, "Choose your skin color:", "Race change","#"+H.dna.features["mcolor"]) as color|null
		if(new_color)
			var/temp_hsv = RGBtoHSV(new_color)
			if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) // mutantcolors must be bright //SPLURT EDIT
				H.dna.features["mcolor"] = sanitize_hexcolor(new_color, 6)
				H.update_body()
				H.update_hair()
			else
				to_chat(H, "<span class='notice'>Invalid color. Your color is not bright enough.</span>")
	else if(select_alteration == "Eye Color")
		if(iscultist(H) && HAS_TRAIT(H, TRAIT_CULT_EYES))
			to_chat(H, "<span class='cultlarge'>\"I do not need you to hide yourself anymore, relish my gift.\"</span>")
			return

		var/heterochromia = input(owner, "Do you want to have heterochromia?", "Confirm Multicolors") in list("Yes", "No")
		if(heterochromia == "Yes")
			var/new_color1 = input(owner, "Choose your left eye color:", "Eye Color Change","#"+H.dna?.features["left_eye_color"]) as color|null
			if(new_color1)
				H.left_eye_color = sanitize_hexcolor(new_color1, 6)
			var/new_color2 = input(owner, "Choose your right eye color:",  "Eye Color Change","#"+H.dna?.features["right_eye_color"]) as color|null
			if(new_color2)
				H.right_eye_color = sanitize_hexcolor(new_color2, 6)
		else
			var/new_eyes = input(owner, "Choose your eye color:", "Character Preference","#"+H.dna?.features["left_eye_color"]) as color|null
			if(new_eyes)
				H.left_eye_color = sanitize_hexcolor(new_eyes, 6)
				H.right_eye_color = sanitize_hexcolor(new_eyes, 6)
		H.dna?.update_ui_block(DNA_LEFT_EYE_COLOR_BLOCK)
		H.dna?.update_ui_block(DNA_RIGHT_EYE_COLOR_BLOCK)
		H.update_body()
	else if(select_alteration == "Hair Style")
		if(H.gender == MALE)
			var/new_style = input(owner, "Select a facial hair style", "Hair Alterations")  as null|anything in GLOB.facial_hair_styles_list
			if(new_style)
				H.facial_hair_style = new_style
		else
			H.facial_hair_style = "Shaved"
		//handle normal hair
		var/new_style = input(owner, "Select a hair style", "Hair Alterations")  as null|anything in GLOB.hair_styles_list
		if(new_style)
			H.hair_style = new_style
			H.update_hair()
	else if (select_alteration == "Genitals")
		var/operation = input("Select organ operation.", "Organ Manipulation", "cancel") in list("add sexual organ", "remove sexual organ", "cancel")
		switch(operation)
			if("add sexual organ")
				var/new_organ = input("Select sexual organ:", "Organ Manipulation") as null|anything in GLOB.genitals_list
				if(!new_organ)
					return
				H.give_genital(GLOB.genitals_list[new_organ])

			if("remove sexual organ")
				var/list/organs = list()
				for(var/obj/item/organ/genital/X in H.internal_organs)
					var/obj/item/organ/I = X
					organs["[I.name] ([I.type])"] = I
				var/obj/item/O = input("Select sexual organ:", "Organ Manipulation", null) as null|anything in organs
				var/obj/item/organ/genital/G = organs[O]
				if(!G)
					return
				G.forceMove(get_turf(H))
				qdel(G)
				H.update_genitals()

	else if (select_alteration == "Ears")
		var/list/snowflake_ears_list = list("Normal" = null)
		for(var/path in GLOB.mam_ears_list)
			var/datum/sprite_accessory/ears/mam_ears/instance = GLOB.mam_ears_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_ears_list[S.name] = path
		var/new_ears
		new_ears = input(owner, "Choose your character's ears:", "Ear Alteration") as null|anything in snowflake_ears_list
		if(new_ears)
			H.dna.features["mam_ears"] = new_ears
		H.update_body()

	else if (select_alteration == "Snout")
		var/list/snowflake_snouts_list = list("Normal" = null)
		for(var/path in GLOB.mam_snouts_list)
			var/datum/sprite_accessory/snouts/mam_snouts/instance = GLOB.mam_snouts_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_snouts_list[S.name] = path
		var/new_snout
		new_snout = input(owner, "Choose your character's face:", "Face Alteration") as null|anything in snowflake_snouts_list
		if(new_snout)
			H.dna.features["mam_snouts"] = new_snout
		H.update_body()

	else if (select_alteration == "Wings")
		var/new_color = input(owner, "Choose your wing color:", "Race change","#"+H.dna.features["wings_color"]) as color|null
		if(new_color)
			H.dna.features["wings_color"] = sanitize_hexcolor(new_color, 6)
			H.update_body()
			H.update_hair()
		var/list/snowflake_wings_list = list("Normal" = null)
		for(var/path in GLOB.deco_wings_list)
			var/datum/sprite_accessory/deco_wings/instance = GLOB.deco_wings_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_wings_list[S.name] = path
		var/new_wings
		new_wings = input(owner, "Choose your character's wings:", "Wing Alteration") as null|anything in snowflake_wings_list
		if(new_wings)
			H.dna.features["deco_wings"] = new_wings
		H.update_body()

	else if (select_alteration == "Markings")
		var/list/snowflake_markings_list = list("None")
		for(var/path in GLOB.mam_body_markings_list)
			var/datum/sprite_accessory/mam_body_markings/instance = GLOB.mam_body_markings_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_markings_list[S.name] = path
		var/new_mam_body_markings
		new_mam_body_markings = input(H, "Choose your character's body markings:", "Marking Alteration") as null|anything in snowflake_markings_list
		if(new_mam_body_markings)
			H.dna.features["mam_body_markings"] = new_mam_body_markings
		for(var/X in H.bodyparts) //propagates the markings changes
			var/obj/item/bodypart/BP = X
			BP.update_limb(FALSE, H)
		H.update_body()

	else if (select_alteration == "Tail")
		var/list/snowflake_tails_list = list("Normal" = null)
		for(var/path in GLOB.mam_tails_list)
			var/datum/sprite_accessory/tails/mam_tails/instance = GLOB.mam_tails_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_tails_list[S.name] = path
		var/new_tail
		new_tail = input(owner, "Choose your character's Tail(s):", "Tail Alteration") as null|anything in snowflake_tails_list
		if(new_tail)
			H.dna.features["mam_tail"] = new_tail
			if(new_tail != "None")
				H.dna.features["taur"] = "None"
		H.update_body()

	else if (select_alteration == "Taur body")
		var/list/snowflake_taur_list = list("Normal" = null)
		for(var/path in GLOB.taur_list)
			var/datum/sprite_accessory/taur/instance = GLOB.taur_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if(S.ignore)
					continue
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_taur_list[S.name] = path
		var/new_taur
		new_taur = input(owner, "Choose your character's tauric body:", "Tauric Alteration") as null|anything in snowflake_taur_list
		if(new_taur)
			H.dna.features["taur"] = new_taur
			if(new_taur != "None")
				H.dna.features["mam_tail"] = "None"
		H.update_body()

	else if (select_alteration == "Penis")
		var/new_shape = input(owner, "Choose your character's dong", "Genital Alteration") as null|anything in GLOB.cock_shapes_list
		if(!new_shape)
			return
		H.dna.features["cock_shape"] = new_shape
		var/obj/item/organ/genital/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
		if(!penis)
			H.give_genital(/obj/item/organ/genital/penis)
		else
			penis.set_shape(new_shape)


	else if (select_alteration == "Vagina")
		var/new_shape = input(owner, "Choose your character's pussy", "Genital Alteration") as null|anything in GLOB.vagina_shapes_list
		if(!new_shape)
			return
		H.dna.features["vag_shape"] = new_shape
		var/obj/item/organ/genital/vagina/vagina = H.getorganslot(ORGAN_SLOT_VAGINA)
		if(!vagina)
			H.give_genital(/obj/item/organ/genital/vagina)
		else
			vagina.set_shape(new_shape)

	else if (select_alteration == "Penis Length")
		var/min_D = CONFIG_GET(number/penis_min_inches_prefs)
		var/max_D = CONFIG_GET(number/penis_max_inches_prefs)
		var/new_length = input(owner, "Penis length in inches:\n([min_D]-[max_D])", "Genital Alteration") as num|null
		if(!new_length)
			return
		new_length = clamp(round(new_length), min_D, max_D)
		H.dna.features["cock_length"] = new_length
		var/obj/item/organ/genital/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
		if(!penis)
			H.give_genital(/obj/item/organ/genital/penis)
		else
			penis.set_length(new_length)

	else if (select_alteration == "Breast Size")
		var/new_size = input(owner, "Breast Size", "Genital Alteration") as null|anything in CONFIG_GET(keyed_list/breasts_cups_prefs)
		if(!new_size)
			return
		H.dna.features["breasts_size"] = new_size
		var/obj/item/organ/genital/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
		if(!breasts)
			H.give_genital(/obj/item/organ/genital/breasts)
		else
			breasts.set_breasts_cup(new_size)

	else if (select_alteration == "Breast Shape")
		var/new_shape
		new_shape = input(owner, "Breast Shape", "Genital Alteration") as null|anything in GLOB.breasts_shapes_list
		if(!new_shape)
			return
		H.dna.features["breasts_shape"] = new_shape
		var/obj/item/organ/genital/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
		if(!breasts)
			H.give_genital(/obj/item/organ/genital/breasts)
		else
			breasts.set_shape(new_shape)

	else if (select_alteration == "Butt Size")
		var/min_B = CONFIG_GET(number/butt_min_size_prefs)
		var/max_B = CONFIG_GET(number/butt_max_size_prefs)
		var/new_butt_size = input(owner, "Butt size:\n([min_B]-[max_B])", "Genital Alteration") as num|null
		if(!new_butt_size)
			return
		new_butt_size = clamp(round(new_butt_size), min_B, max_B)
		H.dna.features["butt_size"] = new_butt_size
		var/obj/item/organ/genital/butt/butt = H.getorganslot(ORGAN_SLOT_BUTT)
		if(!butt)
			H.give_genital(/obj/item/organ/genital/butt)
		else
			butt.set_size(new_butt_size)

	else if (select_alteration == "Belly Size")
		var/min_belly = CONFIG_GET(number/belly_min_size_prefs)
		var/max_belly = CONFIG_GET(number/belly_max_size_prefs)
		var/new_belly_size = input(owner, "Belly size:\n([min_belly]-[max_belly])", "Genital Alteration") as num|null
		if(!new_belly_size)
			return
		new_belly_size = clamp(round(new_belly_size), min_belly, max_belly)
		H.dna.features["belly_size"] = new_belly_size
		var/obj/item/organ/genital/belly/belly = H.getorganslot(ORGAN_SLOT_BELLY)
		if(!belly)
			H.give_genital(/obj/item/organ/genital/belly)
		else
			belly.set_size(new_belly_size)

	else if (select_alteration == "Balls Size")
		var/min_ball = CONFIG_GET(number/balls_min_size_prefs)
		var/max_ball = CONFIG_GET(number/balls_max_size_prefs)
		var/new_balls_size = input(owner, "Balls size:\n([min_ball]-[max_ball])\nSize is analogous to cock length.", "Genital Alteration") as num|null
		if(!new_balls_size)
			return
		new_balls_size = clamp(new_balls_size, min_ball, max_ball)
		H.dna.features["balls_size"] = new_balls_size
		var/obj/item/organ/genital/testicles/testes = H.getorganslot(ORGAN_SLOT_TESTICLES)
		if(!testes)
			H.give_genital(/obj/item/organ/genital/testicles)
		else
			testes.set_ball_size(new_balls_size)

	else
		return
