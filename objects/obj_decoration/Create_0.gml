// Sprite first, so bbox_bottom is correct when depth is calculated
if (sprite_default != -1) {
    sprite_index = sprite_default;
}

// Flat decorations, "always in front" ones and custom-sorted ones skip the parent's sorting and fading
always_on_ground = (flat_on_ground || always_in_front || sort_offset_y != 0);
event_inherited();

if (always_in_front) {
    depth = -100000;                              // the old behaviour, still available
} else if (sort_offset_y != 0) {
    depth = -(bbox_bottom + sort_offset_y);       // sort against everything else using this line
}