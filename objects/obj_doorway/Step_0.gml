// Wiggle when touched without a key
if (wiggle_timer > 0) {
    wiggle_timer += 1;
    lock_angle = sin(wiggle_timer * 1.1) * 14 * (1 - wiggle_timer / 28);
    if (wiggle_timer >= 28) {
        wiggle_timer = 0;
        lock_angle = 0;
    }
}

switch (lock_state) {
    case "key_flying":
        lock_timer += 1;
        key_fly_progress = min(lock_timer / 24, 1);
        if (lock_timer >= 24) {
            lock_state = "opening";
            lock_timer = 0;
            showing_open_sprite = true;   // swaps to the open lock the same moment it bounces
        }
        break;

    case "opening":
        lock_timer += 1;
        lock_bounce = 1 + sin(min(lock_timer / 20, 1) * pi) * 0.3;
        if (lock_timer >= 20) {
            lock_bounce = 1;
            lock_state = "falling";
            lock_timer = 0;
        }
        break;

    case "falling":
        lock_timer += 1;
        lock_fall_speed += 0.5;
        lock_fall_y += lock_fall_speed;
        lock_alpha = 1 - (lock_timer / 35);
        if (lock_timer >= 35) lock_state = "open";
        break;
}