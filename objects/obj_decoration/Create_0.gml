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