depth = -1;
sprite_scale = 0.5; // 0.5 = half size, 1 = original size, 2 = double size, etc.
sprite_index = spr_player_front;
image_xscale = sprite_scale;
image_yscale = sprite_scale;

// If we were sent here by a doorway, move to that spot
if (variable_global_exists("spawn_x")) {
    x = global.spawn_x;
    y = global.spawn_y;
}