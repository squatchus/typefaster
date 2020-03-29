//
//  MenuVC.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 29.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {

    @objc var onViewWillAppear: (()->())!
    @objc var onLeaderboardPressed: (()->())!
    @objc var onPlayPressed: (()->())!
    @objc var onRatePressed: (()->())!
    @objc var onSetttingsPressed: (()->())!
    
    @objc var viewModel: TFMenuVM!
    
    @IBOutlet weak var yourSpeedLabel: UILabel!
    @IBOutlet weak var signsPerMinLabel: UILabel!
    @IBOutlet weak var signsPerMinTitleLabel: UILabel!
    @IBOutlet weak var firstResultLabel: UILabel!

    @IBOutlet weak var rankHintLabel: UILabel!

    @IBOutlet weak var starView1: UIImageView!
    @IBOutlet weak var starView2: UIImageView!
    @IBOutlet weak var starView3: UIImageView!
    @IBOutlet weak var starView4: UIImageView!
    @IBOutlet weak var starView5: UIImageView!
    @IBOutlet weak var starHeightConstraint: NSLayoutConstraint!;
    @IBOutlet weak var starWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leaderboardWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rankTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var rankBottomSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!

    @IBOutlet weak var startTypingButton: UIButton!
    @IBOutlet weak var gameCenterButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onViewWillAppear?()
        self.topMargin.constant = UIScreen.verticalMarginForDevice()
        self.bottomMargin.constant = UIScreen.verticalMarginForDevice();
    }
    
    @objc func reloadViewModel() {
        self.updateWith(viewModel: self.viewModel)
    }

    @objc func updateWith(viewModel: TFMenuVM) {
        self.viewModel = viewModel;
        
        self.yourSpeedLabel.text = self.viewModel.bestResultTitle;
        self.signsPerMinLabel.text = self.viewModel.signsPerMin;
        self.signsPerMinTitleLabel.text = self.viewModel.signsPerMinTitle;
        self.firstResultLabel.text = self.viewModel.firstResultTitle;
        
        var numberOfFullStars = self.viewModel.stars
        let halfStar = (self.viewModel.stars-numberOfFullStars > 0)
        let stars = [self.starView1, self.starView2, self.starView3, self.starView4, self.starView5]
        for starView in stars {
            if numberOfFullStars > 0 {
                starView?.image = UIImage(named: "star_gold.png")
            } else if numberOfFullStars == 0 && halfStar {
                starView?.image = UIImage(named: "star_goldgray.png")
            } else {
                starView?.image = UIImage(named: "star_gray.png")
            }
            numberOfFullStars -= 1;
        }
        
        self.gameCenterButton.setTitle(self.viewModel.rankTitle, for: .normal)
        self.rankHintLabel.text = self.viewModel.rankSubtitle;

        self.startTypingButton.setTitle(self.viewModel.typeFasterTitle, for: .normal)
        self.settingsButton.setTitle(self.viewModel.settingsTitle, for: .normal)
        self.rateButton.setTitle(self.viewModel.rateTitle, for: .normal)

        self.rateButton.layer.cornerRadius = self.rateButton.frame.size.height/2.0;
        self.settingsButton.layer.cornerRadius = self.settingsButton.frame.size.height/2.0;
        self.gameCenterButton.layer.cornerRadius = self.gameCenterButton.frame.size.height/2.0;
        self.startTypingButton.layer.cornerRadius = self.startTypingButton.frame.size.height/2.0;
    }
    
    // MARK: Actions
    
    @IBAction func onRateButtonPressed(_ sender: Any) {
        onRatePressed?()
    }
    @IBAction func onGameCenterButtonPressed(_ sender: Any) {
        onLeaderboardPressed?()
    }
    @IBAction func onSettingsButtonPressed(_ sender: Any) {
        onSetttingsPressed?()
    }
    @IBAction func onPlayButtonPressed(_ sender: Any) {
        onPlayPressed?()
    }
}
