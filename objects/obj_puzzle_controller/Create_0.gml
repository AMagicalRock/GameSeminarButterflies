// puzzle_type and source_task are already correctly set by this point —
// either from the struct passed into instance_create_layer, or from their
// Variable Definitions defaults. Don't reassign them here.

var _cam = view_camera[0];
window_hw = 260; // half-width of the puzzle window (instance variable, used later too)
window_hh = 200; // half-height

anchor_x = clamp(source_task.x - camera_get_view_x(_cam), window_hw + 20, display_get_gui_width() - window_hw - 20);
anchor_y = clamp(source_task.y - camera_get_view_y(_cam), window_hh + 20, display_get_gui_height() - window_hh - 20);

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
	var _margin = 10; // keeps leaves from spawning too close to a corner

	for (var i = 0; i < array_length(tiles); i++) {
	    var _tile_x = grid_x + tiles[i].col * tile_size;
	    var _tile_y = grid_y + tiles[i].row * tile_size;
	    var _leaf_count = irandom_range(1, 3); // now up to 3, can land on the same side more than once

	    for (var k = 0; k < _leaf_count; k++) {
	        var _side = _sides[irandom(3)];
	        var _offset = irandom_range(_margin, tile_size - _margin); // random spot along that edge
	        var _lx, _ly;

	        switch (_side) {
	            case "top":    _lx = _tile_x + _offset;       _ly = _tile_y;                break;
	            case "bottom": _lx = _tile_x + _offset;       _ly = _tile_y + tile_size;     break;
	            case "left":   _lx = _tile_x;                 _ly = _tile_y + _offset;       break;
	            case "right":  _lx = _tile_x + tile_size;     _ly = _tile_y + _offset;       break;
	        }
	        array_push(leaves, { x: _lx, y: _ly, removed: false });
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
	// Harlo too!

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
    global.player_locked = false;
    instance_destroy(self);
};

if (puzzle_type == "flower") {
    flower_positions = [];
    var _radius = 90;
	var _start_angle = 0;

    for (var i = 0; i < 6; i++) {
        var _angle = degtorad(_start_angle + i * 60);
        array_push(flower_positions, {
            x: anchor_x + _radius * sin(_angle),
            y: anchor_y - _radius * cos(_angle)
        });
    }
}