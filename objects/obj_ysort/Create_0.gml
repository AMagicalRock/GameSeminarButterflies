if (!variable_instance_exists(id, "always_on_ground")) {
    always_on_ground = false;
}

if (!always_on_ground) {
    depth = -bbox_bottom;
}