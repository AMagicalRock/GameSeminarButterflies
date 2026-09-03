if (obj_player.interacting_with == id) {
    var _hw = sprite_width * abs(image_xscale) * 0.65;
    var _hh = sprite_height * abs(image_yscale) * 0.65;
    draw_ellipse_color(x - _hw, y - _hh, x + _hw, y + _hh, c_white, c_white, false);
}

draw_self();