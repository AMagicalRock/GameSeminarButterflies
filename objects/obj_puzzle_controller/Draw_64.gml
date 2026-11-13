if (puzzle_type != "flower" && puzzle_type != "shop") {
    draw_sprite_stretched(spr_task_window, 0, anchor_x - window_hw, anchor_y - window_hh, window_hw * 2, window_hh * 2);
}

if (puzzle_type == "prune") {
    for (var i = 0; i < array_length(tiles); i++) {
        var _tx = grid_x + tiles[i].col * tile_size;
        var _ty = grid_y + tiles[i].row * tile_size;
        draw_sprite_stretched(spr_prune_bush, 0, _tx + 4, _ty + 4, tile_size - 8, tile_size - 8);
    }

	for (var i = 0; i < array_length(leaves); i++) {
	    if (!leaves[i].removed) {
	        var _angle = 0;
	        switch (leaves[i].side) {
	            case "top":    _angle = 0;   break;
	            case "left":   _angle = 90;  break;
	            case "bottom": _angle = 180; break;
	            case "right":  _angle = 270; break;
	        }
	        _angle += leaves[i].angle_jitter;

	        draw_sprite_ext(spr_prune_leaf, 0, leaves[i].x, leaves[i].y + leaves[i].fall_offset, 0.4, 0.4, _angle, c_white, leaves[i].fall_alpha);
	    }
	}
}

if (puzzle_type == "pest") {
    // Pests sit under every leaf
    for (var i = 0; i < array_length(pests); i++) {
        var _p = pests[i];
        if (!_p.caught || _p.pop_timer < 10) draw_pest(_p);
    }

    // Leaves that have been moved aside lie underneath...
    for (var i = 0; i < array_length(leaf_spots); i++) {
        var _s = leaf_spots[i];
        if (_s.revealed) {
            draw_sprite_ext(spr_leaf_g_1, 0, _s.x + _s.offset_x, _s.y + _s.offset_y, leaf_scale, leaf_scale, _s.angle, c_white, 1);
        }
    }

    // ...and leaves covering a spot are drawn on top of them
    for (var i = 0; i < array_length(leaf_spots); i++) {
        var _s = leaf_spots[i];
        if (!_s.revealed) {
            draw_sprite_ext(spr_leaf_g_1, 0, _s.x + _s.offset_x, _s.y + _s.offset_y, leaf_scale, leaf_scale, _s.angle, c_white, 1);
        }
    }

    draw_set_font(font_cute);
    draw_set_color(c_white);
    draw_text_transformed(
        anchor_x - window_hw + 60 * obj_gameManager.ui_scale,
        anchor_y - window_hh + 50 * obj_gameManager.ui_scale,
        string(pests_found) + "/" + string(pest_count),
        obj_gameManager.ui_scale * 1.5,
        obj_gameManager.ui_scale * 1.5,
        0
    );
    draw_set_font(-1);
}

if (puzzle_type == "flower") {
    var _s = obj_gameManager.ui_scale;
    draw_sprite_ext(ui_flower_window, 0, anchor_x, anchor_y, _s, _s, 0, c_white, 1);

    var _icon_scale = _s * 0.6;

    for (var i = 0; i < 6; i++) {
        var _f = obj_gameManager.flower_slot_order[i];   // the real flower shown in slot i
        var _pos = flower_positions[i];

        if (obj_gameManager.unlocked_flowers[_f]) {
            draw_sprite_ext(obj_gameManager.ui_flower_sprites[_f], 0, _pos.x, _pos.y, _icon_scale, _icon_scale, 0, c_white, 1);
        } else {
            draw_sprite_ext(obj_gameManager.lock_sprite, 0, _pos.x, _pos.y, _s, _s, 0, c_white, 1);
        }

        if (source_task.planted_flower == _f) {
            draw_set_color(c_yellow);
            draw_circle_color(_pos.x, _pos.y, (40 * _s) / 2, c_yellow, c_yellow, true);
        }
    }
}

// --- "Press E to leave" reminder ---
if (leave_prompt && prompt_age > 20) {
    var _a = clamp((prompt_age - 20) / 25, 0, 1);
    var _pulse = 0.8 + sin(current_time * 0.004) * 0.2;
    draw_pill("Press E to leave", false, _a * 0.85, _a * _pulse);
}

// --- First-time mouse hint, just below the window ---
if (hint_alpha > 0) {
    var _s = obj_gameManager.ui_scale;
    var _mw = sprite_get_width(decal_mouse) * _s;
    var _lw = sprite_get_width(decal_to_select) * _s;
    var _gap = 14 * _s;
    var _total = _mw + _gap + _lw;
    var _half_h = max(sprite_get_height(decal_mouse), sprite_get_height(decal_to_select)) * _s / 2;

    var _cx = anchor_x + hint_offset_x * _s;
    var _cy = anchor_y - window_hh - hint_offset_y * _s;
    // If there's no room above the window, put the hint below it instead
    if (_cy - _half_h < 0) _cy = anchor_y + window_hh + hint_offset_y * _s;
    _cy = clamp(_cy, _half_h, display_get_gui_height() - _half_h);

    var _left = _cx - _total / 2;
    var _pulse = 1 + sin(current_time * 0.006) * 0.05;                              // a gentle breathing pulse
    var _frame = floor(current_time / 400) mod sprite_get_number(decal_mouse);   // plays the mouse's frames if it has several

    draw_sprite_ext(decal_mouse, _frame, _left + _mw / 2, _cy, _s * _pulse, _s * _pulse, 0, c_white, hint_alpha);
    draw_sprite_ext(decal_to_select, 0, _left + _mw + _gap + _lw / 2, _cy, _s, _s, 0, c_white, hint_alpha);
}

