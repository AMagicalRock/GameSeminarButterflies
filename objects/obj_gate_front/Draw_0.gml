if (!instance_exists(owner) || !owner.is_open) exit;

draw_sprite_ext(owner.bottom_open, 0, owner.x, owner.y, owner.image_xscale, owner.image_yscale, owner.image_angle, c_white, 1);