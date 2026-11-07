options = ["Resume Game", "Quit Game"];
selected = 0;
anim = [1, 1];
alpha = 0;
last_mx = -1;
last_my = -1;
btn_x = [0, 0];
btn_y = [0, 0];
btn_w = 0;
btn_h = 0;
panel_x = 0;
panel_y = 0;
panel_w = 0;
panel_h = 0;

do_layout = function() {
    var _s = obj_gameManager.ui_scale;
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    panel_w = 560 * _s;
    panel_h = 360 * _s;
    panel_x = _gw / 2;
    panel_y = _gh / 2;

    btn_w = 360 * _s;
    btn_h = 64 * _s;
    var _gap = 22 * _s;
    var _top = panel_y - panel_h / 2 + 125 * _s;
    for (var i = 0; i < 2; i++) {
        btn_x[i] = panel_x;
        btn_y[i] = _top + btn_h / 2 + i * (btn_h + _gap);
    }
};

point_in_button = function(_i, _mx, _my) {
    return (abs(_mx - btn_x[_i]) < btn_w / 2 && abs(_my - btn_y[_i]) < btn_h / 2);
};

activate = function(_i) {
    if (_i == 0) obj_gameManager.resume_game();
    else obj_gameManager.quit_from_pause();
};

do_layout();

// The menu's drawing lives here, but obj_gameManager calls it
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

    for (var i = 0; i < 2; i++) {
        var _w = btn_w * anim[i];
        var _h = btn_h * anim[i];
        var _fill = (i == selected) ? make_color_rgb(104, 168, 96) : make_color_rgb(62, 110, 66);
        draw_roundrect_color_ext(btn_x[i] - _w / 2, btn_y[i] - _h / 2, btn_x[i] + _w / 2, btn_y[i] + _h / 2, 18 * _s, 18 * _s, _fill, _fill, false);

        draw_set_color(c_white);
        draw_text_transformed(btn_x[i], btn_y[i], options[i], _s * 1.2 * anim[i], _s * 1.2 * anim[i], 0);
    }

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
};