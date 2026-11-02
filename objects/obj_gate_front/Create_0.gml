refresh = function() {
    var _spr = owner.bottom_open;
    var _base = owner.y + (sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * owner.base_yscale;
    depth = -(_base + owner.front_offset_y);
};
refresh();