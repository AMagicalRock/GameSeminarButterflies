global.player_locked = false;
global.carry = undefined;
design_width = 1920;
randomize();
current_area_index = -1;
tutorial_revealed = false;

flower_sprites = [spr_flower_1, spr_flower_2, spr_flower_3, spr_flower_4, spr_flower_5, spr_flower_6];
ui_flower_sprites = [ui_flower_1, ui_flower_2, ui_flower_3, ui_flower_4, ui_flower_5, ui_flower_6];
// Which flower appears in each of the six picker slots, starting at the top and going clockwise.
// The values are real flower indexes; only the picker uses this order.
flower_slot_order = [1, 0, 2, 3, 4, 5];
lock_sprite = ui_lock;

butterfly_data = [
    { sprite: spr_butterfly_BlueGlassyTiger, name: "Blue Glassy Tiger", flower_name: "Vincetoxicum flexuosum" },
    { sprite: spr_butterfly_GrassYellow,     name: "Grass Yellow",      flower_name: "Peacock Flower" },
    { sprite: spr_butterfly_BushBrown,       name: "Bush Brown",        flower_name: "Cow Grass" },
    { sprite: spr_butterfly_BluePansy,       name: "Blue Pansy",        flower_name: "Coromandel" },
    { sprite: spr_butterfly_PaintedJezebel,  name: "Painted Jezebel",   flower_name: "Malayan Mistletoe" },
    { sprite: spr_butterfly_CommonRose,      name: "Common Rose",       flower_name: "Dutchman's Pipe" }
];

unlocked_flowers = [false, true, false, false, false, false];
butterfly_discovered = [false, false, false, false, false, false];
butterfly_spawn_timer = 0;

is_in_no_fly_zone = function(_x, _y) {
    return collision_point(_x, _y, obj_shed_zone, false, true) != noone;
};

compute_ui_layout = function() {
    display_set_gui_size(window_get_width(), window_get_height());
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    ui_scale = _gw / design_width;

    var _set = bar_sprite_sets[max(current_area_index, 0)];
    ui_bar_h = sprite_get_height(_set.back) * ui_scale;
    ui_bar_w = sprite_get_width(_set.back) * ui_scale;
    ui_bar_x = _gw - (120 * ui_scale);
    ui_bar_y = (_gh - ui_bar_h) / 2;
};

money = 500;
tool_multipliers = { litter: 1, prune: 1 };
purchased = {};

// Items now just need sprite/name/cost/area/type — no x/y/scale/page,
// since the popup at each stand lays buttons out itself, not from stored positions.
shop_items = [
    { sprite: ui_button_shop_shears,           name: "Shears",                 cost: 100, area: 0, type: "tool", tool_id: "shears",   offset_x: -60, offset_y: -40 },
	{ sprite: ui_button_shop_cowGrass,         name: "Vincetoxicum Seeds",     cost: 25, area: 0, type: "seed", flower_index: 0,      offset_x: -100, offset_y: 60 },
	{ sprite: ui_button_shop_shears,		   name: "Boots",				   cost: 60, area: 0, type: "tool", tool_id: "boots",	  offset_x: 0, offset_y: 0 },
    { sprite: ui_button_shop_cowGrass,         name: "Cow Grass Seeds",        cost: 25, area: 1, type: "seed", flower_index: 2,      offset_x: 100,  offset_y: -60 },
    { sprite: ui_button_shop_coromandel,       name: "Coromandel Seeds",       cost: 30, area: 1, type: "seed", flower_index: 3,      offset_x: 20,  offset_y: 100 },
    { sprite: ui_button_shop_litterpicker,     name: "Litter Picker",          cost: 100, area: 1, type: "tool", tool_id: "litterpicker", offset_x: 0, offset_y: 0 },
    { sprite: ui_button_shop_malayanMistletoe, name: "Malayan Mistletoe Seeds",cost: 25, area: 2, type: "seed", flower_index: 4,      offset_x: 0,  offset_y: 0 },
    { sprite: ui_button_shop_dutchmansPipe,    name: "Dutchman's Pipe Seeds",  cost: 30, area: 2, type: "seed", flower_index: 5,      offset_x: 0,  offset_y: 0 }
];

