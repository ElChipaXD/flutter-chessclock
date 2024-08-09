import 'package:just_audio/just_audio.dart';

class AudioPlayerHelper {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(String assetPath) async {
    await _audioPlayer.setAsset(assetPath);
    _audioPlayer.play();
  }
}
