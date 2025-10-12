import qs.modules.bar
import qs.modules.services
import qs.modules.components

StyledSlider {
    // wavy: true
    value: Audio.sink?.audio?.volume ?? 0

    onValueChanged: {
        if (Audio.sink?.audio) {
            Audio.sink.audio.volume = value;
        }
    }
}
