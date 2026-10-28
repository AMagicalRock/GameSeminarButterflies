event_inherited();

var _gm = obj_gameManager;

// Trophies flying from the player into their slots
for (var f = array_length(flights) - 1; f >= 0; f--) {
    var _fl = flights[f];
    if (_fl.delay > 0) { _fl.delay -= 1; continue; }
    _fl.t += 1;
    if (_fl.t >= 26) {
        placed[_fl.i] = true;
        bounce[_fl.i] = 1;
        var _wx = x + slot_x[_fl.i] * image_xscale;
        var _wy = y + slot_y[_fl.i] * image_yscale;
        repeat (16) _gm.spawn_sparkle(_gm.room_to_gui_x(_wx), _gm.room_to_gui_y(_wy), 6 * _gm.ui_scale, 12);
        array_delete(flights, f, 1);
    }
}

// Landing bounce
for (var i = 0; i < 3; i++) {
    if (bounce[i] > 0) {
        bounce[i] += 1;
        if (bounce[i] > 20) bounce[i] = 0;
    }
}

// All three on: the details appear in a burst of sparkles
if (!details_started && array_length(flights) == 0 && placed[0] && placed[1] && placed[2]) {
    details_started = true;
    var _cx = x + (sprite_get_width(spr_statue_details) / 2 - sprite_get_xoffset(spr_statue_details)) * image_xscale;
    var _cy = y + (sprite_get_height(spr_statue_details) / 2 - sprite_get_yoffset(spr_statue_details)) * image_yscale;
    repeat (50) _gm.spawn_sparkle(_gm.room_to_gui_x(_cx), _gm.room_to_gui_y(_cy), 9 * _gm.ui_scale, 16);
}
if (details_started) details_alpha = min(details_alpha + 0.03, 1);