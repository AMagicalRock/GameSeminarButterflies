function audio_init() {
    global.vol_master = 1;
    global.vol_music = 0.6;
    global.vol_sfx = 0.9;
    global.music_current = -1;   // the music asset playing now, or -1 for silence
    global.music_inst = -1;      // its playing instance
    global.audio_stops = [];     // faded-out tracks waiting to be stopped
    global.sfx_last = {};        // when each sound last played, so identical sounds can't stack
    audio_master_gain(global.vol_master);
}

function apply_volumes() {
    audio_master_gain(global.vol_master);
    if (global.music_inst != -1 && audio_is_playing(global.music_inst)) {
        audio_sound_gain(global.music_inst, global.vol_music, 0);
    }
}

// The low-level player: one-shot sound with a little pitch variation and a repeat limiter
function play_sfx(_snd, _gain = 1, _pitch_var = 0.08, _min_gap = 40) {
    if (is_undefined(_snd) || _snd == -1 || !audio_exists(_snd)) return -1;

    var _key = string(_snd);
    if (variable_struct_exists(global.sfx_last, _key)) {
        if (current_time - variable_struct_get(global.sfx_last, _key) < _min_gap) return -1;
    }
    variable_struct_set(global.sfx_last, _key, current_time);

    var _inst = audio_play_sound(_snd, 10, false);
    audio_sound_gain(_inst, _gain * global.vol_sfx, 0);
    audio_sound_pitch(_inst, 1 + random_range(-_pitch_var, _pitch_var));
    return _inst;
}

// What the rest of the game calls: a sound by its name in the manager's table
function sfx_play(_name, _gain = 1, _pitch_var = 0.08) {
    var _snd = variable_struct_get(obj_gameManager.sfx, _name);
    if (is_undefined(_snd)) {
        show_debug_message("sfx_play: no sound called '" + _name + "'");
        return -1;
    }
    return play_sfx(_snd, _gain, _pitch_var);
}

// Looping sounds (the lawnmower, ambience). Keep the returned id so you can stop it with audio_stop_sound
function sfx_loop(_name, _gain = 1) {
    var _snd = variable_struct_get(obj_gameManager.sfx, _name);
    if (is_undefined(_snd) || _snd == -1 || !audio_exists(_snd)) return -1;
    var _inst = audio_play_sound(_snd, 10, true);
    audio_sound_gain(_inst, _gain * global.vol_sfx, 0);
    return _inst;
}

// Music crossfades. Asking for the track that's already playing does nothing, so it carries on across rooms
function play_music(_snd, _fade = 1500) {
    if (_snd == global.music_current) return;
    global.music_current = _snd;

    if (global.music_inst != -1) {
        audio_sound_gain(global.music_inst, 0, _fade);
        array_push(global.audio_stops, { inst: global.music_inst, at: current_time + _fade + 100 });
        global.music_inst = -1;
    }

    if (_snd != -1 && audio_exists(_snd)) {
        global.music_inst = audio_play_sound(_snd, 100, true);   // high priority, so effects never cut it off
        audio_sound_gain(global.music_inst, 0, 0);
        audio_sound_gain(global.music_inst, global.vol_music, _fade);
    }
}