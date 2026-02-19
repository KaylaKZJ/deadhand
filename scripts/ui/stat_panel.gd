extends Control
class_name StatPanel
## Stat allocation panel UI
## Allows the player to spend unspent_stat_points on ATK, DEF, or VIT.
## Shows real-time effect previews. Apply commits changes; Cancel discards them.
## Emits stat_preview_changed(staged_atk, staged_def, staged_vit) every time staging
## changes so cards in hand can show a live preview; emits (0, 0, 0) on close/cancel.

signal stat_preview_changed(staged_atk: int, staged_def: int, staged_vit: int)

@onready var unspent_label: Label = $PanelContainer/VBoxContainer/HeaderRow/UnspentLabel
@onready var level_label: Label = $PanelContainer/VBoxContainer/HeaderRow/LevelLabel

@onready var atk_value_label: Label = $PanelContainer/VBoxContainer/ATKRow/ATKButtonRow/ATKValue
@onready var atk_effect_label: Label = $PanelContainer/VBoxContainer/ATKRow/ATKEffect
@onready var atk_minus_btn: Button = $PanelContainer/VBoxContainer/ATKRow/ATKButtonRow/ATKMinus
@onready var atk_plus_btn: Button = $PanelContainer/VBoxContainer/ATKRow/ATKButtonRow/ATKPlus

@onready var def_value_label: Label = $PanelContainer/VBoxContainer/DEFRow/DEFButtonRow/DEFValue
@onready var def_effect_label: Label = $PanelContainer/VBoxContainer/DEFRow/DEFEffect
@onready var def_minus_btn: Button = $PanelContainer/VBoxContainer/DEFRow/DEFButtonRow/DEFMinus
@onready var def_plus_btn: Button = $PanelContainer/VBoxContainer/DEFRow/DEFButtonRow/DEFPlus

@onready var vit_value_label: Label = $PanelContainer/VBoxContainer/VITRow/VITButtonRow/VITValue
@onready var vit_effect_label: Label = $PanelContainer/VBoxContainer/VITRow/VITEffect
@onready var vit_minus_btn: Button = $PanelContainer/VBoxContainer/VITRow/VITButtonRow/VITMinus
@onready var vit_plus_btn: Button = $PanelContainer/VBoxContainer/VITRow/VITButtonRow/VITPlus

@onready var apply_btn: Button = $PanelContainer/VBoxContainer/ButtonRow/ApplyButton
@onready var cancel_btn: Button = $PanelContainer/VBoxContainer/ButtonRow/CancelButton

var combat_manager: CombatManager = null

# Staged (uncommitted) allocation amounts
var _staged_atk: int = 0
var _staged_def: int = 0
var _staged_vit: int = 0

func _ready():
	combat_manager = get_tree().get_first_node_in_group("combat_manager")
	
	atk_minus_btn.pressed.connect(func(): _change_staged("atk", -1))
	atk_plus_btn.pressed.connect(func(): _change_staged("atk", 1))
	def_minus_btn.pressed.connect(func(): _change_staged("def", -1))
	def_plus_btn.pressed.connect(func(): _change_staged("def", 1))
	vit_minus_btn.pressed.connect(func(): _change_staged("vit", -1))
	vit_plus_btn.pressed.connect(func(): _change_staged("vit", 1))
	apply_btn.pressed.connect(_on_apply_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	
	visible = false

func open_panel():
	"""Show panel and reset staged values"""
	if not combat_manager:
		combat_manager = get_tree().get_first_node_in_group("combat_manager")
	_staged_atk = 0
	_staged_def = 0
	_staged_vit = 0
	_refresh_ui()
	visible = true

func close_panel():
	"""Hide panel without committing — revert any card previews"""
	stat_preview_changed.emit(0, 0, 0)
	visible = false

func _change_staged(stat: String, delta: int):
	"""Increment or decrement a staged stat allocation"""
	var points_available = combat_manager.unspent_stat_points - (_staged_atk + _staged_def + _staged_vit)
	
	match stat:
		"atk":
			var new_val = _staged_atk + delta
			if new_val < 0:
				return
			if delta > 0 and points_available <= 0:
				return
			_staged_atk = new_val
		"def":
			var new_val = _staged_def + delta
			if new_val < 0:
				return
			if delta > 0 and points_available <= 0:
				return
			_staged_def = new_val
		"vit":
			var new_val = _staged_vit + delta
			if new_val < 0:
				return
			if delta > 0 and points_available <= 0:
				return
			_staged_vit = new_val
	
	_refresh_ui()
	stat_preview_changed.emit(_staged_atk, _staged_def, _staged_vit)

func _refresh_ui():
	"""Update all labels and button states"""
	if not combat_manager:
		return
	
	var points_spent = _staged_atk + _staged_def + _staged_vit
	var points_remaining = combat_manager.unspent_stat_points - points_spent
	
	if level_label:
		level_label.text = "Level: %d" % combat_manager.player_level
	if unspent_label:
		unspent_label.text = "Points: %d" % points_remaining
		unspent_label.add_theme_color_override("font_color",
			Color.YELLOW if points_remaining > 0 else Color.WHITE)
	
	# ATK row
	var preview_atk = combat_manager.player_atk + _staged_atk
	if atk_value_label:
		atk_value_label.text = "ATK:  %d" % preview_atk
	if atk_effect_label:
		atk_effect_label.text = "+%d dmg to all units" % preview_atk
	if atk_minus_btn:
		atk_minus_btn.disabled = _staged_atk <= 0
	if atk_plus_btn:
		atk_plus_btn.disabled = points_remaining <= 0
	
	# DEF row
	var preview_def = combat_manager.player_def + _staged_def
	if def_value_label:
		def_value_label.text = "DEF:  %d" % preview_def
	if def_effect_label:
		def_effect_label.text = "+%d HP to all armor" % preview_def
	if def_minus_btn:
		def_minus_btn.disabled = _staged_def <= 0
	if def_plus_btn:
		def_plus_btn.disabled = points_remaining <= 0
	
	# VIT row
	var preview_vit = combat_manager.player_vit + _staged_vit
	var preview_max_hp = combat_manager.max_player_hp + (_staged_vit * 2)
	if vit_value_label:
		vit_value_label.text = "VIT:  %d" % preview_vit
	if vit_effect_label:
		vit_effect_label.text = "Max HP = %d" % preview_max_hp
	if vit_minus_btn:
		vit_minus_btn.disabled = _staged_vit <= 0
	if vit_plus_btn:
		vit_plus_btn.disabled = points_remaining <= 0
	
	# Apply disabled if nothing staged
	if apply_btn:
		apply_btn.disabled = points_spent <= 0

func _on_apply_pressed():
	"""Commit staged allocations to the combat manager"""
	if not combat_manager:
		return
	if _staged_atk > 0:
		combat_manager.allocate_stat("atk", _staged_atk)
	if _staged_def > 0:
		combat_manager.allocate_stat("def", _staged_def)
	if _staged_vit > 0:
		combat_manager.allocate_stat("vit", _staged_vit)
	close_panel()

func _on_cancel_pressed():
	"""Discard staged allocations"""
	close_panel()

func _input(event: InputEvent):
	if visible and event.is_action_pressed("ui_cancel"):
		close_panel()
		get_viewport().set_input_as_handled()
