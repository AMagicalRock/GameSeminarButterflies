if (obj_player.interacting_with == id) {
    draw_ellipse_color(x - highlight_hw, y - highlight_hh, x + highlight_hw, y + highlight_hh, c_white, c_white, false);
}

draw_self();