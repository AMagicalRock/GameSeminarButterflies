global.player_locked = false;
design_width = 1920; // the resolution your button art was made for
randomize();
current_area_index = -1;
flower_sprites = [spr_flower_1, spr_flower_2, spr_flower_3, spr_flower_4, spr_flower_5, spr_flower_6];
lock_sprite = spr_lock;
shop_open = false;
journal_open = false;

butterfly_data = [
    { sprite: spr_butterfly_BlueGlassyTiger, name: "Blue Glassy Tiger", flower_name: "Vincetoxicum flexuosum" },
    { sprite: spr_butterfly_GrassYellow,     name: "Grass Yellow",      flower_name: "Peacock Flower" },
    { sprite: spr_butterfly_BushBrown,       name: "Bush Brown",        flower_name: "Cow Grass" },
    { sprite: spr_butterfly_BluePansy,       name: "Blue Pansy",        flower_name: "Coromandel" },
    { sprite: spr_butterfly_PaintedJezebel,  name: "Painted Jezebel",   flower_name: "Malayan Mistletoe" },
    { sprite: spr_butterfly_CommonRose,      name: "Common Rose",       flower_name: "Dutchman's Pipe" }
];

unlocked_flowers = [true, true, false, false, false, false];

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

focused_window = "shop"; // "shop" or "journal" — whichever is currently on top

tab_buttons = [
    { sprite: spr_button_shop,    x: 1805, y: 784, action: "shop",    hover_offset: 0 },
    { sprite: spr_button_journal, x: 1805, y: 928, action: "journal", hover_offset: 0 }
];

shop_background_sprite = spr_shop_page1and2;

