if (pop_timer > 0) {
    pop_timer += 1;
    var _t = min(pop_timer / 25, 1);
    var _u = _t - 1;
    var _s = 1 + 2.70158 * _u * _u * _u + 1.70158 * _u * _u;
    image_xscale = base_scale * _s;
    image_yscale = base_scale * _s;
    if (pop_timer >= 25) {
        pop_timer = 0;
        image_xscale = base_scale;
        image_yscale = base_scale;
    }
}