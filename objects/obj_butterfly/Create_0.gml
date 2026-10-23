sprite_scale = 1;
image_xscale = sprite_scale;
image_yscale = sprite_scale;

flower_type = 0; // overwritten immediately at spawn time
pause_timer = 0;
target_x = x;
target_y = y;
fly_speed = 0.6;
state = "alive"; // becomes "fading" when its type is no longer wanted
state = "spawning";
flap_speed = random_range(0.85, 1.15);
image_speed = flap_speed;
image_alpha = 0;
depth = -100000;