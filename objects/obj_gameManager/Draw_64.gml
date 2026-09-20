if (current_area_index != -1) {
    var _percent = get_area_percent(current_area_index);
    var _fill_h = ui_bar_h * (_percent / 100);

    draw_rectangle_color(ui_bar_x, ui_bar_y, ui_bar_x + ui_bar_w, ui_bar_y + ui_bar_h, c_gray, c_gray, c_gray, c_gray, false);
    draw_rectangle_color(ui_bar_x, ui_bar_y + (ui_bar_h - _fill_h), ui_bar_x + ui_bar_w, ui_bar_y + ui_bar_h, c_lime, c_lime, c_lime, c_lime, false);

    draw_set_color(c_white);
    draw_text(ui_bar_x - 30, ui_bar_y - 20, areas[current_area_index].name);
    draw_text(ui_bar_x - 35, ui_bar_y + ui_bar_h + 10 - 40, string(floor(_percent)) + "%");
}
