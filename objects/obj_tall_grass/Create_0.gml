event_inherited();

task_id = room_get_name(room) + "_" + string(x) + "_" + string(y);
sprite_complete = -1; // grass is destroyed, never swapped

if (obj_gameManager.is_task_completed(task_id)) {
    instance_destroy(self);
}