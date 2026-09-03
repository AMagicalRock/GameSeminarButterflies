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

    // Move any flying pests along their path
    for (var i = 0; i < array_length(pests); i++) {
        var _p = pests[i];
        if (_p.flying) {
            _p.fly_progress += _p.fly_speed;
            var _from = leaf_spots[_p.spot_index];
            var _to = leaf_spots[_p.target_index];

            if (_p.fly_progress >= 1) {
                _p.x = _to.x;
                _p.y = _to.y;
                _p.spot_index = _p.target_index;
                _p.target_index = -1;
                _p.flying = false;
                _p.fly_progress = 0;
            } else {
                _p.x = lerp(_from.x, _to.x, _p.fly_progress);
                _p.y = lerp(_from.y, _to.y, _p.fly_progress);
            }
        }
    }

    if (mouse_check_button_pressed(mb_left)) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        // First check: did they click an unrevealed leaf?
        var _clicked_leaf = -1;
        for (var i = 0; i < array_length(leaf_spots); i++) {
            if (!leaf_spots[i].revealed && point_distance(_mx, _my, leaf_spots[i].x, leaf_spots[i].y) < 18) {
                _clicked_leaf = i;
                break;
            }
        }

        if (_clicked_leaf != -1) {
            leaf_spots[_clicked_leaf].revealed = true;

            // If a pest lives here, this is the moment it gets "spotted" — roll the flee chance once
            for (var i = 0; i < array_length(pests); i++) {
                var _p = pests[i];
                if (!_p.caught && !_p.flying && _p.spot_index == _clicked_leaf) {
                    if (obj_gameManager.current_area_index == 2 && irandom_range(1, 1000) <= pest_dash_chance) {
                        var _targets = [];
                        for (var j = 0; j < array_length(leaf_spots); j++) {
                            if (j != _p.spot_index && !leaf_spots[j].revealed && !is_spot_claimed(j)) {
                                array_push(_targets, j);
                            }
                        }
                        if (array_length(_targets) > 0) {
                            _p.target_index = _targets[irandom(array_length(_targets) - 1)];
                            _p.flying = true;
                        }
                    }
                    break;
                }
            }

        } else {
            // Otherwise, check if they clicked a visible (revealed, grounded) pest
            for (var i = 0; i < array_length(pests); i++) {
                var _p = pests[i];
                if (!_p.caught && !_p.flying && leaf_spots[_p.spot_index].revealed
                && point_distance(_mx, _my, _p.x, _p.y) < 14) {
                    _p.caught = true;
                    pests_found += 1;
                    break;
                }
            }
        }
    }

    if (pests_found >= pest_count) close_puzzle("success");
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