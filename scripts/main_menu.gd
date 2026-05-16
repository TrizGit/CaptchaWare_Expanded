extends Node2D

enum MenuType {
	SETTINGS,
	CREDITS
}

enum SettingsSliders{
	MASTER,
	MUSIC,
	SOUND,
	SCROLL
}

@onready var settings_sliders: VBoxContainer = $menuStuff/windowmenustuff/menus/options/VBoxContainer

@onready var windowmenustuff: Control = $menuStuff/windowmenustuff
@onready var menus: Control = $menuStuff/windowmenustuff/menus

@onready var bg: TextureRect = $"../MicrogameGameplay/bg"

@onready var volume_check: AudioStreamPlayer = $menuStuff/windowmenustuff/menus/options/VolumeCheck

@onready var ui_anim: AnimationPlayer = $"../CanvasLayer/AnimationPlayer"
@onready var captcha_animation_player: AnimationPlayer = $"../MicrogameGameplay/captchaTransition/captchaAnimationPlayer"

@onready var endless_mode: CheckButton = $menuStuff/endless_mode

@onready var email_n_password: Control = $intro

var intro_cutscene := false
var cur_tab_text_typing := 0

var cur_text_node : Label

const random_user = [
	"lemon",
	"paperhatprojects",
	"averagejoe",
	"genericemail",
	"kasaneteto",
	"mrkevinsynthv",
	"egglover",
	"iwillfindyou",
	"randomstreamer",
	"funnyjoke",
	"coincidence",
	"warioware",
	"internetculture",
	"notapuzzlegame",
	"insertfunnytext",
	"lostandfound",
	"horsesnuts",
	"iabsolutely",
	"icantestthis",
	"nonsensenhreal",
	"impossiblechris",
	# extra user (please notify me if you want something to be removed, with a VALID reason)
	"evilcorporation",
	"randomguy",
	"ilikemoney",
	"hatsunemiku",
	"boyfriend",
	"usgovwhistleblower",
	"mrpresident"
]

const random_domains = [
	"gmail.com",
	# extra domains
	"yahoo.com",
	"outlook.com",
	"scientology.org", #shhhhhhhhhhhhhhhhhhh
	"yourschool",
	"youruniv"
]

const random_country = ["au", "fr", "sg", "vn", "jp", "us", "uk", "de", "su", "ru", "id", "cn", "br", "es", "ca"] # why? not

var password_length = ["••••••••", "•••••••••", "••••••••••", "•••••••••••", "••••••••••••"].pick_random() # ok, seriously i have no idea how tf should i do this

func _ready() -> void:
	if GameData.stored_data.played_intro:
		start_with_no_intro()
	else:
		intro_cutscene_start()

	load_settings()
	endless_mode.visible = GameData.save_file.beaten_full_game

func everything_is_random(): # yes
	var selected_user = random_user.pick_random()
	var selected_domain = ""

	if selected_user == "coincidence":
		selected_domain = "neal.fun"
	elif selected_user == "impossiblechris":
		selected_domain = "gmail.com"
	elif selected_user == "usgovwhistleblower":
		selected_domain = "justice.gov"
	elif selected_user == "mrpresident":
		selected_domain = "whitehouse.gov"
	else:
		selected_domain = random_domains.pick_random()
		# schools, amirite (haha, very funny)
		if selected_domain == "yourschool":
			selected_domain += [".sch.", ".edu."].pick_random() + random_country.pick_random()
		elif selected_domain == "youruniv":
			selected_domain += [".ac.", ".edu."].pick_random() + random_country.pick_random()

	cur_text_node.text = selected_user + "@" + selected_domain

func intro_cutscene_start() -> void:
	intro_cutscene = true
	captcha_animation_player.play("intro_cutscene_1")
	change_text_box_intro()
	everything_is_random()

