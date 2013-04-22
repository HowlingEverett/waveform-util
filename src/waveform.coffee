###
Waveform.coffee - some basic utiltiy functions for working with audio files 
and waveform data. At the moment, this module has functions for extracting
peak data from audio files (in the form of peak arrays, useful)
###

pcm = require 'pcm'; ffprobe = require 'node-ffprobe'
fs = require 'fs'; path = require 'path'

###
Generates a peaks object from a given audio file in the format:
{
  peaks: [Number,...]
  max_peak: Number
}
This is useful when dynamically drawing waveforms, for example, in a HTML
canvas object. The peaks are unitless, and should be scaled to the height of
the element into which you're drawing them. Max_peak is helpful for this.

You should get a peaks array with approximately as many entries as your 
specified output_width (there may be slightly fewer, or fewer if the file is
very short). The idea here is that you draw a waveform by drawing a 1px wide
line for each peak in the array.
###
generate_peaks = (audio_path, output_width, duration, sample_rate, channels, cb) ->
  if arguments.length isnt 6
    throw new Error "Invalid arguments supplied to generate_peaks. Should be
    [audio_path, output_width, duration, sample_rate, channels, cb] but was
    #{arguments}"

  audio_path = path.resolve audio_path
  unless fs.existsSync audio_path
    throw new Error "Audio path must be to a valid audio file."

  samples_per_peak = Math.round(duration * sample_rate / output_width) * channels
  current_max = 0 # Highest value seen for the current round
  total_max = 0 # Highest value seen in the input
  peaks = []
  peak_index = 0 # Current index into the peak array
  sample_index = 0 # Current sample index in the current round

  pcm.getPcmData(audio_path 
    {stereo: channels is 2, sample_rate: sample_rate}
    (sample, channel) ->
      sample = Math.abs sample
      current_max = sample if sample > current_max

      # Store a peak value once we've examined every sample
      # in this round of peaks
      if ++sample_index >= samples_per_peak
        store_peak()
    (err, output) ->
      return cb err if err

      # Store final peak value if needed
      if sample_index > 0 and peak_index < peaks.length
        store_peak()

      cb null, {peaks: peaks, max_peak: total_max}
  )

  store_peak = ->
    if current_max > 0
      current_max = alt_log_meter coefficient_to_db current_max
    else
      current_max = -alt_log_meter coefficient_to_db current_max
    peaks[peak_index++] = current_max

    if current_max > total_max
      total_max = current_max

    current_max = 0
    sample_index = 0

  log_10 = (arg) ->
    Math.log(arg) / Math.LN10
  
  log_meter = (power, lower_db, upper_db, non_linearity) ->
    if power < lower_db
      0
    else
      Math.pow((power - lower_db) / (upper_db - lower_db), non_linearity)
  
  alt_log_meter = (power) ->
    log_meter power, -192.0, 0.0, 8.0
    
  coefficient_to_db = (coeff) ->
    20.0 * log_10 coeff

###
Extracts useful audio data from a given path to an audio file, handy when
doing conversion or drawing waveforms. We provide this a separate function
since you'll probably want to save some processing time by doing this once
for each audio file and storing the output (whereas generate waveform may
be called lots of times to render the waveform at different widths/zoom levels
).
###
audio_data = (audio_path, cb) ->
  audio_path = path.resolve audio_path
  if not audio_path? or not fs.existsSync audio_path
    return cb new Error "audio_path must be to a valid audio file."

  ffprobe audio_path, (err, probeData) ->
    return cb err if err
    if not probeData.streams? or probeData.streams.length < 1
      return cb new Error "File didn't contain any valid audio streams."
    stream = probeData.streams[0]
    cb null, {
      sample_rate: stream.sample_rate
      channels: stream.channels
      duration: probeData.format.duration
      format: probeData.format.format_name
      bit_rate: probeData.format.bit_rate
    }

module.exports = { generate_peaks, audio_data }