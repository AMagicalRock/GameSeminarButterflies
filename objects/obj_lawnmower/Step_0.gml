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
    if (_dy < 0) {
        depth = obj_player.depth + 1; // facing back/back-right/back-left → mower renders behind
    } else {
        depth = obj_player.depth - 1; // facing front/front-right/front-left/pure left-right → mower renders in front
    }
}