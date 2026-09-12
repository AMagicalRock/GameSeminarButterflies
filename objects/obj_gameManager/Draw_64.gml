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

if (shop_open) {
    var _bg_x = 220 * ui_scale;
    var _bg_y = 60 * ui_scale;

    if (shop_background_sprite != -1) {
        draw_sprite_ext(shop_background_sprite, 0, _bg_x, _bg_y, ui_scale, ui_scale, 0, c_white, 1);
    } else {
        draw_rectangle_color(_bg_x, _bg_y, _bg_x + 700 * ui_scale, _bg_y + 400 * ui_scale, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
    }

    draw_set_color(c_white);
    draw_text(270 * ui_scale, 110 * ui_scale, "Catalog — Money: " + string(money));

    var _left_page = current_spread * 2;
    var _right_page = current_spread * 2 + 1;

	for (var i = 0; i < array_length(shop_items); i++) {
	    var _item = shop_items[i];
	    if (_item.page == _left_page || _item.page == _right_page) {
	        var _w = sprite_get_width(_item.sprite);
	        var _h = sprite_get_height(_item.sprite);
	        var _final_scale = ui_scale * _item.scale;
	        var _draw_x = _item.x * ui_scale - (_w * (_final_scale - ui_scale)) / 2;
	        var _draw_y = _item.y * ui_scale - (_h * (_final_scale - ui_scale)) / 2;

	        draw_sprite_ext(_item.sprite, 0, _draw_x, _draw_y, _final_scale, _final_scale, 0, c_white, 1);
	        draw_text(_item.x * ui_scale, (_item.y + _h) * ui_scale + 5, _item.name + " — " + string(_item.cost) + "g");
	    }
    }

    if (current_spread > 0) draw_text(265 * ui_scale, 300 * ui_scale, "<");
    if (current_spread < max_spread) draw_text(910 * ui_scale, 300 * ui_scale, ">");
}
