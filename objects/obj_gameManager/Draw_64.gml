if (current_area_index != -1) {
    var _percent = get_area_percent(current_area_index);

    var _inset_x = ui_bar_w * 0.15;
    var _inset_y = ui_bar_h * 0.06;
    var _fill_y_offset = 4; // nudge down — increase/decrease to taste

    var _fill_x1 = ui_bar_x + _inset_x;
    var _fill_x2 = ui_bar_x + ui_bar_w - _inset_x;
    var _fill_h_max = ui_bar_h - (_inset_y * 2);
    var _fill_h = _fill_h_max * (_percent / 100);

    draw_sprite_stretched(ui_pbBack, 0, ui_bar_x, ui_bar_y, ui_bar_w, ui_bar_h);
    draw_rectangle_color(_fill_x1, ui_bar_y + _inset_y + (_fill_h_max - _fill_h) + _fill_y_offset, _fill_x2, ui_bar_y + _inset_y + _fill_h_max + _fill_y_offset, c_lime, c_lime, c_lime, c_lime, false);
    draw_sprite_stretched(ui_pbFront, 0, ui_bar_x, ui_bar_y, ui_bar_w, ui_bar_h);

    draw_set_color(c_white);
    draw_text(ui_bar_x - 30, ui_bar_y - 20, areas[current_area_index].name);
    draw_text(ui_bar_x - 35, ui_bar_y + ui_bar_h + 10 - 40, string(floor(_percent)) + "%");
}