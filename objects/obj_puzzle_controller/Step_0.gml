if (puzzle_type == "prune") {
    if (mouse_check_button_pressed(mb_left)) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        for (var i = 0; i < array_length(leaves); i++) {
            if (!leaves[i].removed && point_distance(_mx, _my, leaves[i].x, leaves[i].y) < 14) {
                leaves[i].removed = true;
            }
        }
    }

    var _all_gone = true;
    for (var i = 0; i < array_length(leaves); i++) {
        if (!leaves[i].removed) { _all_gone = false; break; }
    }
    if (_all_gone) close_puzzle("success");
}

if (puzzle_type == "pest") {

    // Spawn a new predator from a random screen edge periodically
    spawn_timer -= 1;
    if (spawn_timer <= 0) {
        spawn_timer = spawn_interval;
        var _edge = irandom(3);
        var _px, _py;
		switch (_edge) {
			case 0: _px = irandom_range(anchor_x - window_hw, anchor_x + window_hw); _py = anchor_y - window_hh; break; // top
		  case 1: _px = irandom_range(anchor_x - window_hw, anchor_x + window_hw); _py = anchor_y + window_hh; break; // bottom
		  case 2: _px = anchor_x - window_hw; _py = irandom_range(anchor_y - window_hh, anchor_y + window_hh); break; // left
		 case 3: _px = anchor_x + window_hw; _py = irandom_range(anchor_y - window_hh, anchor_y + window_hh); break; // right
		}
        array_push(predators, { x: _px, y: _py, speed: 1.5 });
    }

    // Move every predator toward the caterpillar
    for (var i = array_length(predators) - 1; i >= 0; i--) {
        var _p = predators[i];
        var _dir = point_direction(_p.x, _p.y, caterpillar_x, caterpillar_y);
        _p.x += lengthdir_x(_p.speed, _dir);
        _p.y += lengthdir_y(_p.speed, _dir);

        if (point_distance(_p.x, _p.y, caterpillar_x, caterpillar_y) < 15) {
            close_puzzle("fail"); // reached the caterpillar — window just closes
            exit;
        }
    }

    // Click to remove a predator
    if (mouse_check_button_pressed(mb_left)) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        for (var i = array_length(predators) - 1; i >= 0; i--) {
            if (point_distance(_mx, _my, predators[i].x, predators[i].y) < 18) {
                array_delete(predators, i, 1);
                break;
            }
        }
    }

    // Success condition: survive long enough
    survive_time += 1;
    if (survive_time >= survive_time_target) {
        close_puzzle("success");
    }
}

if (puzzle_type == "flower") {
    if (mouse_check_button_pressed(mb_left)) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        for (var i = 0; i < 6; i++) {
            var _pos = flower_positions[i];
            if (point_distance(_mx, _my, _pos.x, _pos.y) < 25) {
				if (obj_gameManager.unlocked_flowers[i]) {
				    var _first_time = (source_task.planted_flower == -1);
				    source_task.planted_flower = i;
				    source_task.sprite_index = obj_gameManager.flower_sprites[i]; // <-- new line
				    variable_struct_set(obj_gameManager.planted_flowers, source_task.task_id, i);

				    if (_first_time) {
				        source_task.completed = true;
				        obj_gameManager.mark_task_completed(source_task.task_id);
				        obj_gameManager.add_progress(obj_gameManager.current_area_index);
				    }
				}
                close_puzzle("select");
                break;
            }
        }
    }

    if (keyboard_check_pressed(ord("E"))) {
        close_puzzle("cancel"); // close without changing anything
    }
}