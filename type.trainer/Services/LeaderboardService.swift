//
//  LeaderboardService.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit
import GameKit

class LeaderboardService: NSObject, GKGameCenterControllerDelegate {

    @objc var onScoreReceived: ((_ score: Int)->())?
    @objc var onShouldPresentAuthVC: ((_ authVC: UIViewController)->())?
    @objc var onShouldDismissVC: ((_ vc: UIViewController)->())?
    
    var leaderboardId: String?
    var gameCenterEnabled: Bool = false
    var score: Int = 0

    @objc func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] (vc : UIViewController?, error : Error?) -> Void in
            if let authVC = vc { // not authenticated
                self?.onShouldPresentAuthVC?(authVC)
            } else if GKLocalPlayer.local.isAuthenticated {
                self?.gameCenterEnabled = true
                GKLocalPlayer.local.loadDefaultLeaderboardIdentifier { (id, error) in
                    if error != nil { return }
                    self?.leaderboardId = id;
                    let leaderboard = GKLeaderboard()
                    leaderboard.identifier = id;
                    leaderboard.loadScores { (scores, error) in
                        if error != nil { return }
                        let playerScore = Int(leaderboard.localPlayerScore!.value)
                        self?.score = playerScore
                        self?.onScoreReceived?(playerScore)
                    }
                }
            }
        }
    }
    
    @objc var canShowLeaderboard: Bool {
        if let _ = leaderboardId, gameCenterEnabled {
            return true
        } else {
            return false
        }
    }
    
    @objc var controller: UIViewController {
        let leaderboardVC = GKGameCenterViewController()
        leaderboardVC.gameCenterDelegate = self
        leaderboardVC.viewState = .leaderboards
        leaderboardVC.leaderboardIdentifier = self.leaderboardId
        return leaderboardVC
    }
    
    @objc func report(score: Int) {
        if let id = leaderboardId, gameCenterEnabled {
            let scoreToReport = GKScore(leaderboardIdentifier: id)
            scoreToReport.value = Int64(score)
            GKScore.report([scoreToReport])
        }
    }

    // MARK: - GKGameCenterControllerDelegate

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        onShouldDismissVC?(gameCenterViewController)
    }
        
}
