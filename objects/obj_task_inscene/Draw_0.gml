if (obj_player.interacting_with == id) {
    var _y_shift = 0;
    if (task_type == "flower" && planted_flower != -1) {
        var _h = sprite_height * abs(image_yscale);
        _y_shift = _h * 0.15 / 2;
    }

    var _highlight_alpha = lerp(image_alpha, 1, 0.5);

    shader_set(shd_outline);
    draw_sprite_ext(sprite_index, image_index, x, y + _y_shift, image_xscale * 1.15, image_yscale * 1.15, image_angle, c_white, _highlight_alpha);
    shader_reset();
}

draw_self();