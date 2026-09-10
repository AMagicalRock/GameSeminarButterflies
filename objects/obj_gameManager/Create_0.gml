global.player_locked = false;
design_width = 1920; // the resolution your button art was made for
randomize();
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

// --- UI Buttons ---
// Each entry: sprite + manually-chosen x/y position (top-left corner) + what it does.
// Adjust x/y freely to match your catalog art — nothing here is auto-calculated.

compute_ui_layout = function() {
    display_set_gui_size(window_get_width(), window_get_height());

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    ui_scale = _gw / design_width;

    ui_bar_h = 300 * ui_scale;
    ui_bar_w = 20 * ui_scale;
    ui_bar_x = _gw - (40 * ui_scale);
    ui_bar_y = (_gh - ui_bar_h) / 2;
};

shop_background_sprite = spr_shop_page1and2;

tab_buttons = [
    { sprite: spr_button_shop,    x: 1805, y: 784, action: "shop" },
    { sprite: spr_button_journal, x: 1805, y: 928, action: "journal" }
];

shop_items = [
    { sprite: spr_button_shop_litterpicker,      name: "Litter Picker",           cost: 50,  page: 0, x: 643, y: 667, type: "tool", tool_id: "litterpicker" },
    { sprite: spr_button_shop_shears,            name: "Shears",                 cost: 50,  page: 0, x: 284, y: 114, type: "tool", tool_id: "shears" },
    { sprite: spr_button_shop_cow_grass,         name: "Cow Grass Seeds",         cost: 50,  page: 1, x: 1059, y: 347, type: "seed", flower_index: 2 },
    { sprite: spr_button_shop_coromandel,        name: "Coromandel Seeds",        cost: 60,  page: 1, x: 1155, y: 501, type: "seed", flower_index: 3 },
    { sprite: spr_button_shop_malayan_mistletoe, name: "Malayan Mistletoe Seeds", cost: 70, page: 1, x: 1289, y: 655, type: "seed", flower_index: 4 },
    { sprite: spr_button_shop_dutchmans_pipe,    name: "Dutchman's Pipe Seeds",   cost: 80, page: 1, x: 1438, y: 786, type: "seed", flower_index: 5 }
];

var _max_page = 0;
for (var i = 0; i < array_length(shop_items); i++) _max_page = max(_max_page, shop_items[i].page);
max_spread = floor(_max_page / 2);
current_spread = 0;

is_point_in_button = function(_mx, _my, _btn) {
    var _w = sprite_get_width(_btn.sprite) * ui_scale;
    var _h = sprite_get_height(_btn.sprite) * ui_scale;
    var _x = _btn.x * ui_scale;
    var _y = _btn.y * ui_scale;
    return (_mx > _x && _mx < _x + _w && _my > _y && _my < _y + _h);
};

money = 500;
shop_open = false;
journal_open = false;
tool_multipliers = { litter: 1, prune: 1 };
purchased = {};

buy_item = function(_item) {
    if (money < _item.cost) return false;

    if (_item.type == "seed") {
        if (unlocked_flowers[_item.flower_index]) return false;
        unlocked_flowers[_item.flower_index] = true;
    } else if (_item.type == "tool") {
        if (variable_struct_exists(purchased, _item.tool_id)) return false;
        variable_struct_set(purchased, _item.tool_id, true);
        if (_item.tool_id == "litterpicker") tool_multipliers.litter = 0.6;
        if (_item.tool_id == "shears") tool_multipliers.prune = 0.6; // hook — not wired into prune's puzzle yet
    }

    money -= _item.cost;
    return true;
};

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