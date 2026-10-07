event_inherited();

task_id = room_get_name(room) + "_" + string(x) + "_" + string(y);
sprite_complete = -1; // grass is destroyed, never swapped

was_near_player = false;
bounce_timer = 0;

if (obj_gameManager.is_task_completed(task_id)) {
    instance_destroy(self);
}