//
//  ResultsVC.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 31.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class ResultsVC: UIViewController {

    var onViewWillAppear: (()->())?
    var onSharePressed: ((_ text: String)->())?
    var onContinuePressed: (()->())?
    var onSettingsPressed: (()->())?
    var onRatePressed: (()->())?
    
    var viewModel: ResultsVM
    
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var signsPerMinLabel: UILabel!
    @IBOutlet weak var signsPerMinTitleLabel: UILabel!
    @IBOutlet weak var mistakesPercentLabel: UILabel!
    @IBOutlet weak var mistakesPercentTitleLabel: UILabel!
    @IBOutlet weak var bestResultLabel: UILabel!
    @IBOutlet weak var bestResultTitleLabel: UILabel!
    @IBOutlet weak var starView1: UIImageView!
    @IBOutlet weak var starView2: UIImageView!
    @IBOutlet weak var starView3: UIImageView!
    @IBOutlet weak var starView4: UIImageView!
    @IBOutlet weak var starView5: UIImageView!
    @IBOutlet weak var starHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var starWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    init(viewModel: ResultsVM) {
        self.viewModel = viewModel
        super.init(nibName: "ResultsVC", bundle: nil)
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
    
    func reloadViewModel() {
        resultTitleLabel.text = viewModel.data.resultTitle
        bestResultLabel.text = viewModel.data.bestResult
        bestResultTitleLabel.text = viewModel.data.bestResultTitle
        signsPerMinLabel.text = viewModel.data.signsPerMin
        signsPerMinTitleLabel.text = viewModel.data.signsPerMinTitle
        mistakesPercentLabel.text = viewModel.data.mistakes
        mistakesPercentTitleLabel.text = viewModel.data.mistakesTitle
        
        let starViews = [starView1, starView2, starView3, starView4, starView5]
        let starNames = viewModel.data.starImageNames
        for (i, starView) in starViews.enumerated() {
            starView?.image = UIImage(named: starNames[i])
        }
        
        textLabel.text = viewModel.data.text
        authorLabel.text = viewModel.data.author
        
        continueButton.setTitle(viewModel.data.continueTitle, for: .normal)
        settingsButton.setTitle(viewModel.data.settingsTitle, for: .normal)
        rateButton.setTitle(viewModel.data.rateTitle, for: .normal)
        
        shareButton.layer.cornerRadius = shareButton.frame.size.height/2.0
        continueButton.layer.cornerRadius = continueButton.frame.size.height/2.0
        rateButton.layer.cornerRadius = rateButton.frame.size.height/2.0
        settingsButton.layer.cornerRadius = settingsButton.frame.size.height/2.0
    }

    @IBAction func onShareButtonPressed(sender: UIButton) {
        onSharePressed?(viewModel.data.text)
    }

    @IBAction func onRateButtonPressed(sender: UIButton) {
        onRatePressed?()
    }

    @IBAction func onContinueButtonPressed(sender: UIButton) {
        onContinuePressed?()
    }

    @IBAction func onSettingsButtonPressed(sender: UIButton) {
        onSettingsPressed?()
    }
    
}
