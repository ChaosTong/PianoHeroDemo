//
//  AudioEngine.swift
//  PianoHero
//
//  Created by ChaosTong on 2023/7/7.
//

import Foundation
import AVFoundation

class AudioEngine {
    private let engine = AVAudioEngine()
    private(set) var sampler = AVAudioUnitSampler()
    private let reverb = AVAudioUnitReverb()
    private let delay = AVAudioUnitDelay()

    func start() {
//        engine.attach(sampler)
//        engine.attach(reverb)
//        engine.attach(delay)
//
//        engine.connect(sampler, to: delay, format: nil)
//        engine.connect(delay, to: reverb, format: nil)
//        engine.connect(reverb, to: engine.mainMixerNode, format: nil)
        
        engine.attach(sampler)
//        engine.attach(reverb)
//        engine.attach(delay)

//        engine.connect(sampler, to: delay, format: nil)
//        engine.connect(sampler, to: reverb, format: nil)
//        engine.connect(delay, to: reverb, format: nil)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)

        // Reverb
//        reverb.loadFactoryPreset(.mediumHall)
//        reverb.wetDryMix = 30.0

        // Delay
        delay.wetDryMix = 15.0
        delay.delayTime = 0.50
        delay.feedback = 75.0
        delay.lowPassCutoff = 16000.0

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("Error: AudioSession couldn't set category")
        }

        do {
            try audioSession.setActive(true)
        } catch {
            print("Error: AudioSession couldn't set category active")
        }

        if engine.isRunning {
            print("Audio engine already running")
            return
        }

        do {
            try engine.start()
            print("Audio engine started")
        } catch {
            print("Error: couldn't start audio engine")
            return
        }
    }
}
