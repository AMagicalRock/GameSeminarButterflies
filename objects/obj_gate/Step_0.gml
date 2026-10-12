event_inherited();   // keeps the fade-when-occluded behaviour

can_interact = !is_open && distance_to_object(obj_player) < 40;

if (can_interact && keyboard_check_pressed(ord("E")) && !global.player_locked) {
    is_open = true;
    sprite_index = sprite_open;
    depth = -bbox_bottom;   // the open sprite may have a different footprint
    obj_gameManager.mark_task_completed(gate_id);
    open_timer = 1;
}

// A quick squash-and-stretch bounce as it opens
if (open_timer > 0) {
    open_timer += 1;
    var _t = min(open_timer / 20, 1);
    var _squash = sin(_t * pi) * (1 - _t);
    image_xscale = base_xscale * (1 + _squash * 0.1);
    image_yscale = base_yscale * (1 - _squash * 0.15);
    if (open_timer >= 20) {
        open_timer = 0;
        image_xscale = base_xscale;
        image_yscale = base_yscale;
    }
}