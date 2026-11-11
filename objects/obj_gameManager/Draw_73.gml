for (var i = 0; i < array_length(grass_bits); i++) {
    var _g = grass_bits[i];
    var _f = _g.life / _g.max_life;
    var _alpha = clamp((1 - _f) / 0.4, 0, 1);   // solid for the first 60% of its life, then fades
    var _sc = (grass_bit_size * _g.size) / sprite_get_width(particle_grass);
    draw_sprite_ext(particle_grass, _g.frame, _g.x, _g.y - _g.z, _sc, _sc, _g.angle, c_white, _alpha);
}