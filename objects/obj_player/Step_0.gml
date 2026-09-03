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
var _move_speed = 5;
x += _input_x * _move_speed;
y += _input_y * _move_speed;

// --- Sprite direction ---
if (_input_x != 0 || _input_y != 0) {
    if (_input_x == 0 && _input_y < 0) {
        sprite_index = spr_player_back;
        image_xscale = sprite_scale;
        image_yscale = sprite_scale;
    } else if (_input_x == 0 && _input_y > 0) {
        sprite_index = spr_player_front;
        image_xscale = sprite_scale;
        image_yscale = sprite_scale;
    } else if (_input_y == 0) {
        sprite_index = spr_player_right;
        image_xscale = (_input_x > 0) ? sprite_scale : -sprite_scale;
        image_yscale = sprite_scale;
    } else if (_input_y < 0) {
        sprite_index = spr_player_back_right;
        image_xscale = (_input_x > 0) ? sprite_scale : -sprite_scale;
        image_yscale = sprite_scale;
    } else {
        sprite_index = spr_player_front_right;
        image_xscale = (_input_x > 0) ? sprite_scale : -sprite_scale;
        image_yscale = sprite_scale;
    }
}

// --- Task interaction ---
interacting_with = instance_nearest(x, y, obj_task_inscene);

if (interacting_with != noone
	&& point_distance(x, y, interacting_with.x, interacting_with.y) < 70
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
				        var _type = interacting_with.task_type;
				        var _area = obj_gameManager.current_area_index;
				        var _min_count, _max_count;

				        if (_type == "prune") {
				            switch (_area) {
				                case 0: _min_count = 2; _max_count = 3; break;
				                case 1: _min_count = 4; _max_count = 5; break;
				                case 2: _min_count = 6; _max_count = 7; break;
				            }
				        } else if (_type == "pest") {
				            switch (_area) {
				                case 1: _min_count = 2; _max_count = 3; break; // Area 2
				                case 2: _min_count = 4; _max_count = 5; break; // Area 3
				            }
				        } else {
				            _min_count = 3; _max_count = 3;
				        }

				        instance_create_layer(0, 0, "Instances", obj_puzzle_controller, {
				            puzzle_type: _type,
				            source_task: interacting_with,
				            active_tile_count: irandom_range(_min_count, _max_count)
				        });
				        global.player_locked = true;
				    }
}
    } else {
        interacting_with = noone;
    }
}

// --- Camera follow ---
var _cam = view_camera[0];
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

var _target_x = x - _cam_w / 2;
var _target_y = y - _cam_h / 2;

_target_x = clamp(_target_x, 0, max(0, room_width - _cam_w));
_target_y = clamp(_target_y, 0, max(0, room_height - _cam_h));

camera_set_view_pos(_cam, _target_x, _target_y);