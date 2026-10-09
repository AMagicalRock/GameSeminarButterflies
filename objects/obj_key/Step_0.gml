if (pop_timer > 0) {
    pop_timer += 1;
    var _t = min(pop_timer / 25, 1);
    var _u = _t - 1;
    var _s = 1 + 2.70158 * _u * _u * _u + 1.70158 * _u * _u;
    image_xscale = base_scale * _s;
    image_yscale = base_scale * _s;
    if (pop_timer >= 25) {
        pop_timer = 0;
        image_xscale = base_scale;
        image_yscale = base_scale;
    }
}

// Collect by walking over it, once it has finished popping in
if (revealed && pop_timer == 0 && point_distance(x, y, obj_player.x, obj_player.y) < 45) {
    obj_gameManager.collect_key(key_id, x, y);
    instance_destroy();
}

// Ambient sparkles while the key sits on the ground
if (revealed && pop_timer == 0) {
    sparkle_timer -= 1;
    if (sparkle_timer <= 0) {
        sparkle_timer = irandom_range(6, 14);
        obj_gameManager.spawn_ambient_sparkle(
            x + random_range(-abs(sprite_width) / 2, abs(sprite_width) / 2),
            y + random_range(-abs(sprite_height) / 2, abs(sprite_height) / 2)
        );
    }
}