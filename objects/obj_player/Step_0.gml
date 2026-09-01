if (!global.player_locked) {

// Get input direction (-1, 0, or 1 on each axis)
var _input_x = (keyboard_check(vk_right) || keyboard_check(ord("D"))) 
             - (keyboard_check(vk_left)  || keyboard_check(ord("A")));
var _input_y = (keyboard_check(vk_down)  || keyboard_check(ord("S"))) 
             - (keyboard_check(vk_up)    || keyboard_check(ord("W")));

// Normalize so diagonal movement isn't faster than straight movement
var _length = point_distance(0, 0, _input_x, _input_y);
if (_length > 0) {
	_input_x /= _length;
    _input_y /= _length;
}

// Apply movement
var _move_speed = 4;
x += _input_x * _move_speed;
y += _input_y * _move_speed;

// --- Task interaction ---
interacting_with = instance_nearest(x, y, obj_task_inscene);

if (interacting_with != noone
	&& point_distance(x, y, interacting_with.x, interacting_with.y) < 32
	&& (!interacting_with.completed || interacting_with.always_interactable)) {

        if (interacting_with.task_category == "hold") {
            if (keyboard_check(ord("E"))) {
                interacting_with.hold_time += 1;
                if (interacting_with.hold_time >= interacting_with.hold_time_max) {
                    interacting_with.completed = true;
                    obj_gameManager.complete_task(interacting_with);
                    interacting_with = noone;
                }
            } else {
                interacting_with.hold_time = max(interacting_with.hold_time - 2, 0);
            }

			} else if (interacting_with.task_category == "popup") {
			    if (keyboard_check_pressed(ord("E"))) {
			        var _min_tiles, _max_tiles;
			        switch (obj_gameManager.current_area_index) {
			            case 0: _min_tiles = 2; _max_tiles = 3; break;
			            case 1: _min_tiles = 4; _max_tiles = 5; break;
			            case 2: _min_tiles = 6; _max_tiles = 7; break;
			        }

			        instance_create_layer(0, 0, "Instances", obj_puzzle_controller, {
			            puzzle_type: interacting_with.task_type,
			            source_task: interacting_with,
			            active_tile_count: irandom_range(_min_tiles, _max_tiles)
			        });
			        global.player_locked = true;
			    }
}
    } else {
        interacting_with = noone;
    }
}