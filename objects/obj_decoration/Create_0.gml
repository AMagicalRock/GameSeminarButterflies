if (sprite_default != -1) {
    sprite_index = sprite_default;
}

always_on_ground = (flat_on_ground || always_in_front || sort_offset_y != 0);
event_inherited();

// The art's footprint, measured from the sprite itself
var _x1 = x - sprite_get_xoffset(sprite_index) * image_xscale;
var _x2 = _x1 + sprite_get_width(sprite_index) * image_xscale;
var _y1 = y - sprite_get_yoffset(sprite_index) * image_yscale;
var _y2 = _y1 + sprite_get_height(sprite_index) * image_yscale;
art_l = min(_x1, _x2);
art_r = max(_x1, _x2);
art_t = min(_y1, _y2);
art_b = max(_y1, _y2);

// The line this piece sorts against: the player draws in front below it and behind above it
sort_line_y = bbox_bottom + sort_offset_y;

if (always_in_front) {
    depth = -100000;
} else if (sort_offset_y != 0) {
    depth = -sort_line_y;
}

// --- Falling leaves ---
fall_leaves = [];
leaf_sprite = -1;

var _leaf_list = [particle_leaf_1, particle_leaf_2, particle_leaf_3];
var _lt = variable_instance_exists(id, "leaf_type") ? leaf_type : 0;

// Trees pick their leaf from their own sprite. leaf_type is only needed to override this.
if (_lt == 0) {
    switch (sprite_index) {
        case spr_tree_seaAlmond:  _lt = 1; break;
        case spr_tree_pinkMempat: _lt = 2; break;
        case spr_tree_tembusu:    _lt = 3; break;
    }
}
if (_lt > 0) leaf_sprite = _leaf_list[clamp(_lt, 1, 3) - 1];

// Dials
leaf_gap_min = 240;            // frames between drops, per tree (60 frames = 1 second)
leaf_gap_max = 420;
leaf_fall_speed_min = 0.25;   // pixels per frame
leaf_fall_speed_max = 0.55;
leaf_sway = 0.35;             // sideways drift
leaf_size = 28;               // leaf width in pixels

leaf_timer = irandom_range(0, leaf_gap_max);   // each tree's first drop lands anywhere in a full gap