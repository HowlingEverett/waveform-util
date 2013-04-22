should = require('chai').should()
waveform = require '../lib/waveform'

describe "Waveform utilties", ->
  
  describe "waveform peaks generator", ->
    it "should generate an array of peaks roughly equivalent to the requested width", 
    (done) ->
      audio_path = "test/test.m4a"
      waveform.generate_peaks audio_path, 200, 31.068299, 44100, 2, 
      (err, peaks_obj) ->
        should.not.exist err
        should.exist peaks_obj
        peaks_obj.should.have.ownProperty 'peaks'
        peaks_obj.peaks.should.be.instanceof Array
        peaks_obj.peaks.length.should.be.at.most 200
        peaks_obj.peaks.length.should.be.above 190
        done()

    it "should provide a max peak value (the largest peak in the array)",
    (done) ->
      audio_path = "test/test.m4a"
      waveform.generate_peaks audio_path, 200, 31.068299, 44100, 2, 
      (err, peaks_obj) ->
        should.not.exist err
        peaks_obj.should.have.ownProperty 'max_peak'
        isNaN(Number(peaks_obj.max_peak)).should.be.false
        for peak in peaks_obj.peaks
          if peak > peaks_obj.max_peak
            throw new Error "Max peak value #{peaks_obj.max_peak} is 
                             less than peak #{peak}"
        done()


  describe "audio data extractor", ->
    it "should extract useful audio data from a given audio file", (done) ->
      valid_filepath = "test/test.m4a"
      waveform.audio_data valid_filepath, (err, audio_data) ->
        should.not.exist err
        should.exist audio_data
        audio_data.sample_rate.should.eql 44100
        audio_data.channels.should.eql 2
        audio_data.duration.should.eql 31.068299
        audio_data.format.should.eql "mov,mp4,m4a,3gp,3g2,mj2"
        audio_data.bit_rate.should.eql 130654
        done()

    it "should return an error if the file can't be opened", (done) ->
      invalid_filepath = 'test/what.wav'
      waveform.audio_data invalid_filepath, (err, audio_data) ->
        should.exist err
        err.message.should.eql "audio_path must be to a valid audio file."
        done()

    it "should error if the file contains no valid streams", (done) ->
      invalid_audio = 'test/mocha.opts'
      waveform.audio_data invalid_audio, (err, audio_data) ->
        should.exist err
        done()
