import numpy as np
import wave
import struct
import os

sample_rate = 44100

def save_wav(filename, audio_data):
    audio_data = np.clip(audio_data, -1.0, 1.0)
    audio_data = (audio_data * 32767).astype(np.int16)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(audio_data.tobytes())

def generate_old_phone_bell():
    t = np.linspace(0, 2.0, int(sample_rate * 2.0), endpoint=False)
    carrier = np.sin(2 * np.pi * 1200 * t) + np.sin(2 * np.pi * 1240 * t)
    carrier = carrier / 2.0
    modulator = np.sign(np.sin(2 * np.pi * 20 * t))
    modulator = (modulator + 1) / 2
    return carrier * modulator * 0.9

def generate_school_bell():
    t = np.linspace(0, 3.0, int(sample_rate * 3.0), endpoint=False)
    carrier = np.sign(np.sin(2 * np.pi * 800 * t)) + 0.5 * np.sign(np.sin(2 * np.pi * 1050 * t))
    carrier = carrier / 1.5
    modulator = np.sign(np.sin(2 * np.pi * 15 * t))
    modulator = (modulator + 1) / 2
    return carrier * modulator * 0.8

def generate_fire_alarm():
    t = np.linspace(0, 3.0, int(sample_rate * 3.0), endpoint=False)
    carrier = np.sin(2 * np.pi * 2800 * t) + 0.3 * np.sin(2 * np.pi * 2850 * t)
    modulator = np.sign(np.sin(2 * np.pi * 3 * t))
    modulator = (modulator + 1) / 2
    return carrier * modulator * 0.9

def generate_loud_chime():
    t1 = np.linspace(0, 1.0, int(sample_rate * 1.0), endpoint=False)
    t2 = np.linspace(0, 1.5, int(sample_rate * 1.5), endpoint=False)
    env1 = np.exp(-4 * t1)
    env2 = np.exp(-3 * t2)
    w1 = np.sin(2 * np.pi * 1200 * t1) * env1
    w2 = np.sin(2 * np.pi * 900 * t2) * env2
    audio = np.concatenate((w1, w2))
    return audio * 0.9

os.makedirs('assets/sounds', exist_ok=True)
os.makedirs('android/app/src/main/res/raw', exist_ok=True)

save_wav('android/app/src/main/res/raw/bel_sekolah.wav', generate_school_bell())
save_wav('assets/sounds/bel_sekolah.wav', generate_school_bell())

save_wav('android/app/src/main/res/raw/bel_telepon.wav', generate_old_phone_bell())
save_wav('assets/sounds/bel_telepon.wav', generate_old_phone_bell())

save_wav('android/app/src/main/res/raw/bel_kebakaran.wav', generate_fire_alarm())
save_wav('assets/sounds/bel_kebakaran.wav', generate_fire_alarm())

save_wav('android/app/src/main/res/raw/bel_chime.wav', generate_loud_chime())
save_wav('assets/sounds/bel_chime.wav', generate_loud_chime())

print("Bells generated successfully.")
