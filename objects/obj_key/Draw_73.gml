for (var i = 0; i < array_length(glints); i++) {
    var _g = glints[i];
    var _f = _g.life / _g.max_life;
    obj_gameManager.draw_star_shape(_g.x, _g.y, _g.size * _f, _g.size * _f * 0.35, 4, _g.angle, _g.color, _f);
}