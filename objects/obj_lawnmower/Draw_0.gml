if (obj_player.near_mower == id) {
    draw_outline_sprite(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, lerp(image_alpha, 1, 0.5));
}
draw_sprite_ext(sprite_index, image_index, x + shake_x, y + shake_y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);