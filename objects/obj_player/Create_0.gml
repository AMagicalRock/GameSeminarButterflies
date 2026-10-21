depth = -1;
sprite_scale = 0.5; // 0.5 = half size, 1 = original size, 2 = double size, etc.
sprite_index = spr_player_front;
image_xscale = sprite_scale;
image_yscale = sprite_scale;
near_shop = noone;
near_sign = noone;
near_mower = noone;

dir_x = 0;
dir_y = 1; // default facing down/front, matching your default sprite
mounted_mower = noone;
base_move_speed = 4;

// If we were sent here by a doorway, move to that spot
if (variable_global_exists("spawn_x")) {
    x = global.spawn_x;
    y = global.spawn_y;
}

exit_armed = false;     // switched on in the Step Event once the player isn't standing on an exit
pushing_door = noone;

// Arrived through an exit: keep walking exactly as before the cut
if (variable_global_exists("carry") && is_struct(global.carry)) {
    dir_x = global.carry.dir_x;
    dir_y = global.carry.dir_y;
    sprite_index = global.carry.sprite;
    image_xscale = global.carry.xscale;
    global.carry = undefined;
}

is_blocked = function(_x, _y) {
    if (place_meeting(_x, _y, obj_wall)) return true;

    var _g = instance_place(_x, _y, obj_gate);
    if (_g != noone && !_g.is_open) return true;

    // A door that isn't open yet is solid; remember which one so it can react
    var _d = instance_place(_x, _y, obj_doorway);
    if (_d != noone && !_d.is_passable()) {
        pushing_door = _d;
        return true;
    }
    return false;
};