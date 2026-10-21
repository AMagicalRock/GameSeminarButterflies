var _p = instance_place(x, y, obj_player);

if (_p != noone && _p.exit_armed && !global.player_locked) {
    // Keep the player's sideways position along the path, so they don't snap to the middle
    var _wide = (bbox_right - bbox_left) >= (bbox_bottom - bbox_top);
    var _ax = target_x;
    var _ay = target_y;
    if (_wide) _ax += _p.x - (bbox_left + bbox_right) / 2;    // horizontal strip: player crosses vertically
    else       _ay += _p.y - (bbox_top + bbox_bottom) / 2;    // vertical strip: player crosses horizontally

    global.spawn_x = _ax;
    global.spawn_y = _ay;
    global.carry = { dir_x: _p.dir_x, dir_y: _p.dir_y, sprite: _p.sprite_index, xscale: _p.image_xscale };
    room_goto(target_room);
}