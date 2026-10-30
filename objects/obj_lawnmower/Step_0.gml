// --- Motor shake ---
if (instance_exists(obj_player)) {
    var _target_strength = 0;
    if (mounted) {
        // Idles at 1 and rattles harder while the player is actually driving it
        var _moved = point_distance(obj_player.x, obj_player.y, player_last_x, player_last_y) > 0.1;
        _target_strength = _moved ? 1.6 : 1;
    }
    player_last_x = obj_player.x;
    player_last_y = obj_player.y;

    shake_strength = lerp(shake_strength, _target_strength, 0.2);

    // A fast wave plus a little randomness reads as an engine, not a regular wobble
    shake_x = (sin(current_time * 0.09) * 0.7 + random_range(-0.5, 0.5)) * shake_strength * shake_amount;
    shake_y = (sin(current_time * 0.13 + 1) * 0.7 + random_range(-0.5, 0.5)) * shake_strength * shake_amount;
}

if (mounted) {
    var _dx = obj_player.dir_x;
    var _dy = obj_player.dir_y;
    var _foot_y = obj_player.y + (obj_player.sprite_height * obj_player.image_yscale) / 2;

    var _x_offset = (_dy == 0) ? side_offset : fb_offset;

    x = obj_player.x + _dx * _x_offset;
    y = _foot_y + _dy * fb_offset;

	if (_dx == 0 && _dy < 0) {
		sprite_index = spr_lawnmower_back; image_xscale = sprite_scale;
	} else if (_dx == 0 && _dy > 0) {
		sprite_index = spr_lawnmower_front; image_xscale = sprite_scale;
	} else if (_dy == 0) {
		sprite_index = spr_lawnmower_right; image_xscale = (_dx > 0) ? sprite_scale : -sprite_scale;
	} else if (_dy < 0) {
		sprite_index = spr_lawnmower_back_right; image_xscale = (_dx > 0) ? sprite_scale : -sprite_scale;
	} else {
		sprite_index = spr_lawnmower_front_right; image_xscale = (_dx > 0) ? sprite_scale : -sprite_scale;
	}
	
	    // Depth needs to update every frame, since facing can change while mounted
	depth = -bbox_bottom;
}