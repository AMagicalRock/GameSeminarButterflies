// Completed on an earlier visit: never shows again
if (obj_gameManager.is_tutorial_group_done(group_id)) {
    instance_destroy();
    exit;
}

depth = 100;           // flat on the ground, beneath the player and every upright object
lit = false;
state = "active";      // active → holding → fading
hold_timer = 0;
fade_alpha = 1;
pop_timer = 0;
sprite_index = sprite_off;

// WASD and the arrow keys both light the matching decal, since the player can use either
key_is_down = function() {
    switch (trigger_key) {
        case "W": return keyboard_check(ord("W")) || keyboard_check(vk_up);
        case "A": return keyboard_check(ord("A")) || keyboard_check(vk_left);
        case "S": return keyboard_check(ord("S")) || keyboard_check(vk_down);
        case "D": return keyboard_check(ord("D")) || keyboard_check(vk_right);
        case "E": return keyboard_check(ord("E"));
    }
    return false;
};

if (!is_string(trigger_key)) trigger_key = "";   // a stray 0 or undefined means "no key"