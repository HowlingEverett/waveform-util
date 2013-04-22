# Waveform Utils

This is a tiny wrapper around ffprobe and pcm.js to do some handy things with waveforms, particularly if you plan on rendering them in-browser (and can't depend on the WebAudio API being present).

I built this because I needed a way to generate representative peak arrays of arbitrary widths for audio files, to be later rendered into a client-side `<canvas>` element.

## Installing
Grab it via npm:

`npm install waveform-util`

Note that since pcm.js depends on ffmpeg and ffprobe.js on ffprobe, you'll need to have these installed on your system. If you're on OS X, like I am:

`brew install ffprobe ffmpeg`

## Examples

Currently there are methods for generating peak arrays of various sizes (no JSON stream support yet, send ye your pull requests), and for parsing useful audio data out of audio files. 

```
waveform = require('waveform-util')

// Generate peaks from a given audio file path. All parameters are required:
// waveform.generate_peaks(audio_path, target_width, duration, bit_rate, channels, callback);
// Parameters:
//   - audio_path: relative or absolute path to an audio file of *nearly* any type*
//   - target_width: how many entries you want in the output peaks array.
//		     This is useful, for example, if you want to draw a
//		     200px-wide waveform: each peak becomes a line 1px wide.
//   - duration: Duration of the audio in (fractional) seconds
//   - bit_rate: Bit rate of the audio file
//   - channels: Number of channels in the audio (e.g. 1 for mono, 2 for stereo)
//   - callback: callback function with `err` and `peaks_obj` as parameters
//
// The peaks_obj parameter in the callback will be an object with the format
// { peaks: [], max_peak: Number }
waveform.generate_peaks('test.m4a', 200, 31.05, 44100, 2, 
  function (err, peaks_obj) {
    console.log(peaks_obj.peaks) // Array of peak values e.g. [0.75, 0.2, 0.1111,...]
    console.log(peaks_obj.max_peak) // Max peak in the signal: useful for scaling the peak values when drawing them
  }
)
```

