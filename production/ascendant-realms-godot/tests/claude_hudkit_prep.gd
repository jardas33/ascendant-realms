extends SceneTree
# Plan 432: crop Codex's painted HUD masters to their art, clear faint alpha
# residue and halve them for the game. Source: D:/CodexData (read only).
const SRC := "D:/CodexData/art/ascendant-hud-painted-kit-20261023/"
const PIECES := [
	["masters/frame_master_r2.png", Rect2i(56, 93, 1662, 677), "frame"],
	["masters/portrait_socket_r1.png", Rect2i(48, 71, 1158, 1110), "portrait_socket"],
	["minimap_r1/minimap_housing_master_r2.png", Rect2i(52, 60, 1094, 1175), "minimap_housing"],
	["masters/command_backing_r1.png", Rect2i(104, 117, 1044, 1019), "command_backing"],
	["masters/bar_trough_r2.png", Rect2i(30, 367, 1712, 154), "bar_trough"],
]
func _init():
	var out := "res://assets/ui/hud_kit/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	for p in PIECES:
		var img := Image.load_from_file(SRC + p[0])
		img.convert(Image.FORMAT_RGBA8)
		var c: Image = img.get_region(p[1])
		for y in c.get_height():
			for x in c.get_width():
				var col := c.get_pixel(x, y)
				if col.a < 0.08:
					c.set_pixel(x, y, Color(0, 0, 0, 0))
		c.resize(c.get_width() / 2, c.get_height() / 2, Image.INTERPOLATE_LANCZOS)
		c.save_png(out + p[2] + ".png")
		print("KIT ", p[2], " ", c.get_size())
		if p[2] == "command_backing":
			# The slate inside the command backing: the plate of every panel.
			var slate: Image = c.get_region(Rect2i(60, 60, 400, 388))
			slate.save_png(out + "plate_slate.png")
			print("KIT plate_slate ", slate.get_size())
		if p[2] == "frame":
			# The straight top rail alone (outer bronze, iron, inner bronze),
			# drawn along any HUD outline by hud_painted_rim.gd.
			var rail: Image = c.get_region(Rect2i(100, 4, 630, 34))
			rail.save_png(out + "rail.png")
			print("KIT rail ", rail.get_size())
	quit()
