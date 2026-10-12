if (zone == noone) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// The shed's footprint, converted from room coordinates to screen coordinates and kept on screen
var _l = clamp(obj_gameManager.room_to_gui_x(zone.bbox_left), 0, _gw);
var _t = clamp(obj_gameManager.room_to_gui_y(zone.bbox_top), 0, _gh);
var _r = clamp(obj_gameManager.room_to_gui_x(zone.bbox_right + 1), 0, _gw);
var _b = clamp(obj_gameManager.room_to_gui_y(zone.bbox_bottom + 1), 0, _gh);

var _a = cover_alpha;
var _c = c_black;

draw_primitive_begin(pr_trianglestrip);
draw_vertex_color(0, 0, _c, _a);       draw_vertex_color(_l, _t, _c, _a);
draw_vertex_color(_gw, 0, _c, _a);     draw_vertex_color(_r, _t, _c, _a);
draw_vertex_color(_gw, _gh, _c, _a);   draw_vertex_color(_r, _b, _c, _a);
draw_vertex_color(0, _gh, _c, _a);     draw_vertex_color(_l, _b, _c, _a);
draw_vertex_color(0, 0, _c, _a);       draw_vertex_color(_l, _t, _c, _a);
draw_primitive_end();