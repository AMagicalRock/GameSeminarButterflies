if (can_interact) {
    var _highlight_alpha = lerp(image_alpha, 1, 0.5);
    shader_set(shd_outline);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 1.15, image_yscale * 1.15, image_angle, c_white, _highlight_alpha);
    shader_reset();
}
draw_self();