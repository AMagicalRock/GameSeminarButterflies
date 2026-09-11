if (task_id == "") {
    task_id = room_get_name(room) + "_" + string(x) + "_" + string(y);
}

completed = false;
planted_flower = -1;

if (obj_gameManager.is_task_completed(task_id)) {
    completed = true;
    if (always_interactable && variable_struct_exists(obj_gameManager.planted_flowers, task_id)) {
        planted_flower = variable_struct_get(obj_gameManager.planted_flowers, task_id);
    }
}

if (sprite_default != -1) {
    sprite_index = sprite_default;
}
if (completed) {
    if (always_interactable) {
        if (planted_flower != -1) sprite_index = obj_gameManager.flower_sprites[planted_flower];
    } else if (sprite_complete != -1) {
        sprite_index = sprite_complete;
    } else {
        instance_destroy(self);
    }
}

always_on_ground = flat_on_ground || task_type == "litter" || (task_type == "flower" && planted_flower == -1);
event_inherited();

interacting_with = noone;
hold_time_max = 90 * ((task_type == "litter") ? obj_gameManager.tool_multipliers.litter : 1);
hold_time = 0;