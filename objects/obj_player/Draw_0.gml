draw_self();

if (interacting_with != noone && instance_exists(interacting_with) && interacting_with.hold_time > 0) {
    var _fill = interacting_with.hold_time / interacting_with.hold_time_max;

    var _bar_scale = 1.1; // tune to taste
    var _bar_w = sprite_get_width(ui_litterPBBack) * _bar_scale;
    var _bar_h = sprite_get_height(ui_litterPBBack) * _bar_scale;

    // Top-left corner of the bar, centered above the player's head
    var _left = x - _bar_w / 2;
    var _top = y - sprite_height / 2 - 12 - _bar_h;

    // draw_sprite_ext places the sprite's origin at the given point, so offset by
    // the origin to land the top-left corner exactly where we want, whatever the origin is
    var _ox = sprite_get_xoffset(ui_litterPBBack) * _bar_scale;
    var _oy = sprite_get_yoffset(ui_litterPBBack) * _bar_scale;

    // Padding between the sprite's edge and the actual fill track (tune against your art)
    var _inset_x = _bar_w * 0.01;
    var _inset_y = _bar_h * 0.25;
    var _track_w = _bar_w - _inset_x * 2;
    var _fill_w = _track_w * _fill;

    draw_sprite_ext(ui_litterPBBack, 0, _left + _ox, _top + _oy, _bar_scale, _bar_scale, 0, c_white, 1);
    draw_rectangle_color(_left + _inset_x, _top + _inset_y, _left + _inset_x + _fill_w, _top + _bar_h - _inset_y, c_lime, c_lime, c_lime, c_lime, false);
    draw_sprite_ext(ui_litterPBFront, 0, _left + _ox, _top + _oy, _bar_scale, _bar_scale, 0, c_white, 1);

    // The picker rides the leading edge of the fill, chomping open and closed
    var _picker_sprite = ((floor(current_time / 150) mod 2) == 0) ? ui_litterpickerPB_open : ui_litterpickerPB_close;
    var _picker_x = _left + _inset_x + _fill_w;
    var _picker_y = _top + _bar_h / 2;
    draw_sprite_ext(_picker_sprite, 0, _picker_x, _picker_y, _bar_scale, _bar_scale, 0, c_white, 1);
}