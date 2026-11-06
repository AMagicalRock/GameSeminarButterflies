var _s = obj_gameManager.ui_scale;
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_rectangle_color(0, 0, _gw, _gh, make_color_rgb(24, 38, 30), make_color_rgb(24, 38, 30), make_color_rgb(14, 22, 18), make_color_rgb(14, 22, 18), false);

draw_set_font(font_cute);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(c_white);
draw_text_transformed(_gw / 2, _gh * 0.28, "Bunnybloom Garden", _s * 3, _s * 3, 0);   // placeholder title

for (var i = 0; i < array_length(options); i++) {
    var _w = btn_w * anim[i];
    var _h = btn_h * anim[i];
    var _fill = !opt_on[i] ? make_color_rgb(50, 56, 52) : ((i == selected && !confirming) ? make_color_rgb(104, 168, 96) : make_color_rgb(62, 110, 66));
    draw_roundrect_color_ext(btn_x[i] - _w / 2, btn_y[i] - _h / 2, btn_x[i] + _w / 2, btn_y[i] + _h / 2, 18 * _s, 18 * _s, _fill, _fill, false);

    draw_set_color(opt_on[i] ? c_white : make_color_rgb(130, 136, 132));
    draw_text_transformed(btn_x[i], btn_y[i], options[i], _s * 1.2 * anim[i], _s * 1.2 * anim[i], 0);
}

if (message_timer > 0) {
    draw_set_color(c_yellow);
    draw_text_transformed(_gw / 2, _gh * 0.9, message, _s, _s, 0);
}

// --- The "delete this save?" popup, on top of everything ---
if (pop_alpha > 0) {
    // Dim the menu behind it
    draw_set_alpha(0.6 * pop_alpha);
    draw_rectangle_color(0, 0, _gw, _gh, c_black, c_black, c_black, c_black, false);

    // The panel
    draw_set_alpha(pop_alpha);
    var _ps = lerp(0.92, 1, pop_alpha);
    var _pw = panel_w * _ps;
    var _ph = panel_h * _ps;
    var _pc = make_color_rgb(40, 62, 48);
    draw_roundrect_color_ext(panel_x - _pw / 2, panel_y - _ph / 2, panel_x + _pw / 2, panel_y + _ph / 2, 24 * _s, 24 * _s, _pc, _pc, false);

    // The question wraps inside the panel, and a quieter line sits beneath it
    draw_set_color(c_white);
    var _text_scale = _s * 1.2;
    var _wrap = (panel_w * 0.85) / _text_scale;   // the width limit is measured before scaling
    draw_text_ext_transformed(panel_x, panel_y - 55 * _s, "Are you sure you wish to delete this save?", -1, _wrap, _text_scale, _text_scale, 0);
    draw_set_color(make_color_rgb(190, 200, 192));
    draw_text_transformed(panel_x, panel_y + 25 * _s, "This can't be undone.", _s, _s, 0);

    // Confirm and Back, beneath the text
    for (var i = 0; i < 2; i++) {
        var _bw = pop_btn_w * pop_anim[i];
        var _bh = pop_btn_h * pop_anim[i];
        var _hot = (i == pop_selected);
        var _bf;
        if (i == 0) _bf = _hot ? make_color_rgb(196, 84, 70) : make_color_rgb(150, 62, 54);        // Confirm is red
        else        _bf = _hot ? make_color_rgb(104, 168, 96) : make_color_rgb(62, 110, 66);       // Back is green
        draw_roundrect_color_ext(pop_x[i] - _bw / 2, pop_y - _bh / 2, pop_x[i] + _bw / 2, pop_y + _bh / 2, 18 * _s, 18 * _s, _bf, _bf, false);

        draw_set_color(c_white);
        draw_text_transformed(pop_x[i], pop_y, pop_options[i], _s * 1.2 * pop_anim[i], _s * 1.2 * pop_anim[i], 0);
    }

    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);

// TEMP DEBUG
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_yellow);
draw_text(10, 40, "pop_x " + string(pop_x[0]) + " / " + string(pop_x[1]) + "   btn_w " + string(pop_btn_w) + "   panel_w " + string(panel_w));
for (var i = 0; i < 2; i++) {
    draw_rectangle_color(pop_x[i] - pop_btn_w / 2, pop_y - pop_btn_h / 2, pop_x[i] + pop_btn_w / 2, pop_y + pop_btn_h / 2, c_red, c_red, c_red, c_red, true);
}
draw_rectangle_color(panel_x - panel_w / 2, panel_y - panel_h / 2, panel_x + panel_w / 2, panel_y + panel_h / 2, c_aqua, c_aqua, c_aqua, c_aqua, true);