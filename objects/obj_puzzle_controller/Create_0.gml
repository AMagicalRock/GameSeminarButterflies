var _cam = view_camera[0];
window_hw = 260;
window_hh = 200;

var _raw_x = (source_task.x - camera_get_view_x(_cam)) * obj_gameManager.ui_scale;
var _raw_y = (source_task.y - camera_get_view_y(_cam)) * obj_gameManager.ui_scale;

build_item_surface = function(_sprite) {
    var _w = sprite_get_width(_sprite);
    var _h = sprite_get_height(_sprite);
    var _surf = surface_create(_w, _h);
    surface_set_target(_surf);
    draw_clear_alpha(0, 0);
    draw_sprite(_sprite, 0, _w / 2, _h / 2);
    surface_reset_target();
    return _surf;
};

is_point_on_sprite_pixel = function(_mx, _my, _item, _cx, _cy) {
    var _w = sprite_get_width(_item.sprite);
    var _h = sprite_get_height(_item.sprite);
    var _hw = _w * _item.scale / 2;
    var _hh = _h * _item.scale / 2;

    // Cheap rectangle rejection first — most misses never touch the surface at all
    if (_mx < _cx - _hw || _mx > _cx + _hw || _my < _cy - _hh || _my > _cy + _hh) return false;

    if (!surface_exists(_item.pixel_surface)) {
        _item.pixel_surface = build_item_surface(_item.sprite); // rebuild if the OS wiped it
    }

    var _local_x = (_mx - (_cx - _hw)) / _item.scale;
    var _local_y = (_my - (_cy - _hh)) / _item.scale;
    var _col = surface_getpixel_ext(_item.pixel_surface, _local_x, _local_y);
    var _alpha = (_col >> 24) & 0xFF;

    return _alpha > 10; // treat near-fully-transparent pixels as a miss
};

if (puzzle_type == "shop") {
    window_hw = sprite_get_width(ui_shop) / 2;
    window_hh = sprite_get_height(ui_shop) / 2;

    shop_display_items = [];
    for (var i = 0; i < array_length(obj_gameManager.shop_items); i++) {
        var _src = obj_gameManager.shop_items[i];
        if (_src.area != obj_gameManager.current_area_index) continue;

        var _already_owned = false;
        if (_src.type == "seed") _already_owned = obj_gameManager.unlocked_flowers[_src.flower_index];
        else if (_src.type == "tool") _already_owned = variable_struct_exists(obj_gameManager.purchased, _src.tool_id);
        if (_already_owned) continue;

        array_push(shop_display_items, {
            source: _src,
            sprite: _src.sprite,
            offset_x: _src.offset_x,
            offset_y: _src.offset_y,
            scale: 1,
            alpha: 1,
            removing: false,
            pixel_surface: build_item_surface(_src.sprite) // <-- moved here, runs per-item
        });
    }
}

anchor_x = clamp(_raw_x, window_hw + 20, display_get_gui_width() - window_hw - 20);
anchor_y = clamp(_raw_y, window_hh + 20, display_get_gui_height() - window_hh - 20);

depth = -500;

active_cursor_sprite = -1;

has_upgraded_shears = false;
cut_radius = 14;

if (puzzle_type == "prune") {
	grid_cols = 3;
	grid_rows = 3;
	tile_size = min(window_hw * 2 * 0.7, window_hh * 2 * 0.7) / max(grid_cols, grid_rows);
    grid_w = grid_cols * tile_size;
    grid_h = grid_rows * tile_size;
    grid_x = anchor_x - grid_w / 2;
    grid_y = anchor_y - grid_h / 2;

 // Every possible position in the grid, whatever size it is
    var _all_positions = [];
    for (var row = 0; row < grid_rows; row++) {
        for (var col = 0; col < grid_cols; col++) {
            array_push(_all_positions, { row: row, col: col });
        }
    }

    // Shuffle, then keep only however many tiles this puzzle actually needs
	// Manual shuffle (Fisher-Yates) — guaranteed to work on any GameMaker version
	for (var i = array_length(_all_positions) - 1; i > 0; i--) {
	    var _j = irandom(i);
	    var _temp = _all_positions[i];
	    _all_positions[i] = _all_positions[_j];
	    _all_positions[_j] = _temp;
	}
    var _count = min(active_tile_count, array_length(_all_positions));

    tiles = [];
    for (var i = 0; i < _count; i++) {
        array_push(tiles, _all_positions[i]);
    }

   leaves = [];
	var _sides = ["top", "right", "bottom", "left"];
	var _margin = 20; // keeps leaves from spawning too close to a corner

	for (var i = 0; i < array_length(tiles); i++) {
	    var _tile_x = grid_x + tiles[i].col * tile_size;
	    var _tile_y = grid_y + tiles[i].row * tile_size;
	    var _leaf_count = irandom_range(1, 3); // now up to 3, can land on the same side more than once

			for (var k = 0; k < _leaf_count; k++) {
			    var _side = _sides[irandom(3)];
			    var _offset = irandom_range(_margin, tile_size - _margin);
			    var _lx, _ly;
				var _valid = false;
				var _tries = 0;
				
			    while (!_valid && _tries < 30) {
			        _tries += 1;
			        _side = _sides[irandom(3)];
			        _offset = irandom_range(_margin, tile_size - _margin);

			    switch (_side) {
			        case "top":    _lx = _tile_x + _offset;       _ly = _tile_y;                break;
			        case "bottom": _lx = _tile_x + _offset;       _ly = _tile_y + tile_size;     break;
			        case "left":   _lx = _tile_x;                 _ly = _tile_y + _offset;       break;
			        case "right":  _lx = _tile_x + tile_size;      _ly = _tile_y + _offset;       break;
			    }
				
				    _valid = true;
			        for (var j = 0; j < array_length(leaves); j++) {
			            if (point_distance(_lx, _ly, leaves[j].x, leaves[j].y) < 15) {
			                _valid = false;
			                break;
						}
					}
				}
				
				var _push = 0; // how far outward to nudge, in pixels — tune to taste
				switch (_side) {
				    case "top":    _ly -= _push; break;
				    case "bottom": _ly += _push; break;
				    case "left":   _lx -= _push; break;
				    case "right":  _lx += _push; break;
				}
				
			    array_push(leaves, { x: _lx, y: _ly, removed: false, side: _side, angle_jitter: irandom_range(-35, 35), falling: false, fall_offset: 0, fall_alpha: 1 });
			}
		
	}
}

