// Store where we should appear, since instance data won't survive the room switch
global.spawn_x = other.target_x;
global.spawn_y = other.target_y;

room_goto(other.target_room);