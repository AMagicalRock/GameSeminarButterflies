gate_id = "gate_" + room_get_name(room) + "_" + string(x) + "_" + string(y);
is_open = obj_gameManager.is_task_completed(gate_id);
sprite_index = is_open ? sprite_open : sprite_closed;

event_inherited();

can_interact = false;
open_timer = 0;
base_xscale = image_xscale;
base_yscale = image_yscale;

// Split mode: only the OPEN gate is drawn as two pieces; the closed gate stays one full sprite
use_split = sprite_exists(sprite_open_top) && sprite_exists(sprite_open_bottom);
top_open = sprite_open_top;
bottom_open = sprite_open_bottom;
front_part = noone;

if (use_split) {
    mask_index = sprite_closed;   // collision always uses the full closed shape
    front_part = instance_create_depth(x, y, 0, obj_gate_front, { owner: id });
}

update_gate_sort = function() {
    if (use_split && is_open) {
        always_on_ground = true;   // you walk through it, so no fade
        image_alpha = 1;
        depth = -(y + cut_offset_y * base_yscale);
        front_part.refresh();
    } else if (vertical_gate && is_open) {
        always_on_ground = true;
        image_alpha = 1;
        depth = -bbox_top;
    } else {
        depth = -bbox_bottom;
    }
};
update_gate_sort();