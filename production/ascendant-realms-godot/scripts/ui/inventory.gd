extends Control
## Inventory — equipment slots, item bag, equip/unequip, and stat comparison.

const FONT := "res://assets/fonts/cinzel.ttf"
const DEFAULT_BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const BARROSAN_BG := "res://assets/ui/inventory/war_chest_vault_backdrop_r2.png"
const EMPTY_CHEST_ART := "res://assets/ui/inventory/astra_empty_war_chest_r1.png"
const EMPTY_RELIC_ART := "res://assets/ui/inventory/astra_empty_relic_cradle_r1.png"
const RELIC_ART := {
	"Lumeforged Blade": "res://assets/ui/inventory/lumeforged_blade_relic_r1.png",
	"Ironbark Helm": "res://assets/ui/inventory/ironbark_helm_relic_r1.png",
	"Warden's Band": "res://assets/ui/inventory/wardens_band_relic_r1.png",
}
const MENU_PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")

const SLOTS := ["main_hand", "off_hand", "head", "body", "hands", "feet",
	"amulet", "ring1", "ring2", "cloak", "relic"]

const RARITY_COLORS := {
	"common": Color(0.8, 0.8, 0.8),
	"uncommon": Color(0.5, 0.9, 0.5),
	"rare": Color(0.4, 0.65, 1.0),
	"epic": Color(0.75, 0.5, 1.0),
	"legendary": Color(1.0, 0.75, 0.3),
}

var _slots_box: VBoxContainer
var _items_box: VBoxContainer
var _detail_box: VBoxContainer
var _grant_button: Button
var _item_group: ButtonGroup
var _barrosan_vault_active := false

func _ready() -> void:
	_build()
	ProfileManager.profile_changed.connect(_refresh)
	_refresh()

func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

func _build() -> void:
	_barrosan_vault_active = str(ProfileManager.hero().get("race", "")) == "barrosan" and ResourceLoader.exists(BARROSAN_BG)
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var bg_path := BARROSAN_BG if _barrosan_vault_active else DEFAULT_BG
	if ResourceLoader.exists(bg_path):
		bg.texture = load(bg_path)
	add_child(bg)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.05, 0.26 if _barrosan_vault_active else 0.67)
	add_child(scrim)

	var title := Label.new()
	# Same title block as the skirmish council: centred crest title, a small
	# caps subtitle and a gold rule.
	title.text = "War Chest"
	title.add_theme_font_override("font", _title_font())
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.52))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 6.0
	title.offset_bottom = 56.0
	add_child(title)
	var subtitle := Label.new()
	subtitle.text = "RELICS AND ARMS YOUR HERO CARRIES INTO BATTLE"
	subtitle.add_theme_font_override("font", _title_font())
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color(0.72, 0.68, 0.60))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	subtitle.offset_top = 54.0
	subtitle.offset_bottom = 72.0
	add_child(subtitle)
	var rule := ColorRect.new()
	rule.color = Color(0.86, 0.70, 0.40, 0.35)
	rule.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	rule.offset_left = 40.0
	rule.offset_right = -40.0
	rule.offset_top = 76.0
	rule.offset_bottom = 77.0
	add_child(rule)

	# Three columns
	var cols := HBoxContainer.new()
	cols.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cols.offset_top = 92.0
	cols.offset_bottom = -130.0
	cols.offset_left = 64.0
	cols.offset_right = -64.0
	cols.add_theme_constant_override("separation", 18)
	add_child(cols)

	cols.add_child(_column("Equipped", func(v): _slots_box = v))
	cols.add_child(_column("Items", func(v): _items_box = v))
	cols.add_child(_column("Details", func(v): _detail_box = v))

	var footer_back := ColorRect.new()
	footer_back.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer_back.offset_top = -112.0
	footer_back.color = Color(0.015, 0.022, 0.032, 0.91)
	footer_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(footer_back)
	var footer_rule := ColorRect.new()
	footer_rule.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer_rule.offset_top = -112.0
	footer_rule.offset_bottom = -110.0
	footer_rule.color = Color(0.79, 0.64, 0.38, 0.65)
	footer_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(footer_rule)
	var footer := HBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -91.0
	footer.offset_bottom = -20.0
	footer.offset_left = 24.0
	footer.offset_right = -24.0
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 20)
	add_child(footer)
	_grant_button = _button("Claim Starter Relics", _on_grant)
	_style_primary(_grant_button)
	footer.add_child(_grant_button)
	footer.add_child(_button("Salvage Commons", func():
		ProfileManager.salvage_rarities(["common", "uncommon"])
		_refresh()))
	footer.add_child(_button("Back", func(): _goto("res://scenes/ui/hero_sheet.tscn")))

