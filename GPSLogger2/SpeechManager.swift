//
//  SpeechManager.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/29.
//

import Foundation
import AVFoundation


class SpeechManager : NSObject, AVSpeechSynthesizerDelegate {
    
    var speechManager: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var texts: [String] = []
    
    static let shared = SpeechManager()
    
    override init() {
        super.init()
        speechManager.delegate = self
    }
    
    private func decreaseBgmVolume() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("\(error)")
        }
    }
    
    private func resetBgmVolume() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print("\(error)")
        }
    }
    
    func clear() {
        texts.removeAll()
    }
    
    func isSpeaking() -> Bool {
        return speechManager.isSpeaking
    }
    
    func speech() {
        decreaseBgmVolume()
        while texts.count > 0 {
            let text = texts.removeFirst()
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.volume = 1
            utterance.pitchMultiplier = 1.0
            utterance.preUtteranceDelay = 0.2
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.08
            speechManager.speak(utterance)
        }
    }
    
    func speech(_ text: String) {
        push(text)
        speech()
    }
    
    func push(_ text: String) {
        texts.append(text)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 完了時
        if texts.count == 0 {
            resetBgmVolume()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // キャンセル時
        resetBgmVolume()
        clear()
    }
    
    func stop() {
        speechManager.stopSpeaking(at: .immediate)
    }
}