func _input(event: InputEvent) -> void:
	if !(intro_cutscene && event is InputEventKey): return

	if event.is_pressed() && !event.is_echo() && !Input.is_action_just_pressed("ui_text_submit"):
		if cur_text_node.visible_characters == 0:
			cur_text_node.get_parent().placeholder_text = ""
		cur_text_node.visible_characters += 1
		print(cur_text_node.visible_characters, " ", cur_text_node.get_total_character_count(), " ", cur_tab_text_typing)

	if cur_text_node.visible_characters >= cur_text_node.get_total_character_count():
		cur_text_node.get_parent().modulate = Color("d8d8d8ff")

		if cur_tab_text_typing >= 2:
			captcha_animation_player.play("intro_cutscene_2")
			intro_cutscene = false

			GameData.stored_data.played_intro = true
		else:
			change_text_box_intro()

func change_text_box_intro() -> void:
	cur_text_node = email_n_password.get_child(cur_tab_text_typing).get_child(0)
	cur_text_node.text = password_length
	cur_tab_text_typing += 1

func _on_credits_pressed() -> void:
	open_menu(MenuType.CREDITS)

func _on_settings_pressed() -> void:
	open_menu(MenuType.SETTINGS)

func open_menu(menu_type : MenuType) -> void:
	windowmenustuff.visible = true

	for i in menus.get_children():
		i.visible = false

	menus.get_child(menu_type).visible = true

func _on_close_menu_pressed() -> void:
	windowmenustuff.visible = false
	bg.self_modulate = Color("ffffff00")

func load_settings() -> void:
	for i in settings_sliders.get_child_count():
		settings_sliders.get_child(i).get_child(0).value = GameData.game_settings.values()[i]

	for i in SettingsSliders.size():
		set_value_settings(i)

	endless_mode.button_pressed = GameData.save_file.endless_mode

func set_value_settings(value_type : SettingsSliders) -> void:
	var cur_slider := settings_sliders.get_child(value_type).get_child(0)

	match value_type:
		SettingsSliders.MASTER:
			var final_value : float = cur_slider.value
			if cur_slider.value == cur_slider.min_value:
				final_value = -80
			GameData.game_settings.master_volume = final_value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), final_value)
		SettingsSliders.MUSIC:
			var final_value : float = cur_slider.value
			if cur_slider.value == cur_slider.min_value:
				final_value = -80
			GameData.game_settings.music_volume = final_value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), final_value)
		SettingsSliders.SOUND:
			var final_value : float = cur_slider.value
			if cur_slider.value == cur_slider.min_value:
				final_value = -80
			GameData.game_settings.sound_volume = final_value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), final_value)
		SettingsSliders.SCROLL:
			GameData.game_settings.scroll_speed = cur_slider.value
			bg.material.set("shader_parameter/set_speed", cur_slider.value)

	GameData.save_cur_data(GameData.SAVE_SETTINGS)

func _on_scroll_speed_drag_ended(_value_changed: bool) -> void:
	set_value_settings(SettingsSliders.SCROLL)
	bg.self_modulate = Color("e3e3e35a")

func _on_sound_volume_drag_ended(_value_changed: bool) -> void:
	set_value_settings(SettingsSliders.SOUND)
	volume_check.bus = &"Sounds"
	volume_check.play()

func _on_music_volume_drag_ended(_value_changed: bool) -> void:
	set_value_settings(SettingsSliders.MUSIC)
	volume_check.bus = &"Music"
	volume_check.play()

func _on_master_volume_drag_ended(_value_changed: bool) -> void:
	set_value_settings(SettingsSliders.MASTER)
	volume_check.bus = &"Master"
	volume_check.play()

func _on_reset_default_pressed() -> void:
	GameData.reset_all_settings()

	for i in settings_sliders.get_child_count():
		settings_sliders.get_child(i).get_child(0).value = GameData.game_settings.values()[i]

	for i in SettingsSliders.size():
		set_value_settings(i)

func _on_submit_button_pressed() -> void:
	ui_anim.play("end")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "end": return
	get_tree().change_scene_to_file("uid://b1ie1wbaj5lne")


func _on_endless_mode_toggled(toggled_on: bool) -> void:
	GameData.save_file.endless_mode = toggled_on
	GameData.save_cur_data(GameData.GAME_SAVE_NAME)

func _on_captcha_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "intro_cutscene_2": return
	start_with_no_intro()

func start_with_no_intro() -> void:
	captcha_animation_player.play("gamecaptchaidle")
	email_n_password.visible = false
