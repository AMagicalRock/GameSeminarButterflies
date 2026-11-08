if (current_area_index == -1) exit;

if (paused) {
    var _pw = display_get_gui_width();
    var _ph = display_get_gui_height();
    draw_rectangle_color(0, 0, _pw, _ph, c_black, c_black, c_black, c_black, false);   // in case the snapshot has see-through pixels
    if (sprite_exists(pause_frame)) draw_sprite_stretched(pause_frame, 0, 0, 0, _pw, _ph);
}

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

// --- Collected keys and trophies, laid out end to end to the left of the coin icon ---
var _key_ids = ["area2_key", "area3_key", "tutorial_key", "trophy_1", "trophy_2", "trophy_3"];
var _gap = 16 * ui_scale;             // space between neighbouring icons
var _edge = _gap * 1.5;               // space between the coin icon and the first icon
var _cursor = money_icon_x - _edge;   // the right edge of the next icon to be placed
var _cy = money_icon_y + sprite_get_height(ui_money) * ui_scale / 2;   // level with the middle of the coin icon

for (var i = 0; i < array_length(_key_ids); i++) {
    var _id = _key_ids[i];
    if (get_key_state(_id) != "collected") continue;

    var _spr = variable_struct_get(key_sprites, _id);
    var _rest = variable_struct_get(key_hud_scale, _id) * ui_scale;   // the icon's settled size

    // The pop-in bounce when it's first collected
    var _p = variable_struct_exists(key_hud, _id) ? variable_struct_get(key_hud, _id) : 1;
    var _u = _p - 1;
    var _pop = 1 + 2.70158 * _u * _u * _u + 1.70158 * _u * _u;
    var _scale = _rest * _pop;

    var _w = sprite_get_width(_spr) * _rest;   // layout uses the settled width, so neighbours don't jiggle during a pop
    var _cx = _cursor - _w / 2;                // where the middle of this icon goes

    // Aim the picture's visual middle at (_cx, _cy), whatever the sprite's origin is
    var _dx = _cx - (sprite_get_width(_spr) / 2 - sprite_get_xoffset(_spr)) * _scale;
    var _dy = _cy - (sprite_get_height(_spr) / 2 - sprite_get_yoffset(_spr)) * _scale;
    draw_sprite_ext(_spr, 0, _dx, _dy, _scale, _scale, 0, c_white, 1);

    _cursor -= _w + _gap;   // the next icon's right edge sits one gap past this one's left edge
}

// Coins
for (var i = 0; i < array_length(money_particles); i++) {
    var _p = money_particles[i];
    if (_p.delay > 0) continue;
    var _cs = (coin_size * ui_scale) / sprite_get_width(_p.sprite);
    var _cf = floor(_p.frame) mod sprite_get_number(_p.sprite);
    draw_sprite_ext(_p.sprite, _cf, _p.x, _p.y, _cs, _cs, _p.angle, c_white, 1);
}

// The gold butterfly that carries a key or trophy (side view: mirrored, with a slight tilt)
for (var i = 0; i < array_length(key_stars); i++) {
    var _st = key_stars[i];
    var _grow = min(_st.age / 20, 1);
    var _bs = (key_butterfly_size * ui_scale * lerp(0.4, 1, _grow)) / sprite_get_width(particle_butterfly_gold);
    var _bf = floor(_st.frame) mod sprite_get_number(particle_butterfly_gold);

    var _going_left = lengthdir_x(1, _st.heading) < 0;
    var _tilt = lengthdir_y(1, _st.heading) * 20 * (_going_left ? 1 : -1);   // nose up when climbing, down when diving

    draw_sprite_ext(particle_butterfly_gold, _bf, _st.x, _st.y, _going_left ? _bs : -_bs, _bs, _tilt, c_white, 1);
}

// Sparkles
for (var i = 0; i < array_length(sparkles); i++) {
    var _sp = sparkles[i];
    var _f = _sp.life / _sp.max_life;
    var _sx = _sp.room_space ? room_to_gui_x(_sp.x) : _sp.x;
    var _sy = _sp.room_space ? room_to_gui_y(_sp.y) : _sp.y;
    var _ss = (_sp.size * 2 * _f * ui_scale * sparkle_size_mult) / sprite_get_width(_sp.sprite);
    draw_sprite_ext(_sp.sprite, 0, _sx, _sy, _ss, _ss, _sp.angle, c_white, _f);
}

// The pause menu draws here, above everything else
if (paused && instance_exists(obj_pause)) obj_pause.draw_menu();