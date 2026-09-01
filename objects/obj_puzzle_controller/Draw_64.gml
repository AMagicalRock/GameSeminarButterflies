if (puzzle_type != "flower") {
    draw_rectangle_color(anchor_x - window_hw, anchor_y - window_hh, anchor_x + window_hw, anchor_y + window_hh, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
}

if (puzzle_type == "prune") {
    draw_set_color(c_olive);
    for (var i = 0; i < array_length(tiles); i++) {
        var _tx = grid_x + tiles[i].col * tile_size;
        var _ty = grid_y + tiles[i].row * tile_size;
        draw_rectangle(_tx + 4, _ty + 4, _tx + tile_size - 4, _ty + tile_size - 4, false);
    }

    for (var i = 0; i < array_length(leaves); i++) {
        if (!leaves[i].removed) {
            draw_circle_color(leaves[i].x, leaves[i].y, 8, c_lime, c_lime, false);
        }
    }
}

if (puzzle_type == "pest") {
    draw_circle_color(caterpillar_x, caterpillar_y, 14, c_lime, c_lime, false);

    for (var i = 0; i < array_length(predators); i++) {
        draw_circle_color(predators[i].x, predators[i].y, 10, c_red, c_red, false);
    }

    draw_set_color(c_white);
    draw_text(anchor_x - window_hw + 20, anchor_y - window_hh + 10, string(survive_time div 60) + "s survived");
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