shop_items = [
    { sprite: spr_button_shop_litterpicker,      name: "Litter Picker",           cost: 50,  page: 0, x: 755, y: 659, type: "tool", tool_id: "litterpicker", scale: 1 },
    { sprite: spr_button_shop_shears,            name: "Shears",                 cost: 50,  page: 0, x: 628, y: 177, type: "tool", tool_id: "shears", scale: 1 },
    { sprite: spr_button_shop_cowGrass,         name: "Cow Grass Seeds",         cost: 50,  page: 1, x: 1057, y: 209, type: "seed", flower_index: 2, scale: 1 },
    { sprite: spr_button_shop_coromandel,        name: "Coromandel Seeds",        cost: 60,  page: 1, x: 1061, y: 391, type: "seed", flower_index: 3, scale: 1 },
    { sprite: spr_button_shop_malayanMistletoe, name: "Malayan Mistletoe Seeds", cost: 70, page: 1, x: 1064, y: 586, type: "seed", flower_index: 4, scale: 1 },
    { sprite: spr_button_shop_dutchmansPipe,    name: "Dutchman's Pipe Seeds",   cost: 80, page: 1, x: 1063, y: 761, type: "seed", flower_index: 5, scale: 1 }
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

page_x = 250;
page_y = 100;

// tab_y is each page's tab position on the LEFT edge, likely evenly spaced downward — adjust these
// to match wherever your artist actually placed each tab in the sprite
journal_pages = [
    { sprite: spr_journal_page1and2, tab_y: 77 },
    { sprite: spr_journal_page3and4, tab_y: 137 },
    { sprite: spr_journal_page5and6, tab_y: 197 },
    { sprite: spr_journal_page7and8, tab_y: 257 },
    { sprite: spr_journal_page9and10, tab_y: 317 },
    { sprite: spr_journal_page11and12, tab_y: 377 },
    { sprite: spr_journal_page13and14, tab_y: 437 }
];

journal_tab_w = 40; // width of the clickable tab strip sticking out the side
journal_tab_h = 60;

current_journal_spread = 0;

butterfly_discovered = [false, false, false, false, false, false];

journal_icon_positions = [
    { x: 320, y: 180 }, { x: 320, y: 280 }, { x: 320, y: 380 },
    { x: 620, y: 180 }, { x: 620, y: 280 }, { x: 620, y: 380 }
];

shop_offset_x = 0; shop_offset_y = 0;
journal_offset_x = 0; journal_offset_y = 0;
shop_dragging = false; journal_dragging = false;
drag_start_mx = 0; drag_start_my = 0; drag_start_off_x = 0; drag_start_off_y = 0;

shop_x = function(_v) { return (_v + shop_offset_x) * ui_scale; };
shop_y = function(_v) { return (_v + shop_offset_y) * ui_scale; };
journal_x = function(_v) { return (_v + journal_offset_x) * ui_scale; };
journal_y = function(_v) { return (_v + journal_offset_y) * ui_scale; };

// =====================================================
// SHOP PANEL — draws background, items, page arrows
// =====================================================
draw_shop_panel = function() {
    var _bg_x = shop_x(608);
    var _bg_y = shop_y(128);

    if (shop_background_sprite != -1) {
        draw_sprite_ext(shop_background_sprite, 0, _bg_x, _bg_y, ui_scale, ui_scale, 0, c_white, 1);
    } else {
        draw_rectangle_color(_bg_x, _bg_y, _bg_x + 700 * ui_scale, _bg_y + 400 * ui_scale, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
    }

    draw_set_color(c_white);
    draw_text(shop_x(270), shop_y(110), "Catalog — Money: " + string(money));

    var _left_page = current_spread * 2;
    var _right_page = current_spread * 2 + 1;

    for (var i = 0; i < array_length(shop_items); i++) {
        var _item = shop_items[i];
        if (_item.page == _left_page || _item.page == _right_page) {
            var _w = sprite_get_width(_item.sprite);
            var _h = sprite_get_height(_item.sprite);
            var _final_scale = ui_scale * _item.scale;
            var _draw_x = shop_x(_item.x) - (_w * (_final_scale - ui_scale)) / 2;
            var _draw_y = shop_y(_item.y) - (_h * (_final_scale - ui_scale)) / 2;

            draw_sprite_ext(_item.sprite, 0, _draw_x, _draw_y, _final_scale, _final_scale, 0, c_white, 1);
        }
    }

    if (current_spread > 0) draw_text(shop_x(265), shop_y(300), "<");
    if (current_spread < max_spread) draw_text(shop_x(910), shop_y(300), ">");
};

// =====================================================
// JOURNAL PANEL — draws page stack, content-page icons,
// or the individual butterfly info page
// =====================================================
draw_journal_panel = function() {
    // Draw every non-active page first — only their tabs will remain visible
    for (var i = 0; i < array_length(journal_pages); i++) {
        if (i != current_journal_spread) {
            draw_sprite_ext(journal_pages[i].sprite, 0, journal_x(page_x), journal_y(page_y), ui_scale, ui_scale, 0, c_white, 1);
        }
    }
    // Draw the active page LAST, fully on top
    draw_sprite_ext(journal_pages[current_journal_spread].sprite, 0, journal_x(page_x), journal_y(page_y), ui_scale, ui_scale, 0, c_white, 1);

    draw_set_color(c_white);

    if (current_journal_spread == 0) {
        // Content page — one icon per butterfly, question mark if undiscovered
        for (var i = 0; i < 6; i++) {
            var _pos = journal_icon_positions[i];
            if (butterfly_discovered[i]) {
                draw_sprite_ext(butterfly_data[i].sprite, 0, journal_x(_pos.x), journal_y(_pos.y), ui_scale, ui_scale, 0, c_white, 1);
            } else {
                draw_circle_color(journal_x(_pos.x), journal_y(_pos.y), 30 * ui_scale, c_gray, c_gray, false);
                draw_set_color(c_white);
                draw_text(journal_x(_pos.x) - 6, journal_y(_pos.y) - 8, "?");
            }
        }
    } else {
        // Individual butterfly page
        var _i = current_journal_spread - 1;
        var _b = butterfly_data[_i];

        if (butterfly_discovered[_i]) {
            draw_sprite_ext(_b.sprite, 0, journal_x(480), journal_y(180), ui_scale * 2.5, ui_scale * 2.5, 0, c_white, 1);
        } else {
            draw_text(journal_x(270), journal_y(110), "???");
        }
    }
};

handle_shop_click = function(_mx, _my) {
    if (!shop_open) return false;

    if (_mx > shop_x(260) && _mx < shop_x(300) && _my > shop_y(290) && _my < shop_y(330) && current_spread > 0) {
        current_spread -= 1;
        return true;
    }
    if (_mx > shop_x(900) && _mx < shop_x(940) && _my > shop_y(290) && _my < shop_y(330) && current_spread < max_spread) {
        current_spread += 1;
        return true;
    }

    var _left_page = current_spread * 2;
    var _right_page = current_spread * 2 + 1;
    var _shifted_mx = _mx - shop_offset_x * ui_scale;
    var _shifted_my = _my - shop_offset_y * ui_scale;

    for (var i = 0; i < array_length(shop_items); i++) {
        var _item = shop_items[i];
        if ((_item.page == _left_page || _item.page == _right_page) && is_point_in_button(_shifted_mx, _shifted_my, _item)) {
            buy_item(_item);
            return true;
        }
    }

    var _bg_w = (shop_background_sprite != -1) ? sprite_get_width(shop_background_sprite) : 700;
	var _bg_h = (shop_background_sprite != -1) ? sprite_get_height(shop_background_sprite) : 400;

	if (_mx > shop_x(608) && _mx < shop_x(608 + _bg_w) && _my > shop_y(128) && _my < shop_y(128 + _bg_h)) {
        shop_dragging = true;
        drag_start_mx = _mx; drag_start_my = _my;
        drag_start_off_x = shop_offset_x; drag_start_off_y = shop_offset_y;
        return true;
    }

    return false;
};

handle_journal_click = function(_mx, _my) {
    if (!journal_open) return false;

    for (var i = 0; i < array_length(journal_pages); i++) {
        var _tab_x = journal_x(page_x);
        var _tab_y = journal_y(journal_pages[i].tab_y);
        if (_mx > _tab_x && _mx < _tab_x + journal_tab_w * ui_scale
        && _my > _tab_y && _my < _tab_y + journal_tab_h * ui_scale) {
            current_journal_spread = i;
            return true;
        }
    }

    if (current_journal_spread == 0) {
        for (var i = 0; i < 6; i++) {
            var _pos = journal_icon_positions[i];
            if (_mx > journal_x(_pos.x - 40) && _mx < journal_x(_pos.x + 40)
            && _my > journal_y(_pos.y - 40) && _my < journal_y(_pos.y + 40)) {
                current_journal_spread = i + 1;
                return true;
            }
        }
    }

    var _current_sprite = journal_pages[current_journal_spread].sprite;
    var _bg_w = sprite_get_width(_current_sprite) * ui_scale;
    var _bg_h = sprite_get_height(_current_sprite) * ui_scale;

    if (_mx > journal_x(page_x) && _mx < journal_x(page_x) + _bg_w
    && _my > journal_y(page_y) && _my < journal_y(page_y) + _bg_h) {
        journal_dragging = true;
        drag_start_mx = _mx; drag_start_my = _my;
        drag_start_off_x = journal_offset_x; drag_start_off_y = journal_offset_y;
        return true;
    }

    return false;
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