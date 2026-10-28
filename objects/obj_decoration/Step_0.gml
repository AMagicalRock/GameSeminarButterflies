if (flat_on_ground || !instance_exists(obj_player)) exit;

var _p = obj_player;
var _pw = abs(_p.sprite_width) / 2;   // the player's drawn size, assuming a Middle Center origin like the rest of your sprites
var _ph = abs(_p.sprite_height) / 2;

var _overlaps = (_p.x + _pw > art_l && _p.x - _pw < art_r
              && _p.y + _ph > art_t && _p.y - _ph < art_b);
var _behind = (_p.bbox_bottom < sort_line_y);

image_alpha = lerp(image_alpha, (_overlaps && _behind) ? 0.4 : 1, 0.15);