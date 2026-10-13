function draw_outline_sprite(_spr, _img, _x, _y, _xscale, _yscale, _angle, _alpha) {
    var _grow = 1.15;   // rim thickness: raise for a bolder outline

    // Where the sprite's visual centre sits relative to its origin, in unscaled pixels
    var _cx = sprite_get_width(_spr) / 2 - sprite_get_xoffset(_spr);
    var _cy = sprite_get_height(_spr) / 2 - sprite_get_yoffset(_spr);

    // Shift the enlarged copy so it grows evenly around the original's centre
    var _ox = -_cx * _xscale * (_grow - 1);
    var _oy = -_cy * _yscale * (_grow - 1);

    shader_set(shd_outline);
    draw_sprite_ext(_spr, _img, _x + _ox, _y + _oy, _xscale * _grow, _yscale * _grow, _angle, c_white, _alpha);
    shader_reset();
}