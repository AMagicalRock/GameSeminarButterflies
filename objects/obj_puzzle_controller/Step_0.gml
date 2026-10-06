if (puzzle_type == "prune") {
    has_upgraded_shears = variable_struct_exists(obj_gameManager.purchased, "shears");
    active_cursor_sprite = has_upgraded_shears ? spr_shears_upgraded_open : spr_shears_basic_open;
    cut_radius = has_upgraded_shears ? 60 : 20;
    window_set_cursor(cr_none);

    var _clicking = mouse_check_button(mb_left);
    if (has_upgraded_shears) {
        active_cursor_sprite = _clicking ? spr_shears_upgraded_closed : spr_shears_upgraded_open;
    } else {
        active_cursor_sprite = _clicking ? spr_shears_basic_closed : spr_shears_basic_open;
    }

	if (mouse_check_button_pressed(mb_left)) {
	    var _mx = device_mouse_x_to_gui(0);
	    var _my = device_mouse_y_to_gui(0);

	    for (var i = 0; i < array_length(leaves); i++) {
	        if (!leaves[i].removed && !leaves[i].falling && point_distance(_mx, _my, leaves[i].x, leaves[i].y) < cut_radius) {
	            leaves[i].falling = true;
	        }
	    }
	}

	for (var i = 0; i < array_length(leaves); i++) {
	    if (leaves[i].falling && !leaves[i].removed) {
	        leaves[i].fall_offset += 2;
	        leaves[i].fall_alpha -= 0.04;
	        if (leaves[i].fall_alpha <= 0) {
	            leaves[i].fall_alpha = 0;
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
    var _clicking = mouse_check_button(mb_left);
    active_cursor_sprite = _clicking ? spr_gloves_close : spr_gloves_open;
    window_set_cursor(cr_none);
    var _leaf_hit_radius = sprite_get_width(spr_leaf_g_1) * leaf_scale / 2;
    var _pest_hit_radius = sprite_get_width(spr_pest_dragonfly) * pest_scale / 2;

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

        var _clicked_leaf = -1;
        for (var i = 0; i < array_length(leaf_spots); i++) {
            if (!leaf_spots[i].revealed && point_distance(_mx, _my, leaf_spots[i].x, leaf_spots[i].y) < _leaf_hit_radius) {
                _clicked_leaf = i;
                break;
            }
        }

        if (_clicked_leaf != -1) {
            var _spot = leaf_spots[_clicked_leaf];
            _spot.revealed = true;
            _spot.removing = true;

            var _move_angle = irandom_range(0, 359);
            _spot.offset_dx = lengthdir_x(1, _move_angle);
            _spot.offset_dy = lengthdir_y(1, _move_angle);

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
                            _p.angle = point_direction(_p.x, _p.y, leaf_spots[_p.target_index].x, leaf_spots[_p.target_index].y) - 90;
                        }
                    }
                    break;
                }
            }

        } else {
            for (var i = 0; i < array_length(pests); i++) {
                var _p = pests[i];
                if (!_p.caught && !_p.flying && leaf_spots[_p.spot_index].revealed
                && point_distance(_mx, _my, _p.x, _p.y) < _pest_hit_radius) {
                    _p.caught = true;
                    pests_found += 1;
                    break;
                }
            }
        }
    }

    for (var i = 0; i < array_length(leaf_spots); i++) {
        var _s = leaf_spots[i];
        if (_s.removing) {
            _s.offset_x += _s.offset_dx * 2;
            _s.offset_y += _s.offset_dy * 2;
            _s.reveal_alpha -= 0.05;
            if (_s.reveal_alpha <= 0) {
                _s.reveal_alpha = 0;
                _s.removing = false;
            }
        }
    }

    for (var i = 0; i < array_length(pests); i++) {
        var _p = pests[i];
        if (_p.caught && _p.pop_timer < 10) {
            _p.pop_timer += 1;
            if (_p.pop_timer <= 4) {
                _p.pop_scale = lerp(1, 1.4, _p.pop_timer / 4);
            } else {
                _p.pop_scale = lerp(1.4, 0, (_p.pop_timer - 4) / 6);
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
					var _old_type = source_task.planted_flower;

					source_task.planted_flower = i;
					source_task.sprite_index = obj_gameManager.flower_sprites[i];
					source_task.always_on_ground = false;
					source_task.depth = -source_task.bbox_bottom;
					variable_struct_set(obj_gameManager.planted_flowers, source_task.task_id, i);

					var _area = obj_gameManager.areas[obj_gameManager.current_area_index];
					if (_first_time) {
						_area.planted_counts[i] += 1;
					} else if (_old_type != i) {
					 _area.planted_counts[_old_type] -= 1;
					 _area.planted_counts[i] += 1;
					}

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

if (puzzle_type == "shop") {
    var _s = obj_gameManager.ui_scale;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _clicked = mouse_check_button_pressed(mb_left);

    for (var i = array_length(shop_display_items) - 1; i >= 0; i--) {
        var _item = shop_display_items[i];
        var _btn_x = anchor_x + _item.offset_x * _s;
        var _btn_y = anchor_y + _item.offset_y * _s;
        var _hovering = is_point_on_sprite_pixel(_mx, _my, _item, _btn_x, _btn_y);

        if (_item.removing) {
            _item.scale = lerp(_item.scale, 0, 0.3);
            _item.alpha = lerp(_item.alpha, 0, 0.3);
            if (_item.alpha < 0.05) array_delete(shop_display_items, i, 1);
            continue;
        }

        var _target_scale = _hovering ? 1.15 : 1;
        _item.scale = lerp(_item.scale, _target_scale, 0.25);

        if (_hovering && _clicked) {
            if (obj_gameManager.buy_item(_item.source)) _item.removing = true;
        }
    }

    if (keyboard_check_pressed(ord("E"))) close_puzzle("cancel");
}

if (puzzle_type == "sign") {
    if (keyboard_check_pressed(ord("E"))) {
        close_puzzle("cancel");
    }
}