depth = -15000;   // above everything Y-sorted, which sits at roughly -bbox_bottom
zone = noone;
reveal_speed = 0.015;   // lower = slower fade
revealing = false;
cover_alpha = 1;

// Already revealed on an earlier visit: no blackout at all
if (obj_gameManager.tutorial_revealed) {
    instance_destroy();
    exit;
}