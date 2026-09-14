if (current_area_index != -1) {
    var _percent = get_area_percent(current_area_index);
    var _fill_h = ui_bar_h * (_percent / 100);

    draw_rectangle_color(ui_bar_x, ui_bar_y, ui_bar_x + ui_bar_w, ui_bar_y + ui_bar_h, c_gray, c_gray, c_gray, c_gray, false);
    draw_rectangle_color(ui_bar_x, ui_bar_y + (ui_bar_h - _fill_h), ui_bar_x + ui_bar_w, ui_bar_y + ui_bar_h, c_lime, c_lime, c_lime, c_lime, false);

    draw_set_color(c_white);
    draw_text(ui_bar_x - 30, ui_bar_y - 20, areas[current_area_index].name);
    draw_text(ui_bar_x - 35, ui_bar_y + ui_bar_h + 10 - 40, string(floor(_percent)) + "%");
}

for (var i = 0; i < array_length(tab_buttons); i++) {
    var _btn = tab_buttons[i];
    draw_sprite_ext(_btn.sprite, 0, (_btn.x + _btn.hover_offset) * ui_scale, _btn.y * ui_scale, ui_scale, ui_scale, 0, c_white, 1);
}

for (var i = 0; i < array_length(tab_buttons); i++) {
    var _btn = tab_buttons[i];
    draw_sprite_ext(_btn.sprite, 0, (_btn.x + _btn.hover_offset) * ui_scale, _btn.y * ui_scale, ui_scale, ui_scale, 0, c_white, 1);
}

// =====================================================
// DRAW SHOP + JOURNAL IN FOCUS ORDER
// Whichever window is "focused" draws last, so it visually
// covers the other one wherever they overlap.
// =====================================================
var _draw_order = (focused_window == "shop") ? ["journal", "shop"] : ["shop", "journal"];

for (var o = 0; o < array_length(_draw_order); o++) {
    if (_draw_order[o] == "shop" && shop_open) draw_shop_panel();
    if (_draw_order[o] == "journal" && journal_open) draw_journal_panel();
}

// --- DEBUG: mouse position readout, remove before final build ---
//var _dmx = device_mouse_x_to_gui(0);
//var _dmy = device_mouse_y_to_gui(0);

//draw_set_color(c_yellow);
//draw_text(_dmx + 15, _dmy, string(floor(_dmx)) + ", " + string(floor(_dmy)));
//draw_text(_dmx + 15, _dmy + 20, "(÷ ui_scale = " + string(floor(_dmx / ui_scale)) + ", " + string(floor(_dmy / ui_scale)) + ")");