lock_state = (required_key == "") ? "open" : "locked";   // locked → key_flying → opening → falling → open
lock_timer = 0;
wiggle_timer = 0;
lock_angle = 0;
lock_bounce = 1;
lock_fall_y = 0;
lock_fall_speed = 0;
lock_alpha = 1;
key_fly_progress = 0;
key_start_x = 0;
key_start_y = 0;
showing_open_sprite = false;

// If this door was already unlocked on an earlier visit, it never shows a lock again
if (required_key != "" && instance_exists(obj_gameManager) && variable_instance_exists(obj_gameManager, "get_key_state")) {
    if (obj_gameManager.get_key_state(required_key) == "used") lock_state = "open";
}

is_passable = function() {
    return lock_state == "open";
};

on_player_touch = function() {
    if (lock_state != "locked") exit;

    if (obj_gameManager.has_key(required_key)) {
        // The key counts as used right away, so its HUD icon disappears as it launches
        obj_gameManager.set_key_state(required_key, "used");
        lock_state = "key_flying";
        lock_timer = 0;
        key_start_x = obj_player.x;
        key_start_y = obj_player.y;
    } else if (wiggle_timer == 0) {
        wiggle_timer = 1;
    }
};