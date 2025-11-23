//
//  AudioService.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/22/25.
//

import Foundation
import AVFoundation
internal import Combine

final class AudioService:NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    @Published var isRinging: Bool = false
    
    static let shared = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
        
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            print("Audio session is configured for playing audio")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func loadSound(soundName:String){
        
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            
            print("Error loading '\(soundName).mp3'. Falling back to default sound")
            
            //If user selected alarm is not found, fallback to default alarm.
            
            if soundName != "india" {
                
                if Bundle.main.url(forResource: "india", withExtension: "mp3") != nil {
                    
                    return loadSound(soundName: "india")
                }
            }
            print("Default sound not found")
            return
        }
        
        do {
            //Initialize audio player
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.delegate = self
            
            //Set to play in loop, till action is taken. Snooze/Dismiss
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print(" Error initializing audio player: \(error.localizedDescription)")
            
        }
    }
    
    
    func startAlarm(soundName: String) {
        
        //Stop existing alarm if any
        stopAlarm()
        
        loadSound(soundName: soundName)
        
        guard let player = audioPlayer else {
            print("Cannot start alarm")
            return
        }
        
        //Start playing alarm
        player.play()
        self.isRinging = true
        print("Alarm \(soundName) is playing")
    }
    
    func stopAlarm() {
        
        guard let player = audioPlayer, player.isPlaying else {
            
            print("Alarm is not playing currently")
            return
        }
        
        player.stop()
        self.isRinging = false
        audioPlayer = nil
        
        print("Stopped playing alarm")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        print(flag ? "Audio player finished playing" : "Audio player finished playing with error")
    }
}
