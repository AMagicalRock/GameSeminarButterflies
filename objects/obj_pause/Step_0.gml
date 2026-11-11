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
            if (point_in_conf_button(i, _mx, _my)) conf_selected = i;
        }
    }

    var _hz = (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")))
            - (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")));
    if (_hz != 0) conf_selected = clamp(conf_selected - _hz, 0, 1);   // Confirm sits on the right, so the arrows are flipped

    if (mouse_check_button_pressed(mb_left)) {
        for (var i = 0; i < 2; i++) {
            if (point_in_conf_button(i, _mx, _my)) {
                activate_conf(i);
                exit;
            }
        }
    } else if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        activate_conf(conf_selected);
        exit;
    }
} else {
    if (_moved) {
        for (var i = 0; i < 3; i++) {
            if (point_in_button(i, _mx, _my)) selected = i;
        }
    }

    var _dir = (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")))
             - (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")));
    if (_dir != 0) selected = clamp(selected + _dir, 0, 2);

    var _clicked = mouse_check_button_pressed(mb_left) && point_in_button(selected, _mx, _my);
    if (_clicked || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        activate(selected);
        exit;   // this object may have just been destroyed
    }
}

for (var i = 0; i < 3; i++) {
    anim[i] = lerp(anim[i], (i == selected && !confirming) ? 1.08 : 1, 0.25);
}
for (var i = 0; i < 2; i++) {
    conf_anim[i] = lerp(conf_anim[i], (confirming && i == conf_selected) ? 1.08 : 1, 0.25);
}

alpha = lerp(alpha, 1, 0.3);
conf_alpha = lerp(conf_alpha, confirming ? 1 : 0, 0.3);
if (!confirming && conf_alpha < 0.02) conf_alpha = 0;