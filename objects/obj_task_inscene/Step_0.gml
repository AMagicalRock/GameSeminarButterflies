event_inherited();

if (task_type == "prune" || task_type == "pest" || (task_type == "flower" && planted_flower != -1)) {
    var _near = (point_distance(x, y, obj_player.x, obj_player.y) < sprite_width / 2 + 10);

    if (_near && !was_near_player) {
        bounce_timer = 1;
    }
    was_near_player = _near;

    if (bounce_timer > 0) {
        bounce_timer += 1;
        if (bounce_timer > 20) bounce_timer = 0;
    }

    if (bounce_timer > 0) {
        var _t = bounce_timer / 20;
        var _squash = sin(_t * pi) * (1 - _t);
        image_yscale = 1 - _squash * 0.15;
        image_xscale = 1 + _squash * 0.1;
    } else {
        image_yscale = 1;
        image_xscale = 1;
    }
}