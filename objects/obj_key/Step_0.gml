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
// Collect by walking over it, once it has finished popping in
if (revealed && pop_timer == 0 && point_distance(art_center_x(), art_center_y(), obj_player.x, obj_player.y) < 45) {
    obj_gameManager.collect_key(key_id, art_center_x(), art_center_y());
    instance_destroy();
}

// Ambient sparkles, owned by the key and stored in room coordinates
if (revealed && pop_timer == 0) {
    sparkle_timer -= 1;
    if (sparkle_timer <= 0) {
        sparkle_timer = irandom_range(6, 14);

        // The middle of the visible art, whatever the sprite's origin is
        var _cx = x + (sprite_get_width(sprite_index) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale;
        var _cy = y + (sprite_get_height(sprite_index) / 2 - sprite_get_yoffset(sprite_index)) * image_yscale;
        var _life = irandom_range(30, 50);

        array_push(glints, {
            x: _cx + random_range(-abs(sprite_width) / 2, abs(sprite_width) / 2),
            y: _cy + random_range(-abs(sprite_height) / 2, abs(sprite_height) / 2),
            vx: random_range(-0.25, 0.25),
            vy: random_range(-1.2, -0.6),
            life: _life, max_life: _life,
            size: random_range(6, 10),
            angle: random(360),
            spin: random_range(-3, 3),
            color: choose(c_white, make_color_rgb(255, 225, 90))
        });
    }
}

for (var i = array_length(glints) - 1; i >= 0; i--) {
    var _g = glints[i];
    _g.x += _g.vx;
    _g.y += _g.vy;
    _g.angle += _g.spin;
    _g.life -= 1;
    if (_g.life <= 0) array_delete(glints, i, 1);
}