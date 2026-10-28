event_inherited();   // Y-sorting and fade from obj_ysort

trophy_sprites = [spr_statue_trophy_1, spr_statue_trophy_2, spr_statue_trophy_3];
slot_x = [slot1_x, slot2_x, slot3_x];
slot_y = [slot1_y, slot2_y, slot3_y];

placed = [false, false, false];   // landed and visible on the statue
bounce = [0, 0, 0];               // landing bounce timers
flights = [];                     // trophies currently flying in
details_started = false;
details_alpha = 0;

// Revisiting later: everything already placed just shows, with no animation
for (var i = 0; i < 3; i++) {
    if (obj_gameManager.get_key_state(obj_gameManager.trophy_ids[i]) == "placed") placed[i] = true;
}
if (placed[0] && placed[1] && placed[2]) {
    details_started = true;
    details_alpha = 1;
}

place_trophies = function() {
    var _n = 0;
    for (var i = 0; i < 3; i++) {
        var _id = obj_gameManager.trophy_ids[i];
        if (obj_gameManager.get_key_state(_id) == "collected") {
            obj_gameManager.set_key_state(_id, "placed");   // the HUD icon disappears as it leaves the player
            array_push(flights, { i: i, delay: _n * 14, t: 0, sx: obj_player.x, sy: obj_player.y - 20 });
            _n += 1;
        }
    }
};