if (active_cursor_sprite != -1) {
    draw_sprite_ext(active_cursor_sprite, 0, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 0.5, 0.5, 0, c_white, 1);

	if (puzzle_type == "prune" && has_upgraded_shears) {
	    draw_set_alpha(0.5);
	    var _thickness = 3;
	    for (var t = 0; t < _thickness; t++) {
	        draw_circle_color(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), cut_radius - t, c_green, c_green, true);
	    }
	    draw_set_alpha(1);
	}
}

if (puzzle_type == "shop") {
    var _s = obj_gameManager.ui_scale;
    draw_sprite_ext(ui_shop, 0, anchor_x, anchor_y, _s * 0.9, _s * 0.9, 0, c_white, 1);

    for (var i = 0; i < array_length(shop_display_items); i++) {
        var _item = shop_display_items[i];
        var _btn_x = anchor_x + _item.offset_x * _s;
        var _btn_y = anchor_y + _item.offset_y * _s;
        draw_sprite_ext(_item.sprite, 0, _btn_x, _btn_y, _item.scale * _s, _item.scale * _s, 0, c_white, 1);
    }
}

// --- Shop hover box (placeholder look) ---
if (puzzle_type == "shop" && tip_item != noone && tip_alpha > 0.02) {
    var _s = obj_gameManager.ui_scale;
    var _name = tip_item.source.name;
    var _desc = obj_gameManager.get_item_description(tip_item.source);

    draw_set_font(font_cute);
    var _pad = 16 * _s;
    var _w = 340 * _s;
    var _inner = _w - _pad * 2;
    var _name_scale = _s * 1.1;
    var _desc_scale = _s * 0.8;

    // Measure first, so the box fits whatever text it holds
    var _name_h = string_height_ext(_name, -1, _inner / _name_scale) * _name_scale;
    var _desc_h = string_height_ext(_desc, -1, _inner / _desc_scale) * _desc_scale;
    var _h = _pad * 2 + _name_h + 8 * _s + _desc_h;

    // Sits beside the cursor, flipping or sliding to stay on screen
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _cx = device_mouse_x_to_gui(0);
    var _cy = device_mouse_y_to_gui(0);
    var _tx = _cx + 28 * _s;
    var _ty = _cy + 28 * _s;
    if (_tx + _w > _gw - 8 * _s) _tx = _cx - 16 * _s - _w;
    _ty = clamp(_ty, 8 * _s, max(8 * _s, _gh - _h - 8 * _s));

    draw_set_alpha(tip_alpha);
    var _bc = make_color_rgb(30, 46, 36);
    draw_roundrect_color_ext(_tx, _ty, _tx + _w, _ty + _h, 14 * _s, 14 * _s, _bc, _bc, false);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text_ext_transformed(_tx + _pad, _ty + _pad, _name, -1, _inner / _name_scale, _name_scale, _name_scale, 0);
    draw_set_color(make_color_rgb(200, 212, 204));
    draw_text_ext_transformed(_tx + _pad, _ty + _pad + _name_h + 8 * _s, _desc, -1, _inner / _desc_scale, _desc_scale, _desc_scale, 0);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_font(-1);
}

if (puzzle_type == "sign") {
    var _s = obj_gameManager.ui_scale;
    var _discovered = obj_gameManager.butterfly_discovered[sign_butterfly_index];
    var _content = _discovered ? sign_discovered_sprite : sign_undiscovered_sprite;

    if (source_task.sign_use_frame) {
        draw_sprite_ext(ui_sign, 0, anchor_x, anchor_y, _s, _s, 0, c_white, 1);
    }
    draw_sprite_ext(_content, 0, anchor_x, anchor_y, _s, _s, 0, c_white, 1);
}

if (puzzle_type == "thanks") {
    var _s = obj_gameManager.ui_scale;
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    // Dim everything behind it
    draw_set_alpha(0.6 * thanks_alpha);
    draw_rectangle_color(0, 0, _gw, _gh, c_black, c_black, c_black, c_black, false);

    // The panel grows in slightly as it fades up
    draw_set_alpha(thanks_alpha);
    var _grow = lerp(0.92, 1, thanks_alpha);
    var _pw = 760 * _s * _grow;
    var _ph = 400 * _s * _grow;
    var _pc = make_color_rgb(40, 62, 48);
    draw_roundrect_color_ext(anchor_x - _pw / 2, anchor_y - _ph / 2, anchor_x + _pw / 2, anchor_y + _ph / 2, 28 * _s, 28 * _s, _pc, _pc, false);

    draw_set_font(font_cute);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // The width limit is measured before scaling, so it's divided by each text's scale
    draw_set_color(c_white);
    var _title_s = _s * 2.2;
    draw_text_ext_transformed(anchor_x, anchor_y - 95 * _s, "Thank you for playing!", -1, (760 * _s * 0.85) / _title_s, _title_s, _title_s, 0);

    draw_set_color(make_color_rgb(200, 212, 204));
    var _body_s = _s * 1.1;
    draw_text_ext_transformed(anchor_x, anchor_y + 10 * _s, "You can keep playing if you've have not unlocked all the butterflies yet.", -1, (760 * _s * 0.82) / _body_s, _body_s, _body_s, 0);

    // The prompt fades in when E starts working, then pulses gently
    var _pulse = 0.65 + sin(current_time * 0.004) * 0.35;
    var _prompt = thanks_alpha * clamp((thanks_age - 45) / 20, 0, 1) * _pulse;
    draw_set_alpha(_prompt);
    draw_set_color(c_white);
    draw_text_transformed(anchor_x, anchor_y + _ph / 2 - 55 * _s, "Press E to close", _s, _s, 0);

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}