func _column(header: String, assign: Callable) -> Control:
	var panel: PanelContainer = MENU_PLATE_SCRIPT.new()
	if _barrosan_vault_active:
		var panel_alpha := 0.76 if header == "Equipped" else (0.70 if header == "Details" else 0.64)
		var panel_bottom_alpha := 0.66 if header == "Equipped" else (0.22 if header == "Details" else 0.18)
		panel.set("surface_alpha", panel_alpha)
		panel.set("surface_alpha_bottom", panel_bottom_alpha)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 24.0
	style.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", style)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 6)
	scroll.add_child(v)
	var h := Label.new()
	h.text = header.to_upper()
	h.add_theme_font_override("font", _title_font())
	h.add_theme_font_size_override("font_size", 24)
	h.add_theme_color_override("font_color", Color(0.9, 0.78, 0.5))
	h.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	h.add_theme_constant_override("outline_size", 3)
	v.add_child(h)
	v.add_child(HSeparator.new())
	assign.call(v)
	return panel

func _refresh() -> void:
	if not ProfileManager.has_hero():
		get_tree().change_scene_to_file("res://scenes/ui/hero_creation.tscn")
		return
	_rebuild_slots()
	_rebuild_items()
	if _detail_box.get_child_count() <= 2:
		_detail_box.add_child(_empty_message("SELECT A RELIC", "Choose a relic to inspect its powers, compare it to equipped gear, and prepare it for battle.", EMPTY_RELIC_ART))
	var hero := ProfileManager.hero()
	_grant_button.visible = (hero.get("inventory", []) as Array).is_empty() and (hero.get("equipment", {}) as Dictionary).is_empty()

