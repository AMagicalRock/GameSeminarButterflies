if (place_meeting(x, y, obj_player)) {
    with (obj_shed_cover) {
        if (!revealing) {
            revealing = true;
            obj_gameManager.tutorial_revealed = true;
        }
    }
}