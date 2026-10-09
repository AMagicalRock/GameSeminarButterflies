if (current_area_index != -1) {
    var _set = bar_sprite_sets[current_area_index];
    var _percent = get_area_percent(current_area_index);

    var _inset_x = ui_bar_w * 0.15;
    var _inset_y = ui_bar_h * 0.06;
    var _fill_y_offset = 4;

    var _fill_x1 = ui_bar_x + _inset_x;
    var _fill_x2 = ui_bar_x + ui_bar_w - _inset_x;
    var _fill_h_max = ui_bar_h - (_inset_y * 2);
    var _fill_h = _fill_h_max * (_percent / 100);

    draw_sprite_stretched(_set.back, 0, ui_bar_x, ui_bar_y, ui_bar_w, ui_bar_h);
    draw_rectangle_color(_fill_x1, ui_bar_y + _inset_y + (_fill_h_max - _fill_h) + _fill_y_offset, _fill_x2, ui_bar_y + _inset_y + _fill_h_max + _fill_y_offset, _set.fill_color, _set.fill_color, _set.fill_color, _set.fill_color, false);
    draw_sprite_stretched(_set.front, 0, ui_bar_x, ui_bar_y, ui_bar_w, ui_bar_h);

	draw_set_font(font_cute);
	draw_set_halign(fa_center);
	draw_text_transformed(ui_bar_x + ui_bar_w / 2, ui_bar_y + ui_bar_h + 15, string(floor(_percent)) + "%", ui_scale * 1, ui_scale * 1, 0);
	draw_set_halign(fa_left); // reset back to default for anything drawn after this
	draw_set_font(-1);
}

if (current_area_index != -1) {
    var _a = areas[current_area_index];
    var _set = bar_sprite_sets[current_area_index];

    for (var i = 0; i < array_length(_a.milestones); i++) {
        var _m = _a.milestones[i];
        var _flower_index = (_m.percent / 25) - 1; // 25→0, 50→1, 75→2, 100→3

        var _sprite = _set.flowers[clamp(_flower_index, 0, 3)];
        var _sprite_to_draw = (_m.anim_state == "burst" || _m.anim_state == "done") ? _sprite : _set.bud;

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

var _key_ids = ["area2_key", "area3_key"];
var _slot = 0;
for (var i = 0; i < array_length(_key_ids); i++) {
    if (get_key_state(_key_ids[i]) == "collected") {
        var _p = variable_struct_exists(key_hud, _key_ids[i]) ? variable_struct_get(key_hud, _key_ids[i]) : 1;
        var _u = _p - 1;
        var _pop = 1 + 2.70158 * _u * _u * _u + 1.70158 * _u * _u;

        var _icon_scale = 0.6 * ui_scale * _pop;   // tune 0.6 to taste
		var _kx = money_icon_x - 30 * ui_scale - _slot * 50 * ui_scale;
		var _ky = money_icon_y + sprite_get_height(ui_money) * ui_scale / 2;

        draw_sprite_ext(variable_struct_get(key_sprites, _key_ids[i]), 0, _kx, _ky, _icon_scale, _icon_scale, 0, c_white, 1);
        _slot += 1;
    }
}

for (var i = 0; i < array_length(key_stars); i++) {
    var _st = key_stars[i];
    draw_star_shape(_st.x, _st.y, 22 * ui_scale, 10 * ui_scale, 5, _st.angle, make_color_rgb(255, 225, 90), 1);
    draw_star_shape(_st.x, _st.y, 11 * ui_scale, 5 * ui_scale, 5, -_st.angle, c_white, 1);
}

for (var i = 0; i < array_length(sparkles); i++) {
    var _sp = sparkles[i];
    var _f = _sp.life / _sp.max_life;
    var _sx = _sp.room_space ? room_to_gui_x(_sp.x) : _sp.x;
    var _sy = _sp.room_space ? room_to_gui_y(_sp.y) : _sp.y;
    draw_star_shape(_sx, _sy, _sp.size * _f * ui_scale, _sp.size * _f * ui_scale * 0.35, 4, _sp.angle, _sp.color, _f);
}