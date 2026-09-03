interacting_with = noone;

if (sprite_default != -1) {
    sprite_index = sprite_default;
}

if (task_id == "") {
    task_id = room_get_name(room) + "_" + string(x) + "_" + string(y);
}

hold_time = 0;
hold_time_max = 90;
completed = false;
planted_flower = -1;

if (obj_gameManager.is_task_completed(task_id)) {
    completed = true;

    if (always_interactable) {
        if (variable_struct_exists(obj_gameManager.planted_flowers, task_id)) {
            planted_flower = variable_struct_get(obj_gameManager.planted_flowers, task_id);
            sprite_index = obj_gameManager.flower_sprites[planted_flower];
        }
    } else if (sprite_complete != -1) {
        sprite_index = sprite_complete; // e.g. bush stays as the clean sprite permanently
    } else {
        instance_destroy(self);
    }
}