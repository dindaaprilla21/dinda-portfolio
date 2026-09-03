import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void saveWav(String filename, List<double> audioData, int sampleRate) {
  final file = File(filename);
  
  final intData = Int16List(audioData.length);
  for (var i = 0; i < audioData.length; i++) {
    var val = (audioData[i] * 32767).round();
    if (val > 32767) val = 32767;
    if (val < -32768) val = -32768;
    intData[i] = val;
  }
  
  final byteData = intData.buffer.asUint8List();
  
  final bytes = BytesBuilder();
  bytes.add('RIFF'.codeUnits);
  final fileSize = 36 + byteData.length;
  bytes.add([fileSize & 0xff, (fileSize >> 8) & 0xff, (fileSize >> 16) & 0xff, (fileSize >> 24) & 0xff]);
  bytes.add('WAVE'.codeUnits);
  
  bytes.add('fmt '.codeUnits);
  bytes.add([16, 0, 0, 0]); 
  bytes.add([1, 0]); 
  bytes.add([1, 0]); 
  bytes.add([sampleRate & 0xff, (sampleRate >> 8) & 0xff, (sampleRate >> 16) & 0xff, (sampleRate >> 24) & 0xff]);
  
  final byteRate = sampleRate * 1 * 2;
  bytes.add([byteRate & 0xff, (byteRate >> 8) & 0xff, (byteRate >> 16) & 0xff, (byteRate >> 24) & 0xff]);
  
  final blockAlign = 1 * 2;
  bytes.add([blockAlign & 0xff, (blockAlign >> 8) & 0xff]);
  bytes.add([16, 0]); 
  
  bytes.add('data'.codeUnits);
  bytes.add([byteData.length & 0xff, (byteData.length >> 8) & 0xff, (byteData.length >> 16) & 0xff, (byteData.length >> 24) & 0xff]);
  bytes.add(byteData.toList());
  
  file.writeAsBytesSync(bytes.toBytes());
}

List<double> generateSchoolBell() {
  final sampleRate = 44100;
  final length = sampleRate * 3;
  final data = List<double>.filled(length, 0);
  for (var i = 0; i < length; i++) {
    final t = i / sampleRate;
    final carrier1 = sin(2 * pi * 800 * t).sign;
    final carrier2 = sin(2 * pi * 1050 * t).sign * 0.5;
    var carrier = (carrier1 + carrier2) / 1.5;
    
    final modulator = (sin(2 * pi * 15 * t).sign + 1) / 2;
    data[i] = carrier * modulator * 0.8;
  }
  return data;
}

List<double> generateAlarmClock() {
  final sampleRate = 44100;
  final length = sampleRate * 2;
  final data = List<double>.filled(length, 0);
  for (var i = 0; i < length; i++) {
    final t = i / sampleRate;
    final carrier1 = sin(2 * pi * 1200 * t);
    final carrier2 = sin(2 * pi * 1240 * t);
    var carrier = (carrier1 + carrier2) / 2.0;    
    final modulator = (sin(2 * pi * 20 * t).sign + 1) / 2;
    data[i] = carrier * modulator * 0.9;
  }
  return data;
}

List<double> generateFireAlarm() {
  final sampleRate = 44100;
  final length = sampleRate * 3;
  final data = List<double>.filled(length, 0);
  for (var i = 0; i < length; i++) {
    final t = i / sampleRate;
    final carrier = sin(2 * pi * 2800 * t) + 0.3 * sin(2 * pi * 2850 * t);
    final modulator = (sin(2 * pi * 3 * t).sign + 1) / 2;
    data[i] = carrier * modulator * 0.9;
  }
  return data;
}

List<double> generateLoudChime() {
  final sampleRate = 44100;
  final length1 = (sampleRate * 1.0).toInt();
  final length2 = (sampleRate * 1.5).toInt();
  final totalLength = length1 + length2;
  final data = List<double>.filled(totalLength, 0);
  
  for (var i = 0; i < length1; i++) {
    final t = i / sampleRate;
    final env = exp(-4 * t);
    data[i] = sin(2 * pi * 1200 * t) * env * 0.9;
  }
  for (var i = 0; i < length2; i++) {
    final t = i / sampleRate;
    final env = exp(-3 * t);
    data[length1 + i] = sin(2 * pi * 900 * t) * env * 0.9;
  }
  return data;
}

List<double> generateEmergencyBell() {
  final sampleRate = 44100;
  final length = sampleRate * 3;
  final data = List<double>.filled(length, 0);
  for (var i = 0; i < length; i++) {
    final t = i / sampleRate;
    // Fast pulsing loud frequency
    final carrier = sin(2 * pi * 1500 * t);
    final modulator = (sin(2 * pi * 8 * t).sign + 1) / 2;
    data[i] = carrier * modulator * 0.95;
  }
  return data;
}

void main() {
  Directory('assets/sounds').createSync(recursive: true);
  Directory('android/app/src/main/res/raw').createSync(recursive: true);

  saveWav('android/app/src/main/res/raw/bel_sekolah.wav', generateSchoolBell(), 44100);
  saveWav('assets/sounds/bel_sekolah.wav', generateSchoolBell(), 44100);

  saveWav('android/app/src/main/res/raw/bel_telepon.wav', generateAlarmClock(), 44100);
  saveWav('assets/sounds/bel_telepon.wav', generateAlarmClock(), 44100);

  saveWav('android/app/src/main/res/raw/bel_kebakaran.wav', generateFireAlarm(), 44100);
  saveWav('assets/sounds/bel_kebakaran.wav', generateFireAlarm(), 44100);

  saveWav('android/app/src/main/res/raw/bel_chime.wav', generateLoudChime(), 44100);
  saveWav('assets/sounds/bel_chime.wav', generateLoudChime(), 44100);

  saveWav('android/app/src/main/res/raw/bel_darurat.wav', generateEmergencyBell(), 44100);
  saveWav('assets/sounds/bel_darurat.wav', generateEmergencyBell(), 44100);

  // ignore: avoid_print
  print("Bells generated successfully.");
}
