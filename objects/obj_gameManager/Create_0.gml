global.player_locked = false;
current_area_index = -1;
flower_sprites = [ph_flower_1, ph_flower_2, ph_flower_3, ph_flower_4, ph_flower_5, ph_flower_6];
lock_sprite = ph_lock;
//flower_sprites = [spr_flower_0, spr_flower_1, spr_flower_2, spr_flower_3, spr_flower_4, spr_flower_5];
//lock_sprite = spr_lock;

areas = [];

areas[0] = {
    name: "Area 1",
    total_tasks: 0,
    completed_tasks: 0,
    milestones: [
        { percent: 30, type: "butterfly", id: "common_rose", triggered: false },
        { percent: 60, type: "butterfly", id: "lime_butterfly", triggered: false },
        { percent: 100, type: "key", id: "area2_key", triggered: false }
    ]
};

areas[1] = {
    name: "Area 2",
    total_tasks: 0,
    completed_tasks: 0,
    milestones: [
        { percent: 50, type: "butterfly", id: "peacock_pansy", triggered: false },
        { percent: 100, type: "key", id: "area3_key", triggered: false }
    ]
};

areas[2] = {
    name: "Area 3",
    total_tasks: 0,
    completed_tasks: 0,
    milestones: [
        { percent: 100, type: "butterfly", id: "tree_nymph", triggered: false }
    ]
};

get_area_percent = function(_i) {
    var _a = areas[_i];
    if (_a.total_tasks == 0) return 0;
    return (_a.completed_tasks / _a.total_tasks) * 100;
};

check_milestones = function(_i) {
    var _a = areas[_i];
    var _percent = get_area_percent(_i);

    for (var j = 0; j < array_length(_a.milestones); j++) {
        var _m = _a.milestones[j];
        if (!_m.triggered && _percent >= _m.percent) {
            _m.triggered = true;
            show_debug_message("Unlocked: " + _m.id + " (" + _m.type + ")");
            // later: actually spawn the butterfly instance or unlock the door
        }
    }
};

add_progress = function(_area_index) {
    areas[_area_index].completed_tasks += 1;
    check_milestones(_area_index);
};

complete_task = function(_task) {
    mark_task_completed(_task.task_id);
    add_progress(current_area_index);

    if (_task.sprite_complete != -1) {
        _task.sprite_index = _task.sprite_complete;
        _task.completed = true;
    } else {
        instance_destroy(_task);
    }
};

unlocked_flowers = [true, true, false, false, false, false];

completed_task_ids = [];
planted_flowers = {};

is_task_completed = function(_id) {
    for (var i = 0; i < array_length(completed_task_ids); i++) {
        if (completed_task_ids[i] == _id) return true;
    }
    return false;
};

mark_task_completed = function(_id) {
    array_push(completed_task_ids, _id);
};