func _rebuild_slots() -> void:
	# keep header + separator (first 2 children)
	_clear_after(_slots_box, 2)
	var hero := ProfileManager.hero()
	var equip: Dictionary = hero.get("equipment", {})
	var race: Dictionary = GameData.get_race(str(hero.get("race", "")))
	var hero_unit_id := str(race.get("hero", ""))
	var hero_definition: Dictionary = GameData.get_unit(hero_unit_id) if hero_unit_id != "" else {}
	var portrait_path := str(hero_definition.get("portrait", ""))
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		var identity := HBoxContainer.new()
		identity.add_theme_constant_override("separation", 16)
		_slots_box.add_child(identity)
		var portrait := EntityPortraitView.new()
		portrait.name = "EquipmentHeroPortrait"
		portrait.custom_minimum_size = Vector2(148, 148)
		portrait.configure_definition(hero_definition, false)
		identity.add_child(portrait)
		var identity_text := VBoxContainer.new()
		identity_text.alignment = BoxContainer.ALIGNMENT_CENTER
		identity_text.add_theme_constant_override("separation", 5)
		identity.add_child(identity_text)
		var name_label := Label.new()
		name_label.text = str(hero.get("name", "Hero")).to_upper()
		name_label.add_theme_font_override("font", _title_font())
		name_label.add_theme_font_size_override("font_size", 22)
		name_label.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
		identity_text.add_child(name_label)
		var race_label := Label.new()
		race_label.text = str(race.get("name", "Hero")).to_upper()
		race_label.add_theme_font_size_override("font_size", 17)
		race_label.add_theme_color_override("font_color", Color(0.78, 0.8, 0.77))
		identity_text.add_child(race_label)
		var loadout_label := Label.new()
		loadout_label.text = "%d / %d SLOTS FILLED" % [equip.size(), SLOTS.size()]
		loadout_label.add_theme_font_size_override("font_size", 13)
		loadout_label.add_theme_color_override("font_color", Color(0.72, 0.62, 0.43))
		identity_text.add_child(loadout_label)
	_slots_box.add_child(HSeparator.new())
	var equipped_heading := Label.new()
	equipped_heading.text = "EQUIPPED RELICS"
	equipped_heading.add_theme_font_override("font", _title_font())
	equipped_heading.add_theme_font_size_override("font_size", 20)
	equipped_heading.add_theme_color_override("font_color", Color(0.90, 0.76, 0.48))
	_slots_box.add_child(equipped_heading)
	var open_slots: Array[String] = []
	var equipped_count := 0
	for slot in SLOTS:
		var item = equip.get(slot, null)
		if item is Dictionary:
			equipped_count += 1
			_slots_box.add_child(_equipped_card(slot, item))
		else:
			open_slots.append(slot)
	if equipped_count == 0:
		var empty_equipment := Label.new()
		empty_equipment.text = "No relics equipped. Inspect the chest to prepare your hero."
		empty_equipment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_equipment.add_theme_font_size_override("font_size", 16)
		empty_equipment.add_theme_color_override("font_color", Color(0.78, 0.82, 0.82) if _barrosan_vault_active else Color(0.68, 0.72, 0.73))
		if _barrosan_vault_active:
			empty_equipment.add_theme_color_override("font_outline_color", Color(0.01, 0.015, 0.02, 0.9))
			empty_equipment.add_theme_constant_override("outline_size", 2)
		_slots_box.add_child(empty_equipment)
	var open_heading := Label.new()
	open_heading.text = "OPEN SLOTS  ·  %d REMAINING" % open_slots.size()
	open_heading.add_theme_font_override("font", _title_font())
	open_heading.add_theme_font_size_override("font_size", 18)
	open_heading.add_theme_color_override("font_color", Color(0.82, 0.77, 0.65) if _barrosan_vault_active else Color(0.70, 0.66, 0.57))
	if _barrosan_vault_active:
		open_heading.add_theme_color_override("font_outline_color", Color(0.01, 0.015, 0.02, 0.9))
		open_heading.add_theme_constant_override("outline_size", 2)
	_slots_box.add_child(open_heading)
	var open_grid := GridContainer.new()
	open_grid.name = "OpenEquipmentSlots"
	open_grid.columns = 2
	open_grid.add_theme_constant_override("h_separation", 16)
	open_grid.add_theme_constant_override("v_separation", 5)
	_slots_box.add_child(open_grid)
	for slot in open_slots:
		var slot_label := Label.new()
		slot_label.text = _pretty(slot).to_upper()
		slot_label.custom_minimum_size = Vector2(0, 34)
		slot_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		slot_label.add_theme_font_size_override("font_size", 16)
		slot_label.add_theme_color_override("font_color", Color(0.80, 0.84, 0.82) if _barrosan_vault_active else Color(0.65, 0.70, 0.70))
		if _barrosan_vault_active:
			slot_label.add_theme_color_override("font_outline_color", Color(0.01, 0.015, 0.02, 0.94))
			slot_label.add_theme_constant_override("outline_size", 2)
		slot_label.tooltip_text = "%s slot is empty" % _pretty(slot)
		open_grid.add_child(slot_label)

func _equipped_card(slot: String, item: Dictionary) -> Button:
	var accent: Color = RARITY_COLORS.get(str(item.get("rarity", "common")), Color.WHITE)
	var card := Button.new()
	card.name = "EquippedRelic_%s" % slot
	card.focus_mode = Control.FOCUS_NONE
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.custom_minimum_size = Vector2(0, 108)
	card.tooltip_text = "%s equipped in %s" % [str(item.get("name", "?")), _pretty(slot)]
	for state in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#15222b") if state == "normal" else Color("#24343a") if state == "hover" else Color("#2d2925")
		style.border_color = Color(accent, 0.55 if state == "normal" else 0.88)
		style.set_border_width_all(1)
		style.border_width_left = 3
		style.set_corner_radius_all(4)
		style.shadow_color = Color(0, 0, 0, 0.25)
		style.shadow_size = 3
		card.add_theme_stylebox_override(state, style)
	var content := HBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 13
	content.offset_right = -12
	content.add_theme_constant_override("separation", 12)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(content)
	var relic_art := _item_art(item, 94, "EquippedRelicArt")
	if relic_art != null:
		content.add_child(relic_art)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(stack)
	var slot_label := Label.new()
	slot_label.text = _pretty(slot).to_upper()
	slot_label.add_theme_font_size_override("font_size", 15)
	slot_label.add_theme_color_override("font_color", Color(0.74, 0.70, 0.61))
	slot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(slot_label)
	var name_label := Label.new()
	name_label.text = str(item.get("name", "?"))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.max_lines_visible = 2
	name_label.add_theme_font_override("font", _title_font())
	name_label.add_theme_font_size_override("font_size", 21)
	name_label.add_theme_color_override("font_color", accent.lightened(0.18))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(name_label)
	var inspect := Label.new()
	inspect.text = "INSPECT  ›"
	inspect.add_theme_font_size_override("font_size", 13)
	inspect.add_theme_color_override("font_color", Color(0.85, 0.72, 0.46))
	inspect.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inspect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(inspect)
	card.pressed.connect(_show_equipped_detail.bind(slot, item))
	return card

func _rebuild_items() -> void:
	_clear_after(_items_box, 2)
	_item_group = ButtonGroup.new()
	var inv: Array = ProfileManager.hero().get("inventory", [])
	if inv.is_empty():
		_items_box.add_child(_empty_message("NO RELICS CARRIED", "The chest is empty. Claim your starter relics below to outfit your hero.", EMPTY_CHEST_ART))
		return
	var count_label := Label.new()
	count_label.text = "%d RELICS CARRIED  ·  SELECT TO INSPECT" % inv.size()
	count_label.add_theme_font_size_override("font_size", 13)
	count_label.add_theme_color_override("font_color", Color(0.72, 0.67, 0.55))
	_items_box.add_child(count_label)
	# Best first: rarity, then item level.
	var order := ["legendary", "epic", "rare", "uncommon", "common"]
	var sorted := inv.duplicate()
	sorted.sort_custom(func(a, b):
		var ra := order.find(String(a.get("rarity", "common")))
		var rb := order.find(String(b.get("rarity", "common")))
		if ra != rb:
			return ra < rb
		return int(a.get("item_level", 0)) > int(b.get("item_level", 0)))
	for item in sorted:
		_items_box.add_child(_item_card(item))

func _item_card(item: Dictionary) -> Button:
	var rarity := str(item.get("rarity", "common"))
	var accent: Color = RARITY_COLORS.get(rarity, Color.WHITE)
	var card := Button.new()
	card.name = "RelicItemCard"
	card.focus_mode = Control.FOCUS_NONE
	card.toggle_mode = true
	card.button_group = _item_group
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.custom_minimum_size = Vector2(0, 112)
	for state in ["normal", "hover", "pressed", "hover_pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#1b2430") if state == "normal" else Color("#2b3240") if state == "hover" else Color("#302a20")
		style.border_color = Color(accent, 0.55 if state == "normal" else 0.88)
		style.set_border_width_all(1)
		style.border_width_left = 3
		style.set_corner_radius_all(5)
		style.shadow_color = Color(0, 0, 0, 0.28)
		style.shadow_size = 3
		card.add_theme_stylebox_override(state, style)
	var content := HBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 15
	content.offset_right = -14
	content.add_theme_constant_override("separation", 11)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(content)
	var relic_art := _item_art(item, 98, "CarriedRelicArt")
	if relic_art != null:
		content.add_child(relic_art)
	var labels := VBoxContainer.new()
	labels.alignment = BoxContainer.ALIGNMENT_CENTER
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(labels)
	var name_label := Label.new()
	name_label.text = str(item.get("name", "?"))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.max_lines_visible = 2
	name_label.add_theme_font_override("font", _title_font())
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", accent.lightened(0.18))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	labels.add_child(name_label)
	var meta_label := Label.new()
	meta_label.text = "%s  ·  %s%s" % [_pretty(str(item.get("slot", ""))).to_upper(), rarity.to_upper(), "  ·  LOCKED" if bool(item.get("locked", false)) else ""]
	meta_label.add_theme_font_size_override("font_size", 13)
	meta_label.add_theme_color_override("font_color", Color(0.68, 0.72, 0.73))
	meta_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	labels.add_child(meta_label)
	var inspect_label := Label.new()
	inspect_label.text = "INSPECT  ›"
	inspect_label.add_theme_font_size_override("font_size", 13)
	inspect_label.add_theme_color_override("font_color", Color(0.86, 0.72, 0.46))
	inspect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inspect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(inspect_label)
	card.pressed.connect(_show_item_detail.bind(item))
	return card

func _show_item_detail(item: Dictionary) -> void:
	Sfx.play("select")
	_clear_after(_detail_box, 2)
	_detail_box.add_child(_detail_title(item))
	_detail_box.add_child(_detail_meta(item, false))
	_add_detail_art(item)
	_detail_box.add_child(_wrap_label(str(item.get("desc", ""))))
	# comparison vs currently equipped in same slot
	var slot: String = str(item.get("slot", ""))
	var equipped = ProfileManager.hero().get("equipment", {}).get(slot, null)
	_detail_box.add_child(_stats_block(item, equipped))
	if String(item.get("set", "")) != "":
		var worn := 0
		for it in ProfileManager.hero().get("equipment", {}).values():
			if String(it.get("set", "")) == String(item["set"]):
				worn += 1
		_detail_box.add_child(_wrap_label("Set pieces worn: %d of 4 (bonus at 2, power at 4)." % worn))
	var eq := _button("Equip", func():
		ProfileManager.equip_item(item)
		_clear_after(_detail_box, 2)
		_detail_box.add_child(_empty_message("SELECT A RELIC", "Choose a relic to inspect its powers and compare it to equipped gear.", EMPTY_RELIC_ART)))
	_style_primary(eq)
	_detail_box.add_child(eq)
	var sv := _button("Salvage  (+%d XP)" % int(load("res://scripts/game/loot_defs.gd").salvage_xp(item)), func():
		ProfileManager.salvage_item(item)
		_refresh()
		_clear_after(_detail_box, 2)
		_detail_box.add_child(_empty_message("SELECT A RELIC", "Choose a relic to inspect its powers and compare it to equipped gear.", EMPTY_RELIC_ART)))
	_detail_box.add_child(sv)
	# Locked items are never melted by "Salvage Commons".
	var lk := _button("Unlock" if bool(item.get("locked", false)) else "Lock (keep safe)", func():
		item["locked"] = not bool(item.get("locked", false))
		ProfileManager.save_game()
		_refresh()
		_show_item_detail(item))
	_detail_box.add_child(lk)

func _show_equipped_detail(slot: String, item: Dictionary) -> void:
	Sfx.play("select")
	_clear_after(_detail_box, 2)
	_detail_box.add_child(_detail_title(item))
	_detail_box.add_child(_detail_meta(item, true))
	_add_detail_art(item)
	_detail_box.add_child(_wrap_label(str(item.get("desc", ""))))
	_detail_box.add_child(_stats_block(item, null))
	var uq := _button("Unequip", func():
		ProfileManager.unequip_slot(slot)
		_clear_after(_detail_box, 2)
		_detail_box.add_child(_empty_message("SELECT A RELIC", "Choose a relic to inspect its powers and compare it to equipped gear.", EMPTY_RELIC_ART)))
	_detail_box.add_child(uq)

func _detail_title(item: Dictionary) -> Label:
	var l := Label.new()
	l.text = str(item.get("name", "?")).to_upper()
	l.add_theme_font_override("font", _title_font())
	l.add_theme_font_size_override("font_size", 25)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_color_override("font_color", RARITY_COLORS.get(item.get("rarity", "common"), Color.WHITE))
	return l

func _detail_meta(item: Dictionary, equipped: bool) -> Label:
	var rarity := str(item.get("rarity", "common"))
	var label := Label.new()
	label.text = "%s  ·  %s%s" % [_pretty(str(item.get("slot", ""))).to_upper(), rarity.to_upper(), "  ·  EQUIPPED" if equipped else ""]
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", RARITY_COLORS.get(rarity, Color.WHITE))
	return label

func _item_art(item: Dictionary, edge: int, node_name: String) -> TextureRect:
	var art_path := str(RELIC_ART.get(str(item.get("name", "")), ""))
	if art_path.is_empty() or not ResourceLoader.exists(art_path):
		return null
	var art := TextureRect.new()
	art.name = node_name
	art.texture = load(art_path)
	art.custom_minimum_size = Vector2(edge, edge)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return art

func _add_detail_art(item: Dictionary) -> void:
	var art := _item_art(item, 295, "InspectedRelicArt")
	if art == null:
		return
	art.custom_minimum_size = Vector2(0, 295)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_box.add_child(art)

func _stats_block(item: Dictionary, compare) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	var heading := Label.new()
	heading.text = "PROPERTIES"
	heading.add_theme_font_override("font", _title_font())
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color(0.91, 0.75, 0.46))
	v.add_child(heading)
	var stats: Dictionary = item.get("stats", {})
	var cmp: Dictionary = compare.get("stats", {}) if compare else {}
	for k in stats:
		var row := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.07, 0.10, 0.13, 0.86)
		style.border_color = Color(0.68, 0.57, 0.37, 0.30)
		style.set_border_width_all(1)
		style.border_width_left = 3
		style.set_corner_radius_all(4)
		style.content_margin_left = 13
		style.content_margin_right = 13
		style.content_margin_top = 9
		style.content_margin_bottom = 9
		row.add_theme_stylebox_override("panel", style)
		var content := VBoxContainer.new()
		content.add_theme_constant_override("separation", 2)
		row.add_child(content)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		content.add_child(line)
		var stat_name := Label.new()
		stat_name.text = _pretty(str(k)).to_upper()
		stat_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_name.add_theme_font_size_override("font_size", 15)
		stat_name.add_theme_color_override("font_color", Color(0.78, 0.75, 0.65))
		line.add_child(stat_name)
		var stat_value := Label.new()
		stat_value.text = "+%s" % str(stats[k])
		stat_value.add_theme_font_size_override("font_size", 20)
		stat_value.add_theme_color_override("font_color", Color(0.82, 0.95, 0.84))
		line.add_child(stat_value)
		if compare != null and compare.get("slot", "") == item.get("slot", ""):
			var delta = float(stats[k]) - float(cmp.get(k, 0))
			var delta_label := Label.new()
			var signed_delta := "%+.0f" % delta if absf(delta - roundf(delta)) < 0.0001 else "%+.2f" % delta
			delta_label.text = "%s VS EQUIPPED" % signed_delta
			delta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			delta_label.add_theme_font_size_override("font_size", 16)
			delta_label.add_theme_color_override("font_color", Color(0.58, 0.86, 0.64) if delta >= 0 else Color(0.96, 0.67, 0.58))
			content.add_child(delta_label)
		v.add_child(row)
	if stats.is_empty():
		var none := Label.new()
		none.text = "No direct stats."
		none.add_theme_font_override("font", ThemeDB.fallback_font)
		none.add_theme_font_size_override("font_size", 18)
		none.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		v.add_child(none)
	return v

func _on_grant() -> void:
	Sfx.play("select")
	var h := ProfileManager.hero()
	if not (h.get("inventory", []) as Array).is_empty():
		return
	if not (h.get("equipment", {}) as Dictionary).is_empty():
		return
	ProfileManager.add_item({"name": "Ironbark Helm", "slot": "head", "rarity": "uncommon",
		"stats": {"hp": 60, "armor": 2}, "flags": {}, "desc": "A sturdy helm."})
	ProfileManager.add_item({"name": "Lumeforged Blade", "slot": "main_hand", "rarity": "rare",
		"stats": {"dmg": 12, "attack_speed": 0.1}, "flags": {}, "desc": "Hums with Lume."})
	ProfileManager.add_item({"name": "Warden's Band", "slot": "ring1", "rarity": "uncommon",
		"stats": {"mana": 30, "mana_regen": 1.5}, "flags": {}, "desc": "A ring of focus."})

# --- helpers --------------------------------------------------------------
func _pretty(s: String) -> String:
	return s.replace("_", " ").capitalize()

func _clear_after(box: VBoxContainer, keep: int) -> void:
	var children := box.get_children()
	for i in range(children.size() - 1, keep - 1, -1):
		children[i].queue_free()

func _wrap_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_override("font", ThemeDB.fallback_font)
	l.add_theme_color_override("font_color", Color(0.88, 0.88, 0.84))
	l.add_theme_font_size_override("font_size", 19)
	return l

func _empty_message(title_text: String, body_text: String, art_path: String = "") -> VBoxContainer:
	var content := VBoxContainer.new()
	var has_art := not art_path.is_empty() and ResourceLoader.exists(art_path)
	var chest_art := art_path == EMPTY_CHEST_ART
	content.custom_minimum_size = Vector2(0, 500 if chest_art else (420 if has_art else 340))
	content.add_theme_constant_override("separation", 14)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16 if chest_art else (30 if has_art else 68))
	content.add_child(spacer)
	if has_art:
		var artwork := TextureRect.new()
		artwork.name = "EmptyChestArtwork" if chest_art else "EmptyRelicArtwork"
		artwork.texture = load(art_path)
		artwork.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		artwork.custom_minimum_size = Vector2(340, 300) if chest_art else Vector2(260, 250)
		artwork.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(artwork)
	else:
		var sigil := Label.new()
		sigil.text = "◆"
		sigil.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sigil.add_theme_font_override("font", ThemeDB.fallback_font)
		sigil.add_theme_font_size_override("font_size", 62)
		sigil.add_theme_color_override("font_color", Color(0.76, 0.63, 0.40, 0.8))
		content.add_child(sigil)
	var heading := Label.new()
	heading.text = title_text
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", _title_font())
	heading.add_theme_font_size_override("font_size", 23)
	heading.add_theme_color_override("font_color", Color(0.95, 0.86, 0.64))
	content.add_child(heading)
	var body := Label.new()
	body.text = body_text
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_override("font", ThemeDB.fallback_font)
	body.add_theme_font_size_override("font_size", 19)
	body.add_theme_color_override("font_color", Color(0.78, 0.81, 0.80))
	content.add_child(body)
	return content

func _label_button(b: Button, text: String, col: Color) -> void:
	b.text = text
	b.clip_text = false
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_override("font", ThemeDB.fallback_font)
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))

func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.clip_text = false
	b.custom_minimum_size = Vector2(210, 48)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_override("font", ThemeDB.fallback_font)
	b.add_theme_font_size_override("font_size", 18)
	b.pressed.connect(cb)
	return b

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)


func _style_primary(b: Button) -> void:
	# The skirmish screen's bronze call-to-action treatment.
	for state in ["normal", "hover", "pressed"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.36, 0.22, 0.08) if state == "normal" else (Color(0.50, 0.32, 0.12) if state == "hover" else Color(0.28, 0.17, 0.06))
		sb.border_color = Color(1.0, 0.86, 0.52)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(3)
		sb.shadow_color = Color(0.95, 0.65, 0.25, 0.35)
		sb.shadow_size = 10 if state == "hover" else 6
		b.add_theme_stylebox_override(state, sb)
	b.add_theme_font_override("font", _title_font())
	b.add_theme_color_override("font_color", Color(1.0, 0.93, 0.74))
