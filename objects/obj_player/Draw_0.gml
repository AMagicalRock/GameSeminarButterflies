draw_self(); // keep drawing the player sprite as normal

if (interacting_with != noone && instance_exists(interacting_with) && interacting_with.hold_time > 0) {
    var _bar_w = 32;
    var _bar_h = 6;
    var _bar_x = x - _bar_w / 2;
    var _bar_y = y - sprite_height / 2 - 12;
    var _fill = interacting_with.hold_time / interacting_with.hold_time_max;

    draw_rectangle_color(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, c_gray, c_gray, c_gray, c_gray, false);
    draw_rectangle_color(_bar_x, _bar_y, _bar_x + _bar_w * _fill, _bar_y + _bar_h, c_lime, c_lime, c_lime, c_lime, false);
}