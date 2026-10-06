compute_ui_layout();

if (keyboard_check_pressed(vk_f1)) {
    for (var i = 0; i < array_length(unlocked_flowers); i++) unlocked_flowers[i] = true;
    show_debug_message("DEBUG: all flowers unlocked");
}

if (keyboard_check_pressed(vk_f2)) {
    if (current_area_index != -1) {
        var _a = areas[current_area_index];
        var _next_milestone = noone;

        for (var i = 0; i < array_length(_a.milestones); i++) {
            if (!_a.milestones[i].triggered) {
                _next_milestone = _a.milestones[i];
                break;
            }
        }

        if (_next_milestone != noone) {
            var _needed_percent = _next_milestone.percent;
            var _needed_completed = ceil((_needed_percent / 100) * _a.total_tasks);
            _a.completed_tasks = max(_a.completed_tasks, _needed_completed);
            check_milestones(current_area_index);
            show_debug_message("DEBUG: jumped to " + string(_needed_percent) + "% in " + _a.name);
        } else if (_a.completed_tasks < _a.total_tasks) {
            _a.completed_tasks = _a.total_tasks;
            check_milestones(current_area_index);
            show_debug_message("DEBUG: no milestones left, jumped straight to 100% in " + _a.name);
        } else {
            show_debug_message("DEBUG: " + _a.name + " is already fully complete");
        }
    }
}

if (current_area_index != -1) {
    var _a = areas[current_area_index];

    for (var i = 0; i < array_length(_a.planted_counts); i++) {
        var _num = instance_number(obj_butterfly);
        var _of_type_alive = [];

        for (var k = 0; k < _num; k++) {
            var _bfly = instance_find(obj_butterfly, k);
            if (_bfly.flower_type == i && _bfly.state == "alive") {
                array_push(_of_type_alive, _bfly);
            }
        }

        var _excess = array_length(_of_type_alive) - _a.planted_counts[i];
        for (var e = 0; e < _excess; e++) {
            _of_type_alive[e].state = "fading";
        }
    }

    var _allowed = get_allowed_butterfly_count(current_area_index);
    var _active = instance_number(obj_butterfly);

    if (_active < _allowed) {
        butterfly_spawn_timer -= 1;
        if (butterfly_spawn_timer <= 0) {
            butterfly_spawn_timer = 120;
            var _candidates = [];

            for (var i = 0; i < array_length(_a.planted_counts); i++) {
                var _flying_of_type = 0;
                var _num = instance_number(obj_butterfly);

                for (var k = 0; k < _num; k++) {
                    var _bfly = instance_find(obj_butterfly, k);
                    if (_bfly.flower_type == i && _bfly.state == "alive") {
                        _flying_of_type += 1;
                    }
                }

                if (_flying_of_type < _a.planted_counts[i]) {
                    array_push(_candidates, i);
                }
            }

            if (array_length(_candidates) > 0) {
                var _type = _candidates[irandom(array_length(_candidates) - 1)];
                var _b = instance_create_layer(irandom_range(100, room_width - 100), irandom_range(100, room_height - 100), "Instances", obj_butterfly);
                _b.flower_type = _type;
                _b.sprite_index = butterfly_data[_type].sprite;
                butterfly_discovered[_type] = true;
            }
        }
    }
}

if (current_area_index != -1) {
    var _a = areas[current_area_index];
    var _inset_y = ui_bar_h * 0.06;
    var _fill_y_offset = 4;
    var _track_h = ui_bar_h - (_inset_y * 2);
    var _x_offsets = [-15, 15, -15, 15];

    for (var i = 0; i < array_length(_a.milestones); i++) {
        var _m = _a.milestones[i];

        _m.marker_y = ui_bar_y + _inset_y + _fill_y_offset + (_track_h * (1 - _m.percent / 100));
        _m.marker_x = ui_bar_x + ui_bar_w / 2 + (_x_offsets[i] * ui_scale);

        // Set up animation fields the first time this milestone is ever seen
        if (!variable_struct_exists(_m, "anim_state")) {
            _m.anim_state = "idle";
            _m.anim_timer = 0;
            _m.shake_x = 0;
            _m.visual_scale = 1;
        }

        // The moment a milestone becomes triggered, kick off the animation
        if (_m.triggered && _m.anim_state == "idle") {
            _m.anim_state = "shake";
            _m.anim_timer = 0;
        }

        switch (_m.anim_state) {
            case "shake":
                _m.anim_timer += 1;
                var _t = _m.anim_timer / 30;
                _m.shake_x = sin(_m.anim_timer * 1.2) * 6 * (1 - _t);
                if (_m.anim_timer >= 30) {
                    _m.anim_state = "grow";
                    _m.anim_timer = 0;
                    _m.shake_x = 0;
                }
                break;

			case "grow":
			    _m.anim_timer += 1;
			    _m.visual_scale = lerp(1, 1.5, _m.anim_timer / 15);
			    if (_m.anim_timer >= 15) {
			        _m.anim_state = "burst";
			        _m.anim_timer = 0;
				if (_m.type == "money") {
				    spawn_money_particles(_m.marker_x, _m.marker_y, 8, _m.amount);
			        }
			    }
			    break;

            case "burst":
                _m.anim_timer += 1;
                _m.visual_scale = lerp(1.5, 1, _m.anim_timer / 10);
                if (_m.anim_timer >= 10) {
                    _m.anim_state = "done";
                    _m.visual_scale = 1;
                }
                break;
        }
    }
}

for (var i = array_length(money_particles) - 1; i >= 0; i--) {
    var _p = money_particles[i];

    if (_p.delay > 0) {
        _p.delay -= 1;
        continue;
    }

	_p.progress += _p.speed;
	if (_p.progress >= 1) {
	    if (_p.is_last) spawn_money_popup(_p.amount);
	    array_delete(money_particles, i, 1);
	    continue;
	}

	var _ease = 1 - power(1 - _p.progress, 2);
	_p.x = lerp(_p.start_x, money_text_x, _ease);
	_p.y = lerp(_p.start_y, money_text_y, _ease) - sin(_p.progress * pi) * 40;
}

for (var i = array_length(money_popups) - 1; i >= 0; i--) {
    var _pu = money_popups[i];
    _pu.timer += 1;

	if (_pu.state == "counting") {
	    _pu.display = lerp(0, _pu.amount, _pu.timer / 20);
	    if (_pu.timer >= 20) {
	        _pu.display = _pu.amount;
	        _pu.state = "holding";
	        _pu.timer = 0;
	    }
	} else if (_pu.state == "holding") {
        if (_pu.timer >= 25) { // sits still for about 0.4s before floating off
            _pu.state = "floating";
            _pu.timer = 0;
        }

	} else { // floating
	    _pu.y -= 2.5; // faster upward movement (was 0.6)
	    _pu.alpha = 1; // no fade — stays fully visible
	    if (_pu.timer >= 10) {
	        money += _pu.amount;
	        money_counter_bounce = -12;
	        array_delete(money_popups, i, 1);
	    }
	}
}

money_counter_bounce = lerp(money_counter_bounce, 0, 0.2);