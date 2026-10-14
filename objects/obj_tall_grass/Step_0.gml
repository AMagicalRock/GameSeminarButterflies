event_inherited();

var _near = (point_distance(x, y, obj_player.x, obj_player.y) < sprite_width / 2 + 10);

if (_near && !was_near_player) {
    bounce_timer = 1;
}
was_near_player = _near;

// --- Bounce dials ---
var _duration = 30;      // frames the bounce lasts (was 20)
var _squash_y = 0.2;     // how much it flattens (was 0.15)
var _squash_x = 0.15;     // how much it widens (was 0.1)
var _wobbles = 3;        // 1 = a single squash like before, 3 = squash, stretch, squash

if (bounce_timer > 0) {
    bounce_timer += 1;
    if (bounce_timer > _duration) bounce_timer = 0;
}

if (bounce_timer > 0) {
    var _t = bounce_timer / _duration;
    var _squash = sin(_t * pi * _wobbles) * (1 - _t);
    image_yscale = 1 - _squash * _squash_y;
    image_xscale = 1 + _squash * _squash_x;
} else {
    image_yscale = 1;
    image_xscale = 1;
}