if (puzzle_type == "pest") {
    pest_count = active_tile_count;
    var _decoy_count = 6;
    var _total_leaves = pest_count + _decoy_count;

    leaf_spots = [];
    var _margin = 40;
    var _min_spacing = 45;
    var _attempts = 0;

    while (array_length(leaf_spots) < _total_leaves && _attempts < 300) {
        _attempts += 1;
        var _lx = irandom_range(anchor_x - window_hw + _margin, anchor_x + window_hw - _margin);
        var _ly = irandom_range(anchor_y - window_hh + _margin, anchor_y + window_hh - _margin);

        var _too_close = false;
        for (var i = 0; i < array_length(leaf_spots); i++) {
            if (point_distance(_lx, _ly, leaf_spots[i].x, leaf_spots[i].y) < _min_spacing) {
                _too_close = true;
                break;
            }
        }
        if (!_too_close) array_push(leaf_spots, { x: _lx, y: _ly, revealed: false });
    }

    var _indices = [];
    for (var i = 0; i < array_length(leaf_spots); i++) array_push(_indices, i);
    for (var i = array_length(_indices) - 1; i > 0; i--) {
        var _j = irandom(i);
        var _temp = _indices[i]; _indices[i] = _indices[_j]; _indices[_j] = _temp;
    }

    // Pests are now their own list, each with a spot_index they currently occupy
    pests = [];
    for (var i = 0; i < min(pest_count, array_length(_indices)); i++) {
        var _s = _indices[i];
        array_push(pests, {
            spot_index: _s,
            x: leaf_spots[_s].x,
            y: leaf_spots[_s].y,
            flying: false,
            target_index: -1,
            fly_progress: 0,
            fly_speed: 0.035,
            caught: false
        });
    }

    pests_found = 0;
    pest_dash_chance = 350; // out of 1000 — rolled ONCE, the moment a pest is spotted

    is_spot_claimed = function(_index) {
        for (var i = 0; i < array_length(pests); i++) {
            if (pests[i].flying && pests[i].target_index == _index) return true;
        }
        return false;
    };
}

close_puzzle = function(_result) {
    if (_result == "success" && instance_exists(source_task)) {
        obj_gameManager.complete_task(source_task);
    }

    if (puzzle_type == "shop") {
        for (var i = 0; i < array_length(shop_display_items); i++) {
            if (surface_exists(shop_display_items[i].pixel_surface)) {
                surface_free(shop_display_items[i].pixel_surface);
            }
        }
    }

    window_set_cursor(cr_default);
    global.player_locked = false;
    instance_destroy(self);
};

if (puzzle_type == "flower") {
    var _s = obj_gameManager.ui_scale;
    window_hw = sprite_get_width(ui_flower_window) * _s / 2;
    window_hh = sprite_get_height(ui_flower_window) * _s / 2;

    flower_positions = [];
    var _radius = 120 * _s;
    var _start_angle = 0;

    for (var i = 0; i < 6; i++) {
        var _angle = degtorad(_start_angle + i * 60);
        array_push(flower_positions, {
            x: anchor_x + _radius * sin(_angle),
            y: anchor_y - _radius * cos(_angle)
        });
    }

    obj_gameManager.rebuild_flower_positions();
}
if (puzzle_type == "sign") {
    var _s = obj_gameManager.ui_scale;
    window_hw = sprite_get_width(ui_sign) * _s / 2;
    window_hh = sprite_get_height(ui_sign) * _s / 2;

    sign_butterfly_index = source_task.butterfly_index;
    sign_undiscovered_sprite = source_task.sign_undiscovered;
    sign_discovered_sprite = source_task.sign_discovered;
}