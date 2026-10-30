sprite_scale = 0.6; // bigger than 1 = larger than original size
image_xscale = sprite_scale;
image_yscale = sprite_scale;

mounted = false;
move_speed_bonus = 0.8;
side_offset = 75;  // distance when facing left/right
fb_offset = 50;    // distance when facing front/back (and diagonals)

shake_x = 0;
shake_y = 0;
shake_strength = 0;       // eases up when mounted and down when not, so it starts and stops smoothly
shake_amount = 1.5;       // the dial: how far the shake moves the sprite, in pixels
player_last_x = 0;
player_last_y = 0;