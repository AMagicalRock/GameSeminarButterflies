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
    for (var i = 0; i < array_length(leaf_spots); i++) {
        if (!leaf_spots[i].revealed) {
            draw_circle_color(leaf_spots[i].x, leaf_spots[i].y, 14, c_green, c_green, false);
        } else {
            var _live_pest_here = false;
            for (var j = 0; j < array_length(pests); j++) {
                if (!pests[j].caught && !pests[j].flying && pests[j].spot_index == i) {
                    _live_pest_here = true;
                    break;
                }
            }
            if (!_live_pest_here) {
                draw_circle_color(leaf_spots[i].x, leaf_spots[i].y, 10, c_gray, c_gray, false);
            }
        }
    }

    for (var i = 0; i < array_length(pests); i++) {
        var _p = pests[i];
        if (!_p.caught && (_p.flying || leaf_spots[_p.spot_index].revealed)) {
            draw_circle_color(_p.x, _p.y, 10, c_red, c_red, false);
        }
    }

    draw_set_color(c_white);
    draw_text(anchor_x - window_hw + 20, anchor_y - window_hh + 10, string(pests_found) + "/" + string(pest_count));
}

if (puzzle_type == "flower") {
    var _box = 50;
    for (var i = 0; i < 6; i++) {
        var _pos = flower_positions[i];
        var _bx = _pos.x - _box / 2;
        var _by = _pos.y - _box / 2;

        draw_rectangle_color(_bx, _by, _bx + _box, _by + _box, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);

        if (obj_gameManager.unlocked_flowers[i]) {
            draw_sprite_stretched(obj_gameManager.flower_sprites[i], 0, _bx + 5, _by + 5, _box - 10, _box - 10);
        } else {
            draw_sprite_stretched(obj_gameManager.lock_sprite, 0, _bx + 10, _by + 10, _box - 20, _box - 20);
        }

        if (source_task.planted_flower == i) {
            draw_rectangle_color(_bx, _by, _bx + _box, _by + _box, c_yellow, c_yellow, c_yellow, c_yellow, true);
        }
    }
}

if (active_cursor_sprite != -1) {
    draw_sprite_ext(active_cursor_sprite, 0, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 0.25, 0.25, 0, c_white, 1);

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
    draw_sprite_ext(ui_shop, 0, anchor_x, anchor_y, 1, 1, 0, c_white, 1);

    for (var i = 0; i < array_length(shop_display_items); i++) {
        var _item = shop_display_items[i];
        var _btn_x = anchor_x + _item.offset_x;
        var _btn_y = anchor_y + _item.offset_y;
        draw_sprite_ext(_item.sprite, 0, _btn_x, _btn_y, _item.scale, _item.scale, 0, c_white, _item.alpha);
    }
}

if (puzzle_type == "sign") {
    var _s = obj_gameManager.ui_scale;
    draw_sprite_ext(ui_sign, 0, anchor_x, anchor_y, _s, _s, 0, c_white, 1);

    var _content = obj_gameManager.butterfly_discovered[sign_butterfly_index] ? sign_discovered_sprite : sign_undiscovered_sprite;
    draw_sprite_ext(_content, 0, anchor_x, anchor_y, _s, _s, 0, c_white, 1);
}