buy_item = function(_item) {
    if (money < _item.cost) return false;

    if (_item.type == "seed") {
        if (unlocked_flowers[_item.flower_index]) return false;
        unlocked_flowers[_item.flower_index] = true;
    } else if (_item.type == "tool") {
        if (variable_struct_exists(purchased, _item.tool_id)) return false;
        variable_struct_set(purchased, _item.tool_id, true);
        if (_item.tool_id == "litterpicker") tool_multipliers.litter = 0.6;
        if (_item.tool_id == "shears") tool_multipliers.prune = 0.6;
    }

    money -= _item.cost;
    return true;
};

areas = [];

areas[0] = {
    name: "Area 1", total_tasks: 0, completed_tasks: 0,
    milestones: [
        { percent: 25, type: "money", amount: 50, triggered: false },
        { percent: 50, type: "money", amount: 75, triggered: false },
        { percent: 75, type: "key", id: "area2_key", triggered: false },
		{ percent: 100, type: "trophy", id: "trophy_1", triggered: false }
    ],
    planted_counts: [0, 0, 0, 0, 0, 0]
};

areas[1] = {
    name: "Area 2", total_tasks: 0, completed_tasks: 0,
    milestones: [
        { percent: 25, type: "money", amount: 50, triggered: false },
        { percent: 50, type: "money", amount: 75, triggered: false },
        { percent: 75, type: "key", id: "area3_key", triggered: false },
		{ percent: 100, type: "trophy", id: "trophy_2", triggered: false }
    ],
    planted_counts: [0, 0, 0, 0, 0, 0]
};

areas[2] = {
    name: "Area 3", total_tasks: 0, completed_tasks: 0,
    milestones: [
	    { percent: 25, type: "money", amount: 50, triggered: false },
        { percent: 50, type: "money", amount: 75, triggered: false },
		{ percent: 75, type: "money", amount: 75, triggered: false },
        { percent: 100, type: "trophy", id: "trophy_3", triggered: false }
    ],
    planted_counts: [0, 0, 0, 0, 0, 0]
};

areas[3] = {
    name: "Tutorial", total_tasks: 0, completed_tasks: 0,
    milestones: [
        { percent: 100, type: "key", id: "tutorial_key", triggered: false }
    ],
    planted_counts: [0, 0, 0, 0, 0, 0]
};

get_area_percent = function(_i) {
    var _a = areas[_i];
    if (_a.total_tasks == 0) return 0;
    return clamp((_a.completed_tasks / _a.total_tasks) * 100, 0, 100);
};

check_milestones = function(_i) {
    var _a = areas[_i];
    var _percent = get_area_percent(_i);
    for (var j = 0; j < array_length(_a.milestones); j++) {
        var _m = _a.milestones[j];
		if (!_m.triggered && _percent >= _m.percent) {
		    _m.triggered = true;
		    if (_m.type == "key" || _m.type == "trophy") {
		        set_key_state(_m.id, "earned");
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

completed_task_ids = [];
planted_flowers = {};

// Key progression: "unearned" → "earned" → "revealed" → "collected" → "used"
key_states = {
    area2_key: "unearned",
    area3_key: "unearned",
	tutorial_key: "unearned"
};

get_key_state = function(_id) {
    if (!variable_struct_exists(key_states, _id)) return "unearned";
    return variable_struct_get(key_states, _id);
};

key_state_rank = { unearned: 0, earned: 1, revealed: 2, collected: 3, used: 4, placed: 4 };

set_key_state = function(_id, _state) {
    var _cur = variable_struct_get(key_state_rank, get_key_state(_id));
    var _new = variable_struct_get(key_state_rank, _state);
    if (_new > _cur) variable_struct_set(key_states, _id, _state);   // moves forward, never backward
};

has_key = function(_id) {
    return get_key_state(_id) == "collected";
};

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
    for (var i = 0; i < array_length(_a.planted_counts); i++) _total_planted += _a.planted_counts[i];
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

money_particles = [];

spawn_money_particles = function(_x, _y, _count, _amount) {
    for (var i = 0; i < _count; i++) {
        array_push(money_particles, {
            x: _x, y: _y,
            start_x: _x + irandom_range(-10, 10),
            start_y: _y + irandom_range(-10, 10),
            progress: 0,
            speed: random_range(0.02, 0.035),
            delay: i * 3,
            amount: _amount,
            is_last: (i == _count - 1),
            sprite: coin_sprites[irandom(array_length(coin_sprites) - 1)],
            angle: random(360),
            spin: random_range(-6, 6),   // set to 0 if the coin art already spins
            frame: 0
        });
    }
};

money_popups = [];

spawn_money_popup = function(_amount) {
    array_push(money_popups, {
        amount: _amount,
        display: 0,
        x: money_text_x,
        y: money_text_y + 45 * ui_scale, // pushed further below the counter
        state: "counting",
        timer: 0,
        alpha: 1
    });
};

money_counter_bounce = 0;

bar_sprite_sets = [
    { back: ui_pbArea1Back, front: ui_pbArea1Front, bud: ui_pbArea1Bud,
      flowers: [ui_pbArea1Flower_1, ui_pbArea1Flower_2, ui_pbArea1Flower_3, ui_pbArea1Flower_4],
      fill_color: c_lime },
    { back: ui_pbArea2Back, front: ui_pbArea2Front, bud: ui_pbArea2Bud,
      flowers: [ui_pbArea2Flower_1, ui_pbArea2Flower_2, ui_pbArea2Flower_3, ui_pbArea2Flower_4],
      fill_color: c_aqua },
    { back: ui_pbArea3Back, front: ui_pbArea3Front, bud: ui_pbArea3Bud,
      flowers: [ui_pbArea3Flower_1, ui_pbArea3Flower_2, ui_pbArea3Flower_3, ui_pbArea3Flower_4],
      fill_color: c_yellow }
];

bar_sprite_sets[3] = {
    back: ui_pbArea1Back, front: ui_pbArea1Front, bud: ui_pbArea1Bud,
    flowers: [ui_pbArea1Flower_1, ui_pbArea1Flower_2, ui_pbArea1Flower_3, ui_pbArea1Flower_4],
    fill_color: c_lime
};

coin_sprites = [particle_coin_1, particle_coin_2, particle_coin_3];
sparkle_sprites = [
    particle_sparkle_01, particle_sparkle_02, particle_sparkle_03, particle_sparkle_04, particle_sparkle_05,
    particle_sparkle_06, particle_sparkle_07, particle_sparkle_08, particle_sparkle_09, particle_sparkle_10
];

coin_size = 22;            // coin size on screen, in pixels at design resolution
sparkle_size_mult = 1;     // scales every sparkle at once
key_butterfly_size = 56;   // gold butterfly size on screen
key_butterfly_flap = 0.35; // animation frames advanced per step
key_butterfly_wander_seconds = 5;   // how long it flutters around before landing
key_butterfly_speed = 6;          // pixels per step while fluttering, at design resolution
key_butterfly_land_frames = 55;     // length of the final glide down to the key
key_butterfly_art_facing = 180;   // the direction the art faces at 0 rotation: 0 = right, 90 = up, 180 = left, 270 = down
key_butterfly_start_radius = 600;   // how widely it flutters around the key at first, in design pixels
key_butterfly_end_radius = 110;     // how tightly it circles the key just before landing

key_stars = [];
sparkles = [];

spawn_sparkle = function(_x, _y, _speed, _size) {
    var _dir = random(360);
    var _spd = random_range(_speed * 0.4, _speed);
    var _life = irandom_range(20, 40);
    array_push(sparkles, {
        x: _x, y: _y,
        vx: lengthdir_x(_spd, _dir),
        vy: lengthdir_y(_spd, _dir),
        life: _life, max_life: _life,
        size: random_range(_size * 0.6, _size),
        angle: random(360),
        spin: random_range(-6, 6),
        sprite: sparkle_sprites[irandom(array_length(sparkle_sprites) - 1)],
        room_space: false
    });
};

spawn_key_star = function(_x, _y, _key_id) {
    var _sw = display_get_gui_width();
    var _sh = display_get_gui_height();
    var _start_heading = point_direction(_x, _y, _sw * 0.4, _sh * 0.5);   // leaves the bud heading into the screen

    array_push(key_stars, {
        key_id: _key_id,
        x: _x, y: _y,
        phase: "wander",                 // wander → land
        age: 0,
        wander_left: key_butterfly_wander_seconds * game_get_speed(gamespeed_fps),
        heading: _start_heading,
        angle: _start_heading - key_butterfly_art_facing,      // the drawn rotation, starts already facing the right way
        target_x: _sw * 0.4,
        target_y: _sh * 0.5,
        land_t: 0, land_sx: 0, land_sy: 0,
        frame: 0
    });
};

// Gentle, rising sparkle that stays attached to a spot in the room
spawn_ambient_sparkle = function(_rx, _ry) {
    var _life = irandom_range(30, 50);
    array_push(sparkles, {
        x: _rx, y: _ry,
        vx: random_range(-0.25, 0.25),
        vy: random_range(-1.2, -0.6),
        life: _life, max_life: _life,
        size: random_range(6, 10),
        angle: random(360),
        spin: random_range(-3, 3),
        color: choose(c_white, make_color_rgb(255, 225, 90)),
        room_space: true
    });
};

// A star made from a triangle fan: a center vertex plus a ring alternating between outer and inner radius
draw_star_shape = function(_x, _y, _outer, _inner, _points, _angle, _color, _alpha) {
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_x, _y, _color, _alpha);
    for (var i = 0; i <= _points * 2; i++) {
        var _r = (i mod 2 == 0) ? _outer : _inner;
        var _a = _angle + i * (180 / _points);
        draw_vertex_color(_x + lengthdir_x(_r, _a), _y + lengthdir_y(_r, _a), _color, _alpha);
    }
    draw_primitive_end();
};

key_sprites = {
    area2_key: spr_key_area2,
    area3_key: spr_key_area3,
    tutorial_key: spr_key_tutorial,
    trophy_1: spr_statue_trophy_1,
    trophy_2: spr_statue_trophy_2,
    trophy_3: spr_statue_trophy_3
};
key_hud = {};   // key_id → pop-in progress (0 to 1) for the HUD icon

key_hud_scale = {
    area2_key: 1.1,
    area3_key: 1.1,
    tutorial_key: 1.1,
    trophy_1: 0.7,
    trophy_2: 0.7,
    trophy_3: 0.7
};

room_to_gui_x = function(_rx) {
    var _cam = view_camera[0];
    return (_rx - camera_get_view_x(_cam)) * (display_get_gui_width() / camera_get_view_width(_cam));
};
room_to_gui_y = function(_ry) {
    var _cam = view_camera[0];
    return (_ry - camera_get_view_y(_cam)) * (display_get_gui_height() / camera_get_view_height(_cam));
};

collect_key = function(_key_id, _room_x, _room_y) {
    set_key_state(_key_id, "collected");
    repeat (14) spawn_sparkle(room_to_gui_x(_room_x), room_to_gui_y(_room_y), 5 * ui_scale, 10);
    variable_struct_set(key_hud, _key_id, 0);
};

trophy_ids = ["trophy_1", "trophy_2", "trophy_3"];

has_unplaced_trophy = function() {
    for (var i = 0; i < array_length(trophy_ids); i++) {
        if (get_key_state(trophy_ids[i]) == "collected") return true;
    }
    return false;
};

find_sign_for = function(_butterfly_index) {
    for (var i = 0; i < instance_number(obj_exhibit_sign); i++) {
        var _s = instance_find(obj_exhibit_sign, i);
        if (_s.butterfly_index == _butterfly_index) return _s;
    }
    return noone;
};
