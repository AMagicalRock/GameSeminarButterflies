var _index = -1;
if (room == Room_Area1) _index = 0;
else if (room == Room_Area2) _index = 1;
else if (room == Room_Area3) _index = 2;

current_area_index = _index;

// Only count once, the first time this area is entered —
// otherwise revisiting after completing tasks would recount
// the (now fewer, since completed ones are destroyed) remaining instances.
if (_index != -1 && areas[_index].total_tasks == 0) {
    var _count = 0;
    with (obj_task_inscene) {
        _count += 1;
    }
    areas[_index].total_tasks = _count;
}

if (current_area_index >= 1) { unlocked_flowers[2] = true; unlocked_flowers[3] = true; }
if (current_area_index >= 2) { unlocked_flowers[4] = true; unlocked_flowers[5] = true; }