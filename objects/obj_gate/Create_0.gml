// Remembers being opened using the same id list your tasks use.
// This does NOT add progress, so the gate never counts toward the area's percentage.
gate_id = "gate_" + room_get_name(room) + "_" + string(x) + "_" + string(y);
is_open = obj_gameManager.is_task_completed(gate_id);
sprite_index = is_open ? sprite_open : sprite_closed;

event_inherited();   // Y-sorting and fade from obj_ysort, after the sprite is final

can_interact = false;
open_timer = 0;
base_xscale = image_xscale;
base_yscale = image_yscale;