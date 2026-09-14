compute_ui_layout();

// Keyboard button controls
if (keyboard_check_pressed(vk_tab)) {
    shop_open = !shop_open;
    if (shop_open) focused_window = "shop";
}
if (keyboard_check_pressed(ord("J"))) {
    journal_open = !journal_open;
    if (journal_open) focused_window = "journal";
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
                if (shop_open) focused_window = "shop";
            } else if (tab_buttons[i].action == "journal") {
                journal_open = !journal_open;
                if (journal_open) focused_window = "journal";
            }
        }
    }

    if (!_clicked_tab) {
        var _first = focused_window;
        var _second = (focused_window == "shop") ? "journal" : "shop";
        var _handled = (_first == "shop") ? handle_shop_click(_mx, _my) : handle_journal_click(_mx, _my);

        if (_handled) {
            focused_window = _first;
        } else {
            var _handled2 = (_second == "shop") ? handle_shop_click(_mx, _my) : handle_journal_click(_mx, _my);
            if (_handled2) focused_window = _second;
        }
    }
}

if (shop_dragging) {
    if (mouse_check_button(mb_left)) {
        var _mx2 = device_mouse_x_to_gui(0);
        var _my2 = device_mouse_y_to_gui(0);
        shop_offset_x = drag_start_off_x + (_mx2 - drag_start_mx) / ui_scale;
        shop_offset_y = drag_start_off_y + (_my2 - drag_start_my) / ui_scale;

        var _bg_w = (shop_background_sprite != -1) ? sprite_get_width(shop_background_sprite) : 700;
        var _bg_h = (shop_background_sprite != -1) ? sprite_get_height(shop_background_sprite) : 400;

        var _min_x = -608;
        var _max_x = max(_min_x, (display_get_gui_width() / ui_scale) - (608 + _bg_w));
        shop_offset_x = clamp(shop_offset_x, _min_x, _max_x);

        var _min_y = -128;
        var _max_y = max(_min_y, (display_get_gui_height() / ui_scale) - (128 + _bg_h));
        shop_offset_y = clamp(shop_offset_y, _min_y, _max_y);
    } else {
        shop_dragging = false;
    }
}

if (journal_dragging) {
    if (mouse_check_button(mb_left)) {
        var _mx3 = device_mouse_x_to_gui(0);
        var _my3 = device_mouse_y_to_gui(0);
        journal_offset_x = drag_start_off_x + (_mx3 - drag_start_mx) / ui_scale;
        journal_offset_y = drag_start_off_y + (_my3 - drag_start_my) / ui_scale;

        var _current_sprite = journal_pages[current_journal_spread].sprite;
        var _bg_w = sprite_get_width(_current_sprite);
        var _bg_h = sprite_get_height(_current_sprite);

        var _jmin_x = -page_x;
        var _jmax_x = max(_jmin_x, (display_get_gui_width() / ui_scale) - (page_x + _bg_w));
        journal_offset_x = clamp(journal_offset_x, _jmin_x, _jmax_x);

        var _jmin_y = -page_y;
        var _jmax_y = max(_jmin_y, (display_get_gui_height() / ui_scale) - (page_y + _bg_h));
        journal_offset_y = clamp(journal_offset_y, _jmin_y, _jmax_y);
    } else {
        journal_dragging = false;
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
    var _left_page2 = current_spread * 2;
    var _right_page2 = current_spread * 2 + 1;
    var _mouse_held = mouse_check_button(mb_left);
    var _shifted_hmx = _hmx - shop_offset_x * ui_scale;
    var _shifted_hmy = _hmy - shop_offset_y * ui_scale;

    for (var i = 0; i < array_length(shop_items); i++) {
        var _item = shop_items[i];
        if (_item.page != _left_page2 && _item.page != _right_page2) continue;

        var _hovering = is_point_in_button(_shifted_hmx, _shifted_hmy, _item);
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