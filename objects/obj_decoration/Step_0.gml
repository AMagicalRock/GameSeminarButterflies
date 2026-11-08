if (flat_on_ground || !instance_exists(obj_player)) exit;

var _p = obj_player;
var _pw = abs(_p.sprite_width) / 2;   // the player's drawn size, assuming a Middle Center origin like the rest of your sprites
var _ph = abs(_p.sprite_height) / 2;

// --- Falling leaves ---
if (leaf_sprite != -1) {
    // Only start new leaves while the tree is on or near the screen
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam);
    var _vy = camera_get_view_y(_cam);
    var _vw = camera_get_view_width(_cam);
    var _vh = camera_get_view_height(_cam);
    var _near = (art_r > _vx - 150 && art_l < _vx + _vw + 150 && art_b > _vy - 150 && art_t < _vy + _vh + 150);

    leaf_timer -= 1;
    if (leaf_timer <= 0) {
        leaf_timer = irandom_range(leaf_gap_min, leaf_gap_max);
        if (_near) {
            var _w = art_r - art_l;
            var _h = art_b - art_t;
            var _sx = random_range(art_l + _w * 0.2, art_r - _w * 0.2);       // somewhere across the canopy...
            var _sy = random_range(art_t + _h * 0.45, art_t + _h * 0.6);      // ...in the upper half of the sprite
            var _ground = max(bbox_bottom + random_range(-10, 25), _sy + 60);
            array_push(fall_leaves, {
                x: _sx, y: _sy,
                start_y: _sy,
                ground_y: _ground,
                speed: random_range(leaf_fall_speed_min, leaf_fall_speed_max),
                phase: random(360),
                sway_speed: random_range(0.02, 0.04),
                angle: random(360),
                spin: random_range(-0.5, 0.5),
                age: 0
            });
        }
    }

    for (var i = array_length(fall_leaves) - 1; i >= 0; i--) {
        var _l = fall_leaves[i];
        _l.age += 1;
        _l.y += _l.speed;
        _l.x += sin(_l.age * _l.sway_speed + _l.phase) * leaf_sway;
        _l.angle += _l.spin;
        if (_l.y >= _l.ground_y) array_delete(fall_leaves, i, 1);
    }
}

var _overlaps = (_p.x + _pw > art_l && _p.x - _pw < art_r
              && _p.y + _ph > art_t && _p.y - _ph < art_b);
var _behind = (_p.bbox_bottom < sort_line_y);

image_alpha = lerp(image_alpha, (_overlaps && _behind) ? 0.4 : 1, 0.15);