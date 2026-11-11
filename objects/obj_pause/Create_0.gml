options = ["Resume Game", "I'm Stuck", "Quit Game"];
selected = 0;
anim = [1, 1, 1];
alpha = 0;
last_mx = -1;
last_my = -1;
btn_x = [0, 0, 0];
btn_y = [0, 0, 0];
btn_w = 0;
btn_h = 0;
panel_x = 0;
panel_y = 0;
panel_w = 0;
panel_h = 0;

// The "teleport back to the shed?" popup
confirming = false;
conf_alpha = 0;
conf_options = ["Confirm", "Back"];
conf_selected = 1;      // Back starts highlighted, so a stray Enter can't teleport anyone
conf_anim = [1, 1];
conf_x = [0, 0];
conf_y = 0;
conf_btn_w = 0;
conf_btn_h = 0;
cpanel_w = 0;
cpanel_h = 0;

do_layout = function() {
    var _s = obj_gameManager.ui_scale;
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    panel_w = 560 * _s;
    panel_h = 420 * _s;
    panel_x = _gw / 2;
    panel_y = _gh / 2;

    btn_w = 360 * _s;
    btn_h = 64 * _s;
    var _gap = 22 * _s;
    var _top = panel_y - panel_h / 2 + 115 * _s;
    for (var i = 0; i < 3; i++) {
        btn_x[i] = panel_x;
        btn_y[i] = _top + btn_h / 2 + i * (btn_h + _gap);
    }

    cpanel_w = 680 * _s;
    cpanel_h = 320 * _s;
    conf_btn_w = 240 * _s;
    conf_btn_h = 64 * _s;
    // Back on the left and Confirm on the right, matching the main menu's popup
    conf_x[0] = panel_x + conf_btn_w / 2 + 24 * _s;
    conf_x[1] = panel_x - conf_btn_w / 2 - 24 * _s;
    conf_y = panel_y + cpanel_h / 2 - conf_btn_h / 2 - 34 * _s;
};

point_in_button = function(_i, _mx, _my) {
    return (abs(_mx - btn_x[_i]) < btn_w / 2 && abs(_my - btn_y[_i]) < btn_h / 2);
};

point_in_conf_button = function(_i, _mx, _my) {
    return (abs(_mx - conf_x[_i]) < conf_btn_w / 2 && abs(_my - conf_y) < conf_btn_h / 2);
};

activate = function(_i) {
    if (_i == 0) obj_gameManager.resume_game();
    else if (_i == 1) { confirming = true; conf_selected = 1; }
    else obj_gameManager.quit_from_pause();
};

activate_conf = function(_i) {
    if (_i == 0) obj_gameManager.unstick_player();   // Confirm
    else confirming = false;                         // Back
};

do_layout();

draw_menu = function() {
    var _s = obj_gameManager.ui_scale;
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    draw_set_alpha(0.55 * alpha);
    draw_rectangle_color(0, 0, _gw, _gh, c_black, c_black, c_black, c_black, false);

    draw_set_alpha(alpha);
    var _pc = make_color_rgb(40, 62, 48);
    draw_roundrect_color_ext(panel_x - panel_w / 2, panel_y - panel_h / 2, panel_x + panel_w / 2, panel_y + panel_h / 2, 24 * _s, 24 * _s, _pc, _pc, false);

    draw_set_font(font_cute);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_color(c_white);
    draw_text_transformed(panel_x, panel_y - panel_h / 2 + 55 * _s, "Paused", _s * 2, _s * 2, 0);

    for (var i = 0; i < 3; i++) {
        var _w = btn_w * anim[i];
        var _h = btn_h * anim[i];
        var _fill = (i == selected && !confirming) ? make_color_rgb(104, 168, 96) : make_color_rgb(62, 110, 66);
        draw_roundrect_color_ext(btn_x[i] - _w / 2, btn_y[i] - _h / 2, btn_x[i] + _w / 2, btn_y[i] + _h / 2, 18 * _s, 18 * _s, _fill, _fill, false);

        draw_set_color(c_white);
        draw_text_transformed(btn_x[i], btn_y[i], options[i], _s * 1.2 * anim[i], _s * 1.2 * anim[i], 0);
    }

    // --- The confirmation popup, on top of everything ---
    if (conf_alpha > 0) {
        draw_set_alpha(0.6 * conf_alpha);
        draw_rectangle_color(0, 0, _gw, _gh, c_black, c_black, c_black, c_black, false);

        draw_set_alpha(conf_alpha);
        var _cs = lerp(0.92, 1, conf_alpha);
        var _cw = cpanel_w * _cs;
        var _ch = cpanel_h * _cs;
        var _cc = make_color_rgb(40, 62, 48);
        draw_roundrect_color_ext(panel_x - _cw / 2, panel_y - _ch / 2, panel_x + _cw / 2, panel_y + _ch / 2, 24 * _s, 24 * _s, _cc, _cc, false);

        draw_set_color(c_white);
        var _ts = _s * 1.2;
        var _wrap = (cpanel_w * 0.85) / _ts;
        draw_text_ext_transformed(panel_x, panel_y - 55 * _s, "Teleport back to the shed?", -1, _wrap, _ts, _ts, 0);
        draw_set_color(make_color_rgb(190, 200, 192));
        draw_text_transformed(panel_x, panel_y + 20 * _s, "Use this if you're stuck. Your progress is kept.", _s * 0.9, _s * 0.9, 0);

        for (var i = 0; i < 2; i++) {
            var _bw = conf_btn_w * conf_anim[i];
            var _bh = conf_btn_h * conf_anim[i];
            var _bf = (i == conf_selected) ? make_color_rgb(104, 168, 96) : make_color_rgb(62, 110, 66);
            draw_roundrect_color_ext(conf_x[i] - _bw / 2, conf_y - _bh / 2, conf_x[i] + _bw / 2, conf_y + _bh / 2, 18 * _s, 18 * _s, _bf, _bf, false);

            draw_set_color(c_white);
            draw_text_transformed(conf_x[i], conf_y, conf_options[i], _s * 1.2 * conf_anim[i], _s * 1.2 * conf_anim[i], 0);
        }
    }

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
};