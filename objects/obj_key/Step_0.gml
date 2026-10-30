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
if (revealed && pop_timer == 0 && point_distance(art_center_x(), art_center_y(), obj_player.x, obj_player.y) < 45) {
    obj_gameManager.collect_key(key_id, art_center_x(), art_center_y());
    instance_destroy();
}

// Ambient sparkles that drift outward from the middle of the art
if (revealed && pop_timer == 0) {
    sparkle_timer -= 1;
    if (sparkle_timer <= 0) {
        sparkle_timer = irandom_range(6, 14);

        var _cx = art_center_x();
        var _cy = art_center_y();
        var _hw = abs(sprite_width) / 2;
        var _hh = abs(sprite_height) / 2;

        var _a = random(360);                    // the direction this sparkle travels
        var _start = random_range(0.2, 0.8);     // how far out it begins: 0 = the middle, 1 = the edge of the art
        var _spd = random_range(0.8, 1.6);       // outward speed, before drag slows it
        var _life = irandom_range(30, 50);

        array_push(glints, {
            x: _cx + lengthdir_x(_hw * _start, _a),
            y: _cy + lengthdir_y(_hh * _start, _a),
            vx: lengthdir_x(_spd, _a),
            vy: lengthdir_y(_spd, _a),
            life: _life, max_life: _life,
            size: random_range(6, 10),
            angle: random(360),
            spin: random_range(-3, 3),
            sprite: obj_gameManager.sparkle_sprites[irandom(array_length(obj_gameManager.sparkle_sprites) - 1)]
        });
    }
}

for (var i = array_length(glints) - 1; i >= 0; i--) {
    var _g = glints[i];
    _g.x += _g.vx;
    _g.y += _g.vy;
    _g.vx *= 0.97;    // drag: they burst outward, then ease to a stop
    _g.vy *= 0.97;
    _g.angle += _g.spin;
    _g.life -= 1;
    if (_g.life <= 0) array_delete(glints, i, 1);
}