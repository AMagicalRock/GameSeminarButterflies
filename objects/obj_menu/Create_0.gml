options = ["New Game", "Continue", "Quit"];
opt_on = [true, obj_gameManager.has_save(), true];
selected = opt_on[1] ? 1 : 0;
anim = [1, 1, 1];
last_mx = -1;
last_my = -1;
busy = false;
message = "";
message_timer = 0;
btn_x = [0, 0, 0];
btn_y = [0, 0, 0];
btn_w = 0;
btn_h = 0;

// The "delete this save?" popup
confirming = false;
pop_alpha = 0;
pop_options = ["Confirm", "Back"];
pop_selected = 1;      // Back starts highlighted, so a stray Enter can't erase a save
pop_anim = [1, 1];
pop_x = [0, 0];
pop_y = 0;
pop_btn_w = 0;
pop_btn_h = 0;
panel_x = 0;
panel_y = 0;
panel_w = 0;
panel_h = 0;

// Everything is positioned from the screen's size every frame, so window resizing works
do_layout = function() {
    var _s = obj_gameManager.ui_scale;
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    btn_w = 360 * _s;
    btn_h = 64 * _s;
    var _gap = 22 * _s;
    var _top = _gh * 0.5;
    for (var i = 0; i < array_length(options); i++) {
        btn_x[i] = _gw / 2;
        btn_y[i] = _top + btn_h / 2 + i * (btn_h + _gap);
    }

    panel_w = 720 * _s;
    panel_h = 340 * _s;
    panel_x = _gw / 2;
    panel_y = _gh / 2;

    pop_btn_w = 240 * _s;
    pop_btn_h = 64 * _s;
    pop_x[0] = panel_x + pop_btn_w / 2 - 24 * _s;
    pop_x[1] = panel_x - pop_btn_w / 2 + 24 * _s;
    pop_y = panel_y + panel_h / 2 - pop_btn_h / 2 - 36 * _s;
};

point_in_button = function(_i, _mx, _my) {
    return (abs(_mx - btn_x[_i]) < btn_w / 2 && abs(_my - btn_y[_i]) < btn_h / 2);
};

point_in_pop_button = function(_i, _mx, _my) {
    return (abs(_mx - pop_x[_i]) < pop_btn_w / 2 && abs(_my - pop_y) < pop_btn_h / 2);
};

start_new_game = function() {
    busy = true;
    obj_gameManager.delete_save();
    room_goto(Room_Tutorial);
};

activate = function(_i) {
    if (busy || !opt_on[_i]) exit;

    if (_i == 0) {                                      // New Game
        if (obj_gameManager.has_save()) {
            confirming = true;                          // ask before erasing a save
            pop_selected = 1;
        } else {
            start_new_game();                           // nothing to lose, so no question
        }
    } else if (_i == 1) {                               // Continue
        if (obj_gameManager.load_game()) {
            busy = true;
        } else {
            message = "That save couldn't be loaded.";
            message_timer = 3 * game_get_speed(gamespeed_fps);
        }
    } else {                                            // Quit
        busy = true;
        game_end();
    }
};

activate_pop = function(_i) {
    if (_i == 0) start_new_game();                      // Confirm
    else confirming = false;                            // Back
};