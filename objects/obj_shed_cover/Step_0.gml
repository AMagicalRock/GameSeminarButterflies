// Looked up here, not in Create, so the order instances are created in can't break it
if (zone == noone) zone = instance_find(obj_shed_zone, 0);

if (revealing) {
    cover_alpha = max(cover_alpha - reveal_speed, 0);
    if (cover_alpha <= 0) instance_destroy();
}