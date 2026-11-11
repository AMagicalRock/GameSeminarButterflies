if (!obj_gameManager.is_task_completed(task_id)) {
    // The middle of the grass, whatever its origin is
    var _cx = x + (sprite_get_width(sprite_index) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale;
    var _cy = y + (sprite_get_height(sprite_index) / 2 - sprite_get_yoffset(sprite_index)) * image_yscale;
    obj_gameManager.spawn_grass_burst(_cx, _cy, irandom_range(10, 14));

    obj_gameManager.complete_task(self);
}