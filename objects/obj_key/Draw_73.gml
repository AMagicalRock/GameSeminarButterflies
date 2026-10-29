for (var i = 0; i < array_length(glints); i++) {
    var _g = glints[i];
    var _f = _g.life / _g.max_life;
    var _gs = (_g.size * 2 * _f * obj_gameManager.sparkle_size_mult) / sprite_get_width(_g.sprite);
    draw_sprite_ext(_g.sprite, 0, _g.x, _g.y, _gs, _gs, _g.angle, c_white, _f);
}