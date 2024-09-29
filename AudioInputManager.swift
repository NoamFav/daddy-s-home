//
//  AudioInputManager.swift
//  daddy's home
//
//Created by Boss on 29/09/2024.
//

import Foundation
import AVFoundation

class AudioInputManager {
    let audioEngine = AVAudioEngine()
    var inputNode: AVAudioInputNode!
    var samplingRate: Double!

    init() {
        inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        samplingRate = format.sampleRate

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            self.processAudio(buffer: buffer)
        }

        do {
            try audioEngine.start()
            print("Audio Engine started")
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func processAudio(buffer: AVAudioPCMBuffer) {
        // To be overridden by subclasses
    }
}
