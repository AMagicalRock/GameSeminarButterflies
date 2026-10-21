// One line per door type: [closed sprite, open sprite]. Add a line whenever the artist delivers a new door.
function get_door_pair(_sprite) {
    var _pairs = [
        [spr_door_1_close, spr_door_1_open],
        [spr_door_2_close, spr_door_2_open],
        [spr_door_3_close, spr_door_3_open]
    ];

    for (var i = 0; i < array_length(_pairs); i++) {
        if (_pairs[i][0] == _sprite || _pairs[i][1] == _sprite) return _pairs[i];
    }
    return undefined;
}