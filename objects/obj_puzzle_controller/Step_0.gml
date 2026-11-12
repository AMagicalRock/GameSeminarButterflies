if (hint_group != "") {
    if (hint_active && !hint_dismissed) hint_alpha = min(hint_alpha + 0.06, 1);
    else hint_alpha = max(hint_alpha - 0.05, 0);
}

if (leave_prompt) prompt_age += 1;

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
				dismiss_hint();
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

    // Move any flying pests along their path
    for (var i = 0; i < array_length(pests); i++) {
        var _p = pests[i];
        if (_p.flying) {
            _p.fly_progress += _p.fly_speed;
            var _from = leaf_spots[_p.spot_index];
            var _to = leaf_spots[_p.target_index];

            // Nearing a lifted leaf, that leaf slides back over its spot so the pest dives under cover
            if (_p.fly_progress >= 0.6 && _to.revealed) {
                _to.revealed = false;
                _to.target_ox = 0;
                _to.target_oy = 0;
            }

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

        // 1) A leaf covering a spot: lift it. Topmost first, and not while it's still settling
        var _clicked_leaf = -1;
        for (var i = array_length(leaf_spots) - 1; i >= 0; i--) {
            var _ls = leaf_spots[i];
            if (!_ls.revealed && _ls.cooldown <= 0 && point_distance(_mx, _my, _ls.x + _ls.offset_x, _ls.y + _ls.offset_y) < _leaf_hit_radius) {
                _clicked_leaf = i;
                break;
            }
        }

        if (_clicked_leaf != -1) {
            var _spot = leaf_spots[_clicked_leaf];
            _spot.revealed = true;
            _spot.cooldown = leaf_click_cooldown;

            var _off = pick_leaf_offset(_clicked_leaf);
            _spot.target_ox = _off.dx;
            _spot.target_oy = _off.dy;

            for (var i = 0; i < array_length(pests); i++) {
                var _p = pests[i];
                if (!_p.caught && !_p.flying && _p.spot_index == _clicked_leaf) {
                    if (_p.type == "dragonfly" && random(1) < _p.dash_chance) {
                        var _targets = [];
                        for (var j = 0; j < array_length(leaf_spots); j++) {
                            if (j != _p.spot_index && !is_spot_claimed(j) && !is_spot_occupied(j)) {
                                array_push(_targets, j);
                            }
                        }
                        if (array_length(_targets) > 0) {
                            _p.target_index = _targets[irandom(array_length(_targets) - 1)];
                            _p.flying = true;
                            _p.angle = point_direction(_p.x, _p.y, leaf_spots[_p.target_index].x, leaf_spots[_p.target_index].y) - 90;
                            _p.dash_chance *= dragonfly_chance_decay;
                        }
                    }
                    break;
                }
            }

        } else {
            // 2) A revealed pest: catch it
            var _caught_one = false;
            for (var i = 0; i < array_length(pests); i++) {
                var _p = pests[i];
                var _hit_radius = sprite_get_width(_p.sprite) * pest_scale * _p.scale_mult / 2;
                if (!_p.caught && !_p.flying && leaf_spots[_p.spot_index].revealed
                && point_distance(_mx, _my, _p.x, _p.y) < _hit_radius) {
                    _p.caught = true;
                    pests_found += 1;
                    dismiss_hint();
                    _caught_one = true;
                    break;
                }
            }

            // 3) A leaf that was moved aside: pull it back over its spot
            if (!_caught_one) {
                for (var i = array_length(leaf_spots) - 1; i >= 0; i--) {
                    var _ls = leaf_spots[i];
                    if (_ls.revealed && _ls.cooldown <= 0 && point_distance(_mx, _my, _ls.x + _ls.offset_x, _ls.y + _ls.offset_y) < _leaf_hit_radius) {
                        _ls.revealed = false;
                        _ls.cooldown = leaf_click_cooldown;
                        _ls.target_ox = 0;
                        _ls.target_oy = 0;
                        break;
                    }
                }
            }
        }
    }

    // Leaves ease toward wherever they're heading, and their cooldowns tick down
    for (var i = 0; i < array_length(leaf_spots); i++) {
        var _s = leaf_spots[i];
        _s.offset_x = lerp(_s.offset_x, _s.target_ox, leaf_slide_ease);
        _s.offset_y = lerp(_s.offset_y, _s.target_oy, leaf_slide_ease);
        if (_s.cooldown > 0) _s.cooldown -= 1;
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
            var _f = obj_gameManager.flower_slot_order[i];   // the real flower shown in slot i
            var _pos = flower_positions[i];

            if (point_distance(_mx, _my, _pos.x, _pos.y) < 25) {
                if (obj_gameManager.unlocked_flowers[_f]) {
                    var _first_time = (source_task.planted_flower == -1);
                    var _old_type = source_task.planted_flower;

                    source_task.planted_flower = _f;
                    source_task.sprite_index = obj_gameManager.flower_sprites[_f];
                    source_task.always_on_ground = false;
                    source_task.depth = -source_task.bbox_bottom;
                    variable_struct_set(obj_gameManager.planted_flowers, source_task.task_id, _f);

                    var _area = obj_gameManager.areas[obj_gameManager.current_area_index];
                    if (_first_time) {
                        _area.planted_counts[_f] += 1;
                    } else if (_old_type != _f) {
                        _area.planted_counts[_old_type] -= 1;
                        _area.planted_counts[_f] += 1;
                    }
                    obj_gameManager.rebuild_flower_positions();

                    if (_first_time) {
                        source_task.completed = true;
                        obj_gameManager.mark_task_completed(source_task.task_id);
                        obj_gameManager.add_progress(obj_gameManager.current_area_index);
                    }
					
					dismiss_hint();
                }
                close_puzzle("select");
                break;
            }
        }
    }

    if (keyboard_check_pressed(ord("E"))) {
        close_puzzle("cancel");
    }
}


if (puzzle_type == "shop") {
    var _s = obj_gameManager.ui_scale;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _clicked = mouse_check_button_pressed(mb_left);
    var _hover_found = noone;

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

        if (_hovering && _hover_found == noone) _hover_found = _item;

        var _target_scale = _hovering ? 1.15 : 1;
        _item.scale = lerp(_item.scale, _target_scale, 0.25);

        if (_hovering && _clicked) {
            if (obj_gameManager.buy_item(_item.source)) _item.removing = true;
        }
    }

    // The hover box fades in over an item and out when the mouse leaves or the item is bought
    if (_hover_found != noone) tip_item = _hover_found;
    tip_alpha = lerp(tip_alpha, (_hover_found != noone) ? 1 : 0, 0.25);

    if (keyboard_check_pressed(ord("E"))) close_puzzle("cancel");
}

if (puzzle_type == "sign") {
    if (keyboard_check_pressed(ord("E"))) {
        close_puzzle("cancel");
    }
}

if (puzzle_type == "thanks") {
    thanks_age += 1;
    thanks_alpha = lerp(thanks_alpha, 1, 0.12);

    // E is ignored for the first moment, so a stray press can't close it before it's been read
    if (thanks_age > 45 && keyboard_check_pressed(ord("E"))) close_puzzle("cancel");
}