if (required_key == "" || lock_state == "open") exit;

var _spr = showing_open_sprite ? lock_sprite_open : lock_sprite_closed;
if (!sprite_exists(_spr)) _spr = lock_sprite_closed;
if (!sprite_exists(_spr)) {
    show_debug_message("Door in " + room_get_name(room) + " at (" + string(x) + ", " + string(y) + ") has required_key but no lock sprite assigned");
    exit;
}

var _sc = lock_scale * lock_bounce;
draw_sprite_ext(_spr, 0, x + lock_offset_x, y + lock_offset_y + lock_fall_y, _sc, _sc, lock_angle, c_white, lock_alpha);

// The key flying from the player into the lock
if (lock_state == "key_flying") {
    var _key_spr = variable_struct_get(obj_gameManager.key_sprites, required_key);
    var _p = key_fly_progress;
    var _e = _p * _p * (3 - 2 * _p);
    var _kx = lerp(key_start_x, x + lock_offset_x, _e);
    var _ky = lerp(key_start_y, y + lock_offset_y, _e) - sin(_p * pi) * 60;
    var _ks = lerp(1, 0.6, _e);
    draw_sprite_ext(_key_spr, 0, _kx, _ky, _ks, _ks, _p * 360, c_white, 1);
}