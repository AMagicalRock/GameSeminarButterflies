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