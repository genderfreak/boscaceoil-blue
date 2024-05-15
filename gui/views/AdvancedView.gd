###################################################
# Part of Bosca Ceoil Blue                        #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

extends MarginContainer

@onready var _effect_picker: OptionPicker = %EffectPicker
@onready var _effect_value_slider: PadSlider = %EffectValueSlider
@onready var _swing_stepper: Stepper = %SwingStepper

@onready var _buffer_size_picker: OptionPicker = %BufferPicker
@onready var _gui_scale_stepper: Stepper = %GUIScaleStepper


func _ready() -> void:
	_populate_effect_options()
	_populate_buffer_size_options()
	
	_effect_picker.selected.connect(_change_effect)
	_effect_value_slider.changed.connect(_change_effect)
	_swing_stepper.value_changed.connect(_change_swing)
	
	_buffer_size_picker.selected.connect(_change_buffer_size)
	_gui_scale_stepper.value_changed.connect(_change_gui_scale)
	
	if not Engine.is_editor_hint():
		_edit_current_song()
		
		Controller.song_loaded.connect(_edit_current_song)


# Song settings.

func _populate_effect_options() -> void:
	var selected_item: OptionListPopup.Item = null
	
	for i in Effect.MAX:
		var item := OptionListPopup.Item.new()
		item.id = i
		item.text = Effect.get_effect_name(i)
		
		if not selected_item:
			selected_item = item
		
		_effect_picker.options.push_back(item)
	
	_effect_picker.commit_options()
	_effect_picker.set_selected(selected_item)


func _edit_current_song() -> void:
	if not Controller.current_song:
		_effect_picker.set_selected(_effect_picker.options[0])
		_effect_value_slider.set_current_value(Vector2i(0, 0))
		_swing_stepper.value = 0
		return
	
	_effect_picker.set_selected(_effect_picker.options[Controller.current_song.global_effect])
	_effect_value_slider.set_current_value(Vector2i(Controller.current_song.global_effect_power, 0))
	_swing_stepper.value = Controller.current_song.swing


func _change_effect() -> void:
	Controller.set_song_global_effect(_effect_picker.get_selected().id, _effect_value_slider.get_current_value().x)


func _change_swing() -> void:
	Controller.set_song_swing(_swing_stepper.value)


# App settings.

func _populate_buffer_size_options() -> void:
	var selected_item: OptionListPopup.Item = null
	
	for key: String in SettingsManager.BufferSize:
		var value: int = SettingsManager.BufferSize[key]
		
		var item := OptionListPopup.Item.new()
		item.id = value
		item.text = "%d" % [ value ]
		item.text_extended = Controller.settings_manager.get_buffer_size_text(value)
		
		if not selected_item:
			selected_item = item
		
		_buffer_size_picker.options.push_back(item)
	
	_buffer_size_picker.commit_options()
	_buffer_size_picker.set_selected(selected_item)


func _change_buffer_size() -> void:
	Controller.settings_manager.set_buffer_size(_buffer_size_picker.get_selected().id)


func _change_gui_scale() -> void:
	Controller.settings_manager.set_gui_scale(_gui_scale_stepper.value)
