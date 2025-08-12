extends StaticBody2D




func _on_mast_area_body_entered(body: StaticBody2D) -> void:
	hide()
	print("Player Entered Area")
	
