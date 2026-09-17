always_on_ground = flat_on_ground || always_in_front;
event_inherited();

if (sprite_default != -1) {
    sprite_index = sprite_default;
}

if (always_in_front) {
    depth = -100000; // same fixed "always wins" constant as your butterflies
}