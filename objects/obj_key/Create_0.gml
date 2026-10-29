sparkle_timer = 0;
glints = [];   // this key's own sparkles, in room coordinates

if (sprite_default != -1) {
    sprite_index = sprite_default;
}

var _state = variable_instance_exists(obj_gameManager, "get_key_state") ? obj_gameManager.get_key_state(key_id) : "unearned";

if (_state == "collected" || _state == "used" || _state == "placed") {
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
// Size on the ground. Keys keep whatever scale they already had, and trophies get their own.
var _ground_scale = image_xscale;
if (string_pos("trophy_", key_id) == 1) _ground_scale = 0.7;   // the trophy dial: smaller = smaller on the ground

image_xscale = _ground_scale;
image_yscale = _ground_scale;
base_scale = _ground_scale;   // the pop-in animation grows to this size and settles on it
pop_timer = 0;

// The middle of the visible art, whatever the sprite's origin is
art_center_x = function() {
    return x + (sprite_get_width(sprite_index) / 2 - sprite_get_xoffset(sprite_index)) * base_scale;
};
art_center_y = function() {
    return y + (sprite_get_height(sprite_index) / 2 - sprite_get_yoffset(sprite_index)) * base_scale;
};