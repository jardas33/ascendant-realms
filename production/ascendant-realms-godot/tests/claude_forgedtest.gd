extends SceneTree
## Claude probe: draws sample forged panels over a battlefield picture and
## saves FORGED_OUT. Review-only.

const SKIN := preload("res://scripts/ui/hud_forged_skin.gd")


class FPanel extends Control:
	var outline := PackedVector2Array()
	var studs := []
	var window := Rect2()
	var opts := {}
	func _draw() -> void:
		SKIN.paint(self, outline, studs, window, opts)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var bg := TextureRect.new()
	var img := Image.load_from_file(OS.get_environment("FORGED_BG"))
	bg.texture = ImageTexture.create_from_image(img)
	bg.size = Vector2(1280, 720)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	root.add_child(bg)
	# A top band hung from the edge.
	var band := FPanel.new()
	band.outline = PackedVector2Array([Vector2(0, -20), Vector2(640, -20), Vector2(640, 30), Vector2(620, 50), Vector2(0, 50)])
	band.studs = SKIN.rivets_along(Vector2(0, 45.5), Vector2(620, 45.5), 120.0, 2.6, 30.0)
	band.studs.append(Vector4(628, 22, 6.5, 1))
	band.opts = {"rim": 8.0, "inlay": 0.0}
	root.add_child(band)
	# A minimap housing.
	var mm := FPanel.new()
	mm.position = Vector2(12, 400)
	var w := 290.0
	var h := 310.0
	var c := 14.0
	mm.outline = PackedVector2Array([Vector2(c, 0), Vector2(w - c, 0), Vector2(w, c), Vector2(w, h - c), Vector2(w - c, h), Vector2(c, h), Vector2(0, h - c), Vector2(0, c)])
	mm.window = Rect2(16, 38, w - 32, w - 32 - 16 + 0)
	mm.studs = [Vector4(10, 10, 5, 1), Vector4(w - 10, 10, 5, 1), Vector4(10, h - 10, 5, 1), Vector4(w - 10, h - 10, 5, 1)]
	mm.opts = {"rim": 9.0, "inlay": 0.0}
	root.add_child(mm)
	var title := Label.new()
	title.text = "HOLLOWSPAN CROSSING"
	title.position = Vector2(12 + 40, 408)
	title.add_theme_color_override("font_color", Color(0.93, 0.84, 0.66))
	root.add_child(title)
	# A command chassis.
	var ch := FPanel.new()
	ch.position = Vector2(440, 520)
	ch.outline = PackedVector2Array([Vector2(18, 0), Vector2(150, 0), Vector2(177, 27), Vector2(177, 40), Vector2(400, 40), Vector2(426, 16), Vector2(426, 10), Vector2(450, -14), Vector2(800, -14), Vector2(822, 8), Vector2(822, 176), Vector2(798, 200), Vector2(21, 200), Vector2(0, 179), Vector2(0, 18)])
	ch.studs = [Vector4(18, 12, 7, 1), Vector4(808, 184, 7, 1), Vector4(14, 184, 7, 1), Vector4(438, 10, 9, 1)]
	ch.studs.append_array(SKIN.rivets_along(Vector2(30, 194), Vector2(790, 194), 140.0, 2.4))
	ch.opts = {"rim": 12.0, "inlay": 10.0}
	root.add_child(ch)
	await create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(OS.get_environment("FORGED_OUT"))
	quit(0)
