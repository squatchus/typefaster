//
//  MenuVC.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 29.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {

    @objc var viewModel: MenuVM

    @objc var onLeaderboardPressed: (()->())?
    @objc var onPlayPressed: (()->())?
    @objc var onRatePressed: (()->())?
    @objc var onSetttingsPressed: (()->())?
    
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
    
    @IBOutlet weak var starHeightConstraint: NSLayoutConstraint!
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

    @objc init(viewModel: MenuVM) {
        self.viewModel = viewModel
        super.init(nibName: "MenuVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topMargin.constant = UIScreen.verticalMarginForDevice()
        bottomMargin.constant = UIScreen.verticalMarginForDevice()
        reloadViewModel()
    }
    
    @objc func reloadViewModel() {
        yourSpeedLabel.text = viewModel.bestResultTitle
        signsPerMinLabel.text = viewModel.signsPerMin
        signsPerMinTitleLabel.text = viewModel.signsPerMinTitle
        firstResultLabel.text = viewModel.firstResultTitle
        rankHintLabel.text = viewModel.rankSubtitle

        let starViews = [starView1, starView2, starView3, starView4, starView5]
        let starNames = viewModel.starImageNames()
        for (i, starView) in starViews.enumerated() {
            starView?.image = UIImage(named: starNames[i])
        }

        gameCenterButton.setTitle(viewModel.rankTitle, for: .normal)
        startTypingButton.setTitle(viewModel.typeFasterTitle, for: .normal)
        settingsButton.setTitle(viewModel.settingsTitle, for: .normal)
        rateButton.setTitle(viewModel.rateTitle, for: .normal)

        rateButton.layer.cornerRadius = rateButton.frame.size.height/2.0
        settingsButton.layer.cornerRadius = settingsButton.frame.size.height/2.0
        gameCenterButton.layer.cornerRadius = gameCenterButton.frame.size.height/2.0
        startTypingButton.layer.cornerRadius = startTypingButton.frame.size.height/2.0
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
