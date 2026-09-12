compute_ui_layout();

if (keyboard_check_pressed(vk_tab)) {
    shop_open = !shop_open;
    journal_open = false;
}
if (keyboard_check_pressed(ord("J"))) {
    journal_open = !journal_open;
    shop_open = false;
}

if (mouse_check_button_pressed(mb_left)) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _clicked_tab = false;

    for (var i = 0; i < array_length(tab_buttons); i++) {
        if (is_point_in_button(_mx, _my, tab_buttons[i])) {
            _clicked_tab = true;
            if (tab_buttons[i].action == "shop") {
                shop_open = !shop_open;
                journal_open = false;
            } else if (tab_buttons[i].action == "journal") {
                journal_open = !journal_open;
                shop_open = false;
            }
        }
    }

    if (!_clicked_tab && shop_open) {
        if (_mx > 260 * ui_scale && _mx < 300 * ui_scale && _my > 290 * ui_scale && _my < 330 * ui_scale && current_spread > 0) {
            current_spread -= 1;
        }
        if (_mx > 900 * ui_scale && _mx < 940 * ui_scale && _my > 290 * ui_scale && _my < 330 * ui_scale && current_spread < max_spread) {
            current_spread += 1;
        }

        var _left_page = current_spread * 2;
        var _right_page = current_spread * 2 + 1;

        for (var i = 0; i < array_length(shop_items); i++) {
            var _item = shop_items[i];
            if ((_item.page == _left_page || _item.page == _right_page) && is_point_in_button(_mx, _my, _item)) {
                buy_item(_item);
            }
        }
    }
}

var _hmx = device_mouse_x_to_gui(0);
var _hmy = device_mouse_y_to_gui(0);

for (var i = 0; i < array_length(tab_buttons); i++) {
    var _btn = tab_buttons[i];
    var _target_offset = is_point_in_button(_hmx, _hmy, _btn) ? 10 : 0;
    _btn.hover_offset = lerp(_btn.hover_offset, _target_offset, 0.2);
}

if (shop_open) {
    var _left_page = current_spread * 2;
    var _right_page = current_spread * 2 + 1;
    var _mouse_held = mouse_check_button(mb_left);

    for (var i = 0; i < array_length(shop_items); i++) {
        var _item = shop_items[i];
        if (_item.page != _left_page && _item.page != _right_page) continue;

        var _hovering = is_point_in_button(_hmx, _hmy, _item);
        var _target_scale = 1;
        if (_hovering && _mouse_held) _target_scale = 0.9;
        else if (_hovering) _target_scale = 1.1;

        _item.scale = lerp(_item.scale, _target_scale, 0.25);
    }
}

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