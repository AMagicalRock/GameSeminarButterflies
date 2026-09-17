if (puzzle_type != "flower") {
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
            var _angle = 12;
				switch (leaves[i].side) {
				    case "top":    _angle = 0;   break; // already matches default "pointing up"
				    case "left":   _angle = 90;  break; // rotate 90° counter-clockwise from up → left
				    case "bottom": _angle = 180; break; // rotate 180° from up → down
				    case "right":  _angle = 270; break; // rotate 270° (or -90°) from up → right
				}
			_angle += leaves[i].angle_jitter;

			draw_sprite_ext(spr_prune_leaf, 0, leaves[i].x, leaves[i].y, 0.4, 0.4, _angle, c_white, 1);
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