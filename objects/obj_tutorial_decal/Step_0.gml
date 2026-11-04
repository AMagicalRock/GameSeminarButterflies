if (state == "active") {
    // A keyed decal lights up, and stays lit, once its key has been pressed
    if (trigger_key != "" && !lit && !global.player_locked && key_is_down()) {
        lit = true;
        pop_timer = 1;
    }

    // The group is complete when every keyed decal in it is lit,
    // or when something else (the gate) has completed it
    var _keyed = 0;
    var _lit = 0;
    for (var i = 0; i < instance_number(obj_tutorial_decal); i++) {
        var _d = instance_find(obj_tutorial_decal, i);
        if (_d.group_id == group_id && _d.trigger_key != "") {
            _keyed += 1;
            if (_d.lit) _lit += 1;
        }
    }

    if ((_keyed > 0 && _lit == _keyed) || obj_gameManager.is_tutorial_group_done(group_id)) {
        obj_gameManager.complete_tutorial_group(group_id);   // remembered, so none of the group return
        lit = true;
        state = "holding";
        hold_timer = 40;   // a short beat, so the last key is seen turning green
    }
} else if (state == "holding") {
    hold_timer -= 1;
    if (hold_timer <= 0) state = "fading";
} else {
    fade_alpha -= 0.03;
    if (fade_alpha <= 0) instance_destroy();
}

if (pop_timer > 0) {
    pop_timer += 1;
    if (pop_timer > 12) pop_timer = 0;
}

sprite_index = (lit && sprite_exists(sprite_on)) ? sprite_on : sprite_off;