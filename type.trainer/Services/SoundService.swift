//
//  SoundService.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit
import AVFoundation

enum Sound: Int {
    case keyboardClick, buttonClick, mistake, newRecord, newRank
}

fileprivate extension AVAudioPlayer {
    static func playerFor(filename: String, volume: Float = 1.0) -> AVAudioPlayer {
        let path = Bundle.main.path(forResource: filename, ofType: nil)
        let url = URL(fileURLWithPath: path!)
        let player = try! AVAudioPlayer(contentsOf: url)
        player.volume = volume
        player.prepareToPlay()
        return player
    }
}

class SoundService {

    let keyClickPlayer: AVAudioPlayer
    let buttonClickPlayer: AVAudioPlayer
    let mistakePlayer: AVAudioPlayer
    let newRecordPlayer: AVAudioPlayer
    let newRankPlayer: AVAudioPlayer
    
    init() {
        keyClickPlayer = AVAudioPlayer.playerFor(filename: "Tock.caf", volume: 0.1)
        buttonClickPlayer = AVAudioPlayer.playerFor(filename: "click.wav")
        mistakePlayer = AVAudioPlayer.playerFor(filename: "error.wav")
        newRecordPlayer = AVAudioPlayer.playerFor(filename: "new_result.wav")
        newRankPlayer = AVAudioPlayer.playerFor(filename: "new_rank.wav")
    }
    
    func play(_ sound: Sound) {
        let soundPlayer = player(for: sound)
        if soundPlayer.isPlaying {
            soundPlayer.currentTime = 0
        } else {
            soundPlayer.play()
        }
    }
    
    fileprivate func player(for sound: Sound) -> AVAudioPlayer {
        switch sound {
        case .buttonClick:
            return buttonClickPlayer
        case .keyboardClick:
            return keyClickPlayer
        case .mistake:
            return mistakePlayer
        case .newRecord:
            return newRecordPlayer
        case .newRank:
            return newRankPlayer
        }
    }
    
}
