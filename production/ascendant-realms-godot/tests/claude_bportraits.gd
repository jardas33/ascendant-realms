extends SceneTree
## Plan 525: every building's selection portrait (the large single card) in
## one sheet per people, with no painting, so live-model framing shows.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(1600, 1000)
	var gd = root.get_node("/root/GameData")
	var races: Array = OS.get_environment("CLAUDE_RACES").split(",") if OS.get_environment("CLAUDE_RACES") != "" else gd.RACES.keys()
	for race in races:
		var holder := Control.new()
		root.add_child(holder)
		var bg := ColorRect.new(); bg.color = Color(0.1, 0.1, 0.1); bg.size = Vector2(1600, 1000); holder.add_child(bg)
		var i := 0
		for bid in gd.buildings_for_race(race):
			var d: Dictionary = gd.get_building(bid).duplicate()
			d.erase("command_art")
			var p = load("res://scripts/ui/entity_portrait_view.gd").new()
			p.custom_minimum_size = Vector2(150, 150)
			p.size = Vector2(150, 150)
			p.position = Vector2(10 + (i % 9) * 175, 10 + (i / 9) * 195)
			holder.add_child(p)
			var l := Label.new(); l.text = String(bid).replace(race + "_", ""); l.position = p.position + Vector2(0, 155); holder.add_child(l)
			p.configure_definition(d, true)
			i += 1
		for f in 12:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("D:/ClaudeWork/tmp/bport/%s.png" % race)
		holder.queue_free()
		await process_frame
	quit(0)
