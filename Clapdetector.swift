//
//  Clapdetector.swift
//  daddy's home
//
//  Created by Boss on 29/09/2024.
//

import Foundation
import AVFoundation
import AppKit
import Accelerate

class ClapDetector: AudioInputManager {
    var lastClapTime: TimeInterval = 0
    let clapThreshold: Float = 0.4 // Adjust based on testing
    let clapInterval: TimeInterval = 1.0 // Max time between claps for double clap
    var clapCount = 0

    override init() {
        super.init()
        print("ClapDetector initialized and listening for claps...")
    }

    override func processAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        analyzeAudioData(samples: channelDataArray)
    }

    func analyzeAudioData(samples: [Float]) {
        let rms = calculateRMS(samples: samples)
        if rms > clapThreshold {
            handlePotentialClap()
        }
    }

    func calculateRMS(samples: [Float]) -> Float {
        // Updated RMS calculation using modern vDSP API
        var rms: Float = 0.0
        vDSP_rmsqv(samples, 1, &rms, UInt(samples.count))
        return rms
    }

    func handlePotentialClap() {
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastClapTime < clapInterval {
            clapCount += 1
            if clapCount == 2 {
                performAction()
                clapCount = 0
            }
        } else {
            clapCount = 1
        }
        lastClapTime = currentTime
    }

    func performAction() {
        print("Double clap detected!")
        wakeDisplay()
    }

    func wakeDisplay() {
        // Simulate a key press to wake the display
        let source = CGEventSource(stateID: .combinedSessionState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x31, keyDown: true) // Space key
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x31, keyDown: false)
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
