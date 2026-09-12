if (!always_on_ground) {
    var _horiz_overlap = (obj_player.bbox_right > bbox_left && obj_player.bbox_left < bbox_right);
    var _vert_overlap = (obj_player.bbox_bottom > bbox_top && obj_player.bbox_top < bbox_bottom);
    var _behind = _horiz_overlap && _vert_overlap && (obj_player.bbox_bottom < bbox_bottom);

    var _target_alpha = _behind ? 0.4 : 1;
    image_alpha = lerp(image_alpha, _target_alpha, 0.15);
}