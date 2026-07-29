extends Control
## Inventory — equipment slots, item bag, equip/unequip, and stat comparison.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"

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
	scrim.color = Color(0.02, 0.03, 0.05, 0.78)
	add_child(scrim)

	var title := Label.new()
	title.text = "War Chest"
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
	cols.offset_top = 70.0
	cols.offset_bottom = -80.0
	cols.offset_left = 24.0
	cols.offset_right = -24.0
	cols.add_theme_constant_override("separation", 20)
	add_child(cols)

	cols.add_child(_column("Equipped", func(v): _slots_box = v))
	cols.add_child(_column("Items", func(v): _items_box = v))
	cols.add_child(_column("Details", func(v): _detail_box = v))

	# Footer
	var footer := HBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -64.0
	footer.offset_bottom = -16.0
	footer.offset_left = 24.0
	footer.offset_right = -24.0
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 20)
	add_child(footer)
	footer.add_child(_button("Grant Starter Relics", _on_grant))
	footer.add_child(_button("Back", func(): _goto("res://scenes/ui/hero_sheet.tscn")))

func _column(header: String, assign: Callable) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 6)
	scroll.add_child(v)
	var h := Label.new()
	h.text = header
	h.add_theme_font_override("font", _title_font())
	h.add_theme_font_size_override("font_size", 22)
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

func _rebuild_slots() -> void:
	# keep header + separator (first 2 children)
	_clear_after(_slots_box, 2)
	var equip: Dictionary = ProfileManager.hero().get("equipment", {})
	for slot in SLOTS:
		var item = equip.get(slot, null)
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, 40)
		var text := "%s: %s" % [_pretty(slot), (item.get("name", "?") if item else "Empty")]
		var col := Color(0.6, 0.6, 0.62)
		if item:
			col = RARITY_COLORS.get(item.get("rarity", "common"), Color.WHITE)
		_label_button(b, text, col)
		if item:
			b.pressed.connect(_show_equipped_detail.bind(slot, item))
		_slots_box.add_child(b)

func _rebuild_items() -> void:
	_clear_after(_items_box, 2)
	var inv: Array = ProfileManager.hero().get("inventory", [])
	if inv.is_empty():
		var empty := Label.new()
		empty.text = "Your bag is empty."
		empty.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		_items_box.add_child(empty)
		return
	for item in inv:
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, 40)
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
	var eq := _button("Equip", func(): ProfileManager.equip_item(item); _clear_after(_detail_box, 2))
	_detail_box.add_child(eq)

func _show_equipped_detail(slot: String, item: Dictionary) -> void:
	Sfx.play("select")
	_clear_after(_detail_box, 2)
	_detail_box.add_child(_detail_title(item))
	_detail_box.add_child(_wrap_label(str(item.get("desc", ""))))
	_detail_box.add_child(_stats_block(item, null))
	var uq := _button("Unequip", func(): ProfileManager.unequip_slot(slot); _clear_after(_detail_box, 2))
	_detail_box.add_child(uq)

func _detail_title(item: Dictionary) -> Label:
	var l := Label.new()
	l.text = str(item.get("name", "?"))
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", RARITY_COLORS.get(item.get("rarity", "common"), Color.WHITE))
	return l

func _stats_block(item: Dictionary, compare) -> VBoxContainer:
	var v := VBoxContainer.new()
	var stats: Dictionary = item.get("stats", {})
	var cmp: Dictionary = compare.get("stats", {}) if compare else {}
	for k in stats:
		var row := Label.new()
		var line := "%s: +%s" % [_pretty(k), str(stats[k])]
		if compare != null and compare.get("slot", "") == item.get("slot", ""):
			var delta = float(stats[k]) - float(cmp.get(k, 0))
			var sign := "+" if delta >= 0 else ""
			line += "   (vs equipped %s%s)" % [sign, str(delta)]
		row.text = line
		row.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
		v.add_child(row)
	if stats.is_empty():
		var none := Label.new()
		none.text = "No direct stats."
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
	l.add_theme_color_override("font_color", Color(0.88, 0.88, 0.84))
	l.add_theme_font_size_override("font_size", 16)
	return l

func _label_button(b: Button, text: String, col: Color) -> void:
	b.text = text
	b.clip_text = false
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))

func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.clip_text = false
	b.custom_minimum_size = Vector2(210, 48)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 18)
	b.pressed.connect(cb)
	return b

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
