if (keyboard_check_pressed(vk_f1)) {
    for (var i = 0; i < array_length(unlocked_flowers); i++) {
        unlocked_flowers[i] = true;
    }
    show_debug_message("DEBUG: all flowers unlocked");
}

if (current_area_index != -1) {
    var _allowed = get_allowed_butterfly_count(current_area_index);
    var _active = instance_number(obj_butterfly);

    if (_active < _allowed) {
        butterfly_spawn_timer -= 1;
        if (butterfly_spawn_timer <= 0) {
            butterfly_spawn_timer = 120;

            var _a = areas[current_area_index];
            var _candidates = [];

            for (var i = 0; i < array_length(_a.planted_counts); i++) {
                var _flying_of_type = 0;
                var _num = instance_number(obj_butterfly);

                for (var k = 0; k < _num; k++) {
                    var _bfly = instance_find(obj_butterfly, k);
                    if (_bfly.flower_type == i) {
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
            }
        }
    }
}

if (current_area_index != -1) {
    var _a = areas[current_area_index];

    // --- Despawn excess butterflies whose type is no longer wanted ---
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

    // --- Existing spawn logic, with one small change below ---
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
                    if (_bfly.flower_type == i && _bfly.state == "alive") { // <-- added state check
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
            }
        }
    }
}