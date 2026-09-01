depth = -1;

// If we were sent here by a doorway, move to that spot
if (variable_global_exists("spawn_x")) {
    x = global.spawn_x;
    y = global.spawn_y;
}