draw_self();

if (interacting_with != noone && instance_exists(interacting_with) && interacting_with.hold_time > 0) {
    var _fill = interacting_with.hold_time / interacting_with.hold_time_max;

    var _bar_scale = 0.8;   // tune to taste
    var _bar_w = sprite_get_width(ui_litterPBBack) * _bar_scale;
    var _bar_h = sprite_get_height(ui_litterPBBack) * _bar_scale;

    // Top-left corner of the bag, centered above the player's head
    var _left = x - _bar_w / 2;
    var _top = y - sprite_height / 2 - 12 - _bar_h;

    // draw_sprite_ext puts the sprite's origin at the point you give it, so offset by the
    // origin to land the top-left corner exactly here, whatever origin the art uses
    var _ox = sprite_get_xoffset(ui_litterPBBack) * _bar_scale;
    var _oy = sprite_get_yoffset(ui_litterPBBack) * _bar_scale;

    // Padding between the bag's edge and the fill area (tune against the art)
    var _inset_x = _bar_w * 0.15;
    var _inset_y = _bar_h * 0.12;
    var _track_h = _bar_h - _inset_y * 2;
    var _fill_h = _track_h * _fill;

    // The fill's bottom edge stays put and its top edge rises
    var _fill_x1 = _left + _inset_x;
    var _fill_x2 = _left + _bar_w - _inset_x;
    var _fill_y2 = _top + _bar_h - _inset_y;
    var _fill_y1 = _fill_y2 - _fill_h;

    draw_sprite_ext(ui_litterPBBack, 0, _left + _ox, _top + _oy, _bar_scale, _bar_scale, 0, c_white, 1);
	// Bottom-to-top reveal of the fill sprite
	var _fw = sprite_get_width(ui_litterPBFill);
	var _fh = sprite_get_height(ui_litterPBFill);
	var _part_h = round(_fh * _fill);   // how many pixel rows of the sprite to show

	if (_part_h > 0) {
	    draw_sprite_part_ext(
	        ui_litterPBFill, 0,
	        0, _fh - _part_h,                              // start this far down the sprite...
	        _fw, _part_h,                                  // ...and keep just the bottom slice
	        _left, _top + (_fh - _part_h) * _bar_scale,    // draw the slice where it belongs on the bag
	        _bar_scale, _bar_scale, c_white, 1
	    );
	}
    draw_sprite_ext(ui_litterPBFront, 0, _left + _ox, _top + _oy, _bar_scale, _bar_scale, 0, c_white, 1);

    // The picker icon sits above the bag, fixed in place, and only swaps between open and closed
    var _upgraded = variable_struct_exists(obj_gameManager.purchased, "litterpicker");
    var _is_open = ((floor(current_time / 250) mod 2) == 0);

    var _icon;
    if (_upgraded) {
        _icon = _is_open ? ui_litterpickerPB_upgraded_open : ui_litterpickerPB_upgraded_close;
    } else {
        _icon = _is_open ? ui_litterpickerPB_open : ui_litterpickerPB_close;
    }

    var _icon_scale = _bar_scale;   // tune separately if the icon looks too big or small
    var _icon_gap = 0;              // negative values overlap the bag, positive values float above it
    var _icon_cx = _left + _bar_w / 2;
    var _icon_cy = _top - _icon_gap - (sprite_get_height(_icon) * _icon_scale) / 2;

    // Aim the icon's visual centre at (_icon_cx, _icon_cy) whatever its origin is
    var _icon_x = _icon_cx - (sprite_get_width(_icon) / 2 - sprite_get_xoffset(_icon)) * _icon_scale;
    var _icon_y = _icon_cy - (sprite_get_height(_icon) / 2 - sprite_get_yoffset(_icon)) * _icon_scale;

    draw_sprite_ext(_icon, 0, _icon_x, _icon_y, _icon_scale, _icon_scale, 0, c_white, 1);
}

// TEMP DEBUG
draw_set_alpha(0.35);
draw_rectangle_color(bbox_left, bbox_top, bbox_right, bbox_bottom, c_blue, c_blue, c_blue, c_blue, false);
draw_set_alpha(1);