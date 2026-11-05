do_layout();

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _moved = (_mx != last_mx || _my != last_my);
last_mx = _mx;
last_my = _my;

if (confirming) {
    // Only the popup responds while it's open
    if (_moved) {
        for (var i = 0; i < 2; i++) {
            if (point_in_pop_button(i, _mx, _my)) pop_selected = i;
        }
    }

    var _h = (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")))
           - (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")));
    if (_h != 0) pop_selected = clamp(pop_selected + _h, 0, 1);

    if (keyboard_check_pressed(vk_escape)) {
        confirming = false;
    } else if (mouse_check_button_pressed(mb_left)) {
        for (var i = 0; i < 2; i++) {
            if (point_in_pop_button(i, _mx, _my)) activate_pop(i);
        }
    } else if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("E"))) {
        activate_pop(pop_selected);
    }
} else if (!busy) {
    var _n = array_length(options);

    // Moving the mouse selects whatever it's over
    if (_moved) {
        for (var i = 0; i < _n; i++) {
            if (opt_on[i] && point_in_button(i, _mx, _my)) selected = i;
        }
    }

    // Keyboard: up and down skip anything disabled
    var _dir = (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")))
             - (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")));
    if (_dir != 0) {
        repeat (_n) {
            selected = (selected + _dir + _n) mod _n;
            if (opt_on[selected]) break;
        }
    }

    var _clicked = mouse_check_button_pressed(mb_left) && point_in_button(selected, _mx, _my);
    if (_clicked || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("E"))) {
        activate(selected);
    }
}

for (var i = 0; i < array_length(options); i++) {
    anim[i] = lerp(anim[i], (i == selected && !confirming) ? 1.08 : 1, 0.25);
}
for (var i = 0; i < 2; i++) {
    pop_anim[i] = lerp(pop_anim[i], (confirming && i == pop_selected) ? 1.08 : 1, 0.25);
}

pop_alpha = lerp(pop_alpha, confirming ? 1 : 0, 0.3);
if (!confirming && pop_alpha < 0.02) pop_alpha = 0;

if (message_timer > 0) message_timer -= 1;