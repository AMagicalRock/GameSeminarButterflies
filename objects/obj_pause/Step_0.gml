do_layout();

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// Moving the mouse selects whatever it's over
if (_mx != last_mx || _my != last_my) {
    last_mx = _mx;
    last_my = _my;
    for (var i = 0; i < 2; i++) {
        if (point_in_button(i, _mx, _my)) selected = i;
    }
}

var _dir = (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")))
         - (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")));
if (_dir != 0) selected = clamp(selected + _dir, 0, 1);

var _clicked = mouse_check_button_pressed(mb_left) && point_in_button(selected, _mx, _my);
if (_clicked || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    activate(selected);
    exit;   // this object may have just been destroyed
}

for (var i = 0; i < 2; i++) {
    anim[i] = lerp(anim[i], (i == selected) ? 1.08 : 1, 0.25);
}
alpha = lerp(alpha, 1, 0.3);