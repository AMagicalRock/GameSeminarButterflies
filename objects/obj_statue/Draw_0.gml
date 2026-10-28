if (obj_player.near_statue == id) {
    draw_outline_sprite(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, lerp(image_alpha, 1, 0.5));
}

draw_self();   // the empty statue

// Trophies sitting on the statue
for (var i = 0; i < 3; i++) {
    if (placed[i]) {
        var _b = (bounce[i] > 0) ? 1 + sin((bounce[i] / 20) * pi) * 0.2 * (1 - bounce[i] / 20) : 1;
        draw_sprite_ext(trophy_sprites[i], 0, x + slot_x[i] * image_xscale, y + slot_y[i] * image_yscale, image_xscale * _b, image_yscale * _b, 0, c_white, image_alpha);
    }
}

// Trophies still in the air
for (var f = 0; f < array_length(flights); f++) {
    var _fl = flights[f];
    if (_fl.delay > 0) continue;
    var _p = _fl.t / 26;
    var _e = _p * _p * (3 - 2 * _p);
    var _fx = lerp(_fl.sx, x + slot_x[_fl.i] * image_xscale, _e);
    var _fy = lerp(_fl.sy, y + slot_y[_fl.i] * image_yscale, _e) - sin(_p * pi) * 70;
    var _fs = lerp(1.4, 1, _e);
    draw_sprite_ext(trophy_sprites[_fl.i], 0, _fx, _fy, image_xscale * _fs, image_yscale * _fs, 0, c_white, 1);
}

// The details layer
if (details_alpha > 0) {
    draw_sprite_ext(spr_statue_details, 0, x, y, image_xscale, image_yscale, 0, c_white, details_alpha * image_alpha);
}

// TEMP DEBUG: hold G to preview all three trophy slots, then delete this block
if (keyboard_check(ord("G"))) {
    for (var i = 0; i < 3; i++) {
        draw_sprite_ext(trophy_sprites[i], 0, x + slot_x[i] * image_xscale, y + slot_y[i] * image_yscale, image_xscale, image_yscale, 0, c_white, 0.5);
    }
}