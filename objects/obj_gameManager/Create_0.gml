global.player_locked = false;
randomize();
money = 0;
current_area_index = -1;
flower_sprites = [spr_flower_1, spr_flower_2, spr_flower_3, spr_flower_4, spr_flower_5, spr_flower_6];
lock_sprite = spr_lock;

butterfly_data = [
    { sprite: spr_butterfly_BlueGlassyTiger, name: "Blue Glassy Tiger", flower_name: "Vincetoxicum flexuosum" },
    { sprite: spr_butterfly_GrassYellow,     name: "Grass Yellow",      flower_name: "Peacock Flower" },
    { sprite: spr_butterfly_BushBrown,       name: "Bush Brown",        flower_name: "Cow Grass" },
    { sprite: spr_butterfly_BluePansy,       name: "Blue Pansy",        flower_name: "Coromandel" },
    { sprite: spr_butterfly_PaintedJezebel,  name: "Painted Jezebel",   flower_name: "Malayan Mistletoe" },
    { sprite: spr_butterfly_CommonRose,      name: "Common Rose",       flower_name: "Dutchman's Pipe" }
];

unlocked_flowers = [true, true, false, false, false, false]; // flowers 1-2 pre-unlocked, 3-6 wait for the shop

butterfly_spawn_timer = 0;

areas = [];

areas[0] = {
    name: "Area 1",
    total_tasks: 0,
    completed_tasks: 0,
    milestones: [
        { percent: 30, type: "money", amount: 50, triggered: false },
        { percent: 50, type: "money", amount: 75, triggered: false },
        { percent: 70, type: "key", id: "area2_key", triggered: false }
    ],
	planted_counts: [0, 0, 0, 0, 0, 0]
};

areas[1] = {
    name: "Area 2",
    total_tasks: 0,
    completed_tasks: 0,
    milestones: [
        { percent: 30, type: "money", amount: 50, triggered: false },
        { percent: 50, type: "money", amount: 75, triggered: false },
        { percent: 70, type: "key", id: "area3_key", triggered: false }
    ],
	planted_counts: [0, 0, 0, 0, 0, 0]
};

areas[2] = {
    name: "Area 3",
    total_tasks: 0,
    completed_tasks: 0,
    milestones: [
        { percent: 100, type: "butterfly", id: "tree_nymph", triggered: false }
    ],
	planted_counts: [0, 0, 0, 0, 0, 0]
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
            if (_m.type == "money") {
                money += _m.amount; // needs a `money = 0;` added to your Create Event
            }
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

get_allowed_butterfly_count = function(_area_index) {
    var _a = areas[_area_index];
    var _total_planted = 0;
    for (var i = 0; i < array_length(_a.planted_counts); i++) {
        _total_planted += _a.planted_counts[i];
    }
    if (_total_planted == 0) return 0;

    var _percent = get_area_percent(_area_index);
    if (_percent < 30) return 0;

    var _t = clamp((_percent - 30) / (70 - 30), 0, 1);
    return floor(1 + _t * (_total_planted - 1));
};

flower_positions_by_type = array_create(6);
for (var i = 0; i < 6; i++) flower_positions_by_type[i] = [];

rebuild_flower_positions = function() {
    for (var i = 0; i < 6; i++) flower_positions_by_type[i] = [];

    var _num = instance_number(obj_task_inscene);
    for (var t = 0; t < _num; t++) {
        var _task = instance_find(obj_task_inscene, t);
        if (_task.task_type == "flower" && _task.planted_flower != -1) {
            array_push(flower_positions_by_type[_task.planted_flower], { x: _task.x, y: _task.y });
        }
    }
};