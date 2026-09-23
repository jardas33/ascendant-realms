extends Control
## Inventory — equipment slots, item bag, equip/unequip, and stat comparison.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
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

func _ready() -> void:
	_build()
	ProfileManager.profile_changed.connect(_refresh)
	_refresh()

func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

func _build() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists(BG):
		bg.texture = load(BG)
	add_child(bg)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.05, 0.67)
	add_child(scrim)

	var title := Label.new()
	title.text = "WAR CHEST"
	title.add_theme_font_override("font", _title_font())
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	title.offset_left = 24.0
	title.offset_top = 16.0
	title.offset_right = 400.0
	title.offset_bottom = 58.0
	add_child(title)

	# Three columns
	var cols := HBoxContainer.new()
	cols.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cols.offset_top = 84.0
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
	footer.add_child(_grant_button)
	footer.add_child(_button("Back", func(): _goto("res://scenes/ui/hero_sheet.tscn")))

func _column(header: String, assign: Callable) -> Control:
	var panel: PanelContainer = MENU_PLATE_SCRIPT.new()
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
		_detail_box.add_child(_empty_message("SELECT A RELIC", "Choose a relic to inspect its powers, compare it to equipped gear, and prepare it for battle."))
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
	_slots_box.add_child(HSeparator.new())
	for slot in SLOTS:
		var item = equip.get(slot, null)
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 37)
		row.add_theme_constant_override("separation", 8)
		_slots_box.add_child(row)
		var slot_name := Label.new()
		slot_name.text = _pretty(slot).to_upper()
		slot_name.custom_minimum_size = Vector2(160, 0)
		slot_name.add_theme_font_size_override("font_size", 16)
		slot_name.add_theme_color_override("font_color", Color(0.87, 0.77, 0.57))
		row.add_child(slot_name)
		if item:
			var b := Button.new()
			b.focus_mode = Control.FOCUS_NONE
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.custom_minimum_size = Vector2(0, 34)
			_label_button(b, str(item.get("name", "?")), RARITY_COLORS.get(item.get("rarity", "common"), Color.WHITE))
			b.pressed.connect(_show_equipped_detail.bind(slot, item))
			row.add_child(b)
		else:
			var vacant := Label.new()
			vacant.text = "—  EMPTY"
			vacant.add_theme_font_size_override("font_size", 16)
			vacant.add_theme_color_override("font_color", Color(0.56, 0.60, 0.62))
			row.add_child(vacant)
		var rule := ColorRect.new()
		rule.custom_minimum_size = Vector2(0, 1)
		rule.color = Color(0.78, 0.68, 0.48, 0.17)
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_slots_box.add_child(rule)

func _rebuild_items() -> void:
	_clear_after(_items_box, 2)
	var inv: Array = ProfileManager.hero().get("inventory", [])
	if inv.is_empty():
		_items_box.add_child(_empty_message("NO RELICS CARRIED", "The chest is empty. Claim your starter relics below to outfit your hero."))
		return
	for item in inv:
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, 50)
		var col: Color = RARITY_COLORS.get(item.get("rarity", "common"), Color.WHITE)
		_label_button(b, "%s (%s)" % [item.get("name", "?"), _pretty(item.get("slot", ""))], col)
		b.pressed.connect(_show_item_detail.bind(item))
		_items_box.add_child(b)

func _show_item_detail(item: Dictionary) -> void:
	Sfx.play("select")
	_clear_after(_detail_box, 2)
	_detail_box.add_child(_detail_title(item))
	_detail_box.add_child(_wrap_label(str(item.get("desc", ""))))
	# comparison vs currently equipped in same slot
	var slot: String = str(item.get("slot", ""))
	var equipped = ProfileManager.hero().get("equipment", {}).get(slot, null)
	_detail_box.add_child(_stats_block(item, equipped))
	var eq := _button("Equip", func():
		ProfileManager.equip_item(item)
		_clear_after(_detail_box, 2)
		_detail_box.add_child(_empty_message("SELECT A RELIC", "Choose a relic to inspect its powers and compare it to equipped gear.")))
	_detail_box.add_child(eq)

func _show_equipped_detail(slot: String, item: Dictionary) -> void:
	Sfx.play("select")
	_clear_after(_detail_box, 2)
	_detail_box.add_child(_detail_title(item))
	_detail_box.add_child(_wrap_label(str(item.get("desc", ""))))
	_detail_box.add_child(_stats_block(item, null))
	var uq := _button("Unequip", func():
		ProfileManager.unequip_slot(slot)
		_clear_after(_detail_box, 2)
		_detail_box.add_child(_empty_message("SELECT A RELIC", "Choose a relic to inspect its powers and compare it to equipped gear.")))
	_detail_box.add_child(uq)

func _detail_title(item: Dictionary) -> Label:
	var l := Label.new()
	l.text = str(item.get("name", "?")).to_upper()
	l.add_theme_font_override("font", _title_font())
	l.add_theme_font_size_override("font_size", 25)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_color_override("font_color", RARITY_COLORS.get(item.get("rarity", "common"), Color.WHITE))
	return l

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
		var row := Label.new()
		var line := "%s   +%s" % [_pretty(k).to_upper(), str(stats[k])]
		var row_color := Color(0.72, 0.94, 0.76)
		if compare != null and compare.get("slot", "") == item.get("slot", ""):
			var delta = float(stats[k]) - float(cmp.get(k, 0))
			var sign := "+" if delta >= 0 else ""
			line += "   ·   %s%s VS EQUIPPED" % [sign, str(delta)]
			if delta < 0:
				row_color = Color(0.96, 0.67, 0.58)
		row.text = line
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_theme_font_override("font", ThemeDB.fallback_font)
		row.add_theme_font_size_override("font_size", 19)
		row.add_theme_color_override("font_color", row_color)
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

func _empty_message(title_text: String, body_text: String) -> VBoxContainer:
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(0, 340)
	content.add_theme_constant_override("separation", 14)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 68)
	content.add_child(spacer)
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
