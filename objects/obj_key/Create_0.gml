sparkle_timer = 0;

if (sprite_default != -1) {
    sprite_index = sprite_default;
}

var _state = variable_instance_exists(obj_gameManager, "get_key_state") ? obj_gameManager.get_key_state(key_id) : "unearned";

if (_state == "collected" || _state == "used") {
    instance_destroy();
    exit;
}

// If the star never landed (player left mid-flight), just show the key on the next visit
if (_state == "earned") {
    obj_gameManager.set_key_state(key_id, "revealed");
    _state = "revealed";
}

revealed = (_state == "revealed");
visible = revealed;
base_scale = image_xscale;
pop_timer = 0;