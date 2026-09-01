if (current_area_index != -1) {
    var _percent = get_area_percent(current_area_index);
    var _bar_h = 300;
    var _bar_w = 20;
    var _bar_x = display_get_gui_width() - 40;
    var _bar_y = (display_get_gui_height() - _bar_h) / 2;
    var _fill_h = _bar_h * (_percent / 100);

    draw_rectangle_color(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, c_gray, c_gray, c_gray, c_gray, false);
    draw_rectangle_color(_bar_x, _bar_y + (_bar_h - _fill_h), _bar_x + _bar_w, _bar_y + _bar_h, c_lime, c_lime, c_lime, c_lime, false);

    draw_set_color(c_white);
    draw_text(_bar_x - 30, _bar_y - 20, areas[current_area_index].name);
    draw_text(_bar_x - 35, _bar_y + _bar_h + 10, string(floor(_percent)) + "%"); // <-- new line
}