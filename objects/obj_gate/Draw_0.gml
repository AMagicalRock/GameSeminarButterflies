// Closed (or unsplit): one sprite, with the normal highlight
if (!(use_split && is_open)) {
    if (can_interact) {
        draw_outline_sprite(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, lerp(image_alpha, 1, 0.5));
    }
    draw_self();
    exit;
}

// Open and split: this object draws the top piece, and obj_gate_front draws the bottom one
draw_sprite_ext(top_open, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 1);