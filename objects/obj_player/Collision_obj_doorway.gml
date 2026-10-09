if (other.is_passable()) {
    global.spawn_x = other.target_x;
    global.spawn_y = other.target_y;
    room_goto(other.target_room);
} else {
    other.on_player_touch();
}