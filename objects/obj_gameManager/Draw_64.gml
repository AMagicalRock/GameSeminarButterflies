if (current_area_index != -1) {
    var _percent = get_area_percent(current_area_index);

    var _inset_x = ui_bar_w * 0.15;
    var _inset_y = ui_bar_h * 0.06;
    var _fill_y_offset = 4;

    var _fill_x1 = ui_bar_x + _inset_x;
    var _fill_x2 = ui_bar_x + ui_bar_w - _inset_x;
    var _fill_h_max = ui_bar_h - (_inset_y * 2);
    var _fill_h = _fill_h_max * (_percent / 100);

    draw_sprite_stretched(ui_pbBack, 0, ui_bar_x, ui_bar_y, ui_bar_w, ui_bar_h);
    draw_rectangle_color(_fill_x1, ui_bar_y + _inset_y + (_fill_h_max - _fill_h) + _fill_y_offset, _fill_x2, ui_bar_y + _inset_y + _fill_h_max + _fill_y_offset, c_lime, c_lime, c_lime, c_lime, false);
    draw_sprite_stretched(ui_pbFront, 0, ui_bar_x, ui_bar_y, ui_bar_w, ui_bar_h);

	draw_set_font(font_cute);
	draw_set_halign(fa_center);
	draw_text_transformed(ui_bar_x + ui_bar_w / 2, ui_bar_y + ui_bar_h + 15, string(floor(_percent)) + "%", ui_scale * 1, ui_scale * 1, 0);
	draw_set_halign(fa_left); // reset back to default for anything drawn after this
	draw_set_font(-1);
}

if (current_area_index != -1) {
    var _a = areas[current_area_index];

    for (var i = 0; i < array_length(_a.milestones); i++) {
        var _m = _a.milestones[i];

        var _sprite;
        if (_m.percent == 25) _sprite = ui_pbFlower_1;
        else if (_m.percent == 50) _sprite = ui_pbFlower_2;
        else if (_m.percent == 75) _sprite = ui_pbFlower_3;
        else if (_m.percent == 100) _sprite = ui_pbFlower_4;
        else _sprite = ui_pbFlower_1;

        var _sprite_to_draw = (_m.anim_state == "burst" || _m.anim_state == "done") ? _sprite : ui_pbBud;
        var _draw_x = _m.marker_x + _m.shake_x;
        var _scale = ui_scale * _m.visual_scale;

        draw_sprite_ext(_sprite_to_draw, 0, _draw_x, _m.marker_y, _scale, _scale, 0, c_white, 1);
    }
}

for (var i = 0; i < array_length(money_particles); i++) {
    var _p = money_particles[i];
    if (_p.delay > 0) continue;
    draw_circle_color(_p.x, _p.y, 8 * ui_scale, c_yellow, c_yellow, false);
}

money_padding = 20 * ui_scale;
money_icon_x = display_get_gui_width() - (sprite_get_width(ui_money) * ui_scale) - money_padding - 100;
money_icon_y = 30 * ui_scale;
var _text_y_offset = 7 * ui_scale;

money_text_x = money_icon_x + sprite_get_width(ui_money) * ui_scale + 10;
money_text_y = money_icon_y + _text_y_offset;

draw_sprite_ext(ui_money, 0, money_icon_x, money_icon_y + money_counter_bounce, ui_scale, ui_scale, 0, c_white, 1);
draw_set_font(font_cute);
draw_text_transformed(money_text_x, money_text_y + money_counter_bounce, string(money), ui_scale * 1.5, ui_scale * 1.5, 0);
draw_set_font(-1);

draw_set_font(font_cute);
for (var i = 0; i < array_length(money_popups); i++) {
    var _pu = money_popups[i];
    draw_set_alpha(_pu.alpha);
    draw_set_color(c_white);
    draw_text_transformed(_pu.x, _pu.y, "+" + string(floor(_pu.display)), ui_scale * 1.5, ui_scale * 1.5, 0);
}
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(-1);