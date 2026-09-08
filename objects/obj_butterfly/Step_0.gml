if (state == "spawning") {
    image_alpha += 0.02;
    if (image_alpha >= 1) {
        image_alpha = 1;
        state = "alive";
    }
}

if (state == "fading") {
    image_alpha -= 0.02;
    if (image_alpha <= 0) {
        instance_destroy(self);
    }
}

if (state == "alive") {
    if (pause_timer > 0) {
        pause_timer -= 1;
    } else {
        var _dist_to_target = point_distance(x, y, target_x, target_y);

        if (_dist_to_target < 5) {
			var _positions = obj_gameManager.flower_positions_by_type[flower_type];
			var _over_flower = false;

			for (var p = 0; p < array_length(_positions); p++) {
				if (point_distance(x, y, _positions[p].x, _positions[p].y) < 20) {
					_over_flower = true;
					break;
				}
			}

            if (_over_flower && irandom_range(1, 100) <= 20) {
                pause_timer = irandom_range(30, 90); // brief hover, roughly 0.5-1.5s
            }

            target_x = clamp(x + irandom_range(-150, 150), 50, room_width - 50);
            target_y = clamp(y + irandom_range(-150, 150), 50, room_height - 50);
        }

        var _dir = point_direction(x, y, target_x, target_y);
        x += lengthdir_x(fly_speed, _dir);
        y += lengthdir_y(fly_speed, _dir);
    }
}