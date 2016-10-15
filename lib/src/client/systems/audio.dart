part of client;

class MusicPlayerSystem extends VoidEntitySystem {
  AudioBuffer audioBuffer;
  Uint8List beatByteFrequencyData = new Uint8List(32);
  double beatFactor = 1.0;

  static AudioBufferSourceNode source;
  static AnalyserNode beatAnalyser;
  MusicPlayerSystem(this.audioBuffer);

  @override
  void initialize() {
    if (source == null) {
      var ctx = new AudioContext();
      source = ctx.createBufferSource();
      source.buffer = audioBuffer;
      source.connectNode(ctx.destination);

      beatAnalyser = ctx.createAnalyser();
      beatAnalyser.fftSize = beatByteFrequencyData.length * 2;
      source.connectNode(beatAnalyser);

      source.loop = true;
      source.start(0);
    }
  }

  @override
  void processSystem() {
    beatAnalyser.getByteFrequencyData(beatByteFrequencyData);

    beatFactor = 1.0 +
        beatByteFrequencyData.reduce((value, element) => value + element) /
            beatByteFrequencyData.length /
            1000.0;
    print(beatFactor);
  }
}
