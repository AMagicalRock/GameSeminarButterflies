draw_self();

for (var i = 0; i < array_length(fall_leaves); i++) {
    var _l = fall_leaves[i];
    var _p = clamp((_l.y - _l.start_y) / (_l.ground_y - _l.start_y), 0, 1);    // 0 at the canopy, 1 at the ground
    var _a = clamp((0.85 - _p) / 0.35, 0, 1) * min(_l.age / 40, 1);            // fades in gently, then out before the ground
    var _s = leaf_size / sprite_get_width(leaf_sprite);
    draw_sprite_ext(leaf_sprite, 0, _l.x, _l.y, _s, _s, _l.angle, c_white, _a * image_alpha);
}