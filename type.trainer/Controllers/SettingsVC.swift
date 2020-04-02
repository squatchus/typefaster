//
//  SettingsVC.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 30.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    var viewModel: SettingsVM
    
    var onViewWillAppear: (()->())?
    var onNotificationsSettingChanged: ((_ enabled: Bool)->())?
    var onCategorySettingChanged: (()->())?
    var onDonePressed: (()->())?

    @IBOutlet weak var doneWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var settingsTitleLabel: UILabel!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var strictTypingTitleLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationDescriptionLabel: UILabel!
    @IBOutlet weak var strictTypingSwitch: UISwitch!
    @IBOutlet weak var strictTypingDescriptionLabel: UILabel!
    @IBOutlet weak var categoryClassicButton: UIButton!
    @IBOutlet weak var categoryQuotesButton: UIButton!
    @IBOutlet weak var categoryHokkuButton: UIButton!
    @IBOutlet weak var categoryCookiesButton: UIButton!
    @IBOutlet weak var categoryEnglishButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    init(viewModel: SettingsVM) {
        self.viewModel = viewModel
        super.init(nibName: "SettingsVC", bundle: nil)
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
        notificationSwitch.isOn  = viewModel.defaults.notifications
        strictTypingSwitch.isOn = viewModel.defaults.strictTyping

        settingsTitleLabel.text = viewModel.settingsTitle
        notificationTitleLabel.text = viewModel.notificationsTitle
        strictTypingTitleLabel.text = viewModel.strictTypingTitle

        notificationDescriptionLabel.attributedText = viewModel.notificationsInfo
        strictTypingDescriptionLabel.attributedText = viewModel.strictTypingInfo

        categoryClassicButton.isSelected = viewModel.defaults.classicEnabled
        categoryQuotesButton.isSelected = viewModel.defaults.quotesEnabled
        categoryHokkuButton.isSelected = viewModel.defaults.hokkuEnabled
        categoryCookiesButton.isSelected = viewModel.defaults.cookiesEnabled
        categoryEnglishButton.isSelected = viewModel.defaults.englishEnabled

        updateCategoryButton(categoryClassicButton)
        updateCategoryButton(categoryQuotesButton)
        updateCategoryButton(categoryHokkuButton)
        updateCategoryButton(categoryCookiesButton)
        updateCategoryButton(categoryEnglishButton)

        doneButton.setTitle(viewModel.doneTitle, for: .normal)

        for subview in view.subviews {
            if subview is UIButton {
                subview.layer.cornerRadius = subview.frame.size.height/2.0
            } else if let switcher = subview as? UISwitch {
                switcher.onTintColor = UIColor.tf_purple_button
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        if sender == notificationSwitch {
            let notifications = notificationSwitch.isOn
            viewModel.defaults.notifications = notifications
            onNotificationsSettingChanged?(notifications)
        } else if sender == strictTypingSwitch {
            viewModel.defaults.strictTyping = strictTypingSwitch.isOn
        }
    }

    @IBAction func onCategoryButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender == categoryClassicButton) {
            viewModel.defaults.classicEnabled = categoryClassicButton.isSelected
        } else if (sender == categoryQuotesButton) {
            viewModel.defaults.quotesEnabled = categoryQuotesButton.isSelected
        } else if (sender == categoryHokkuButton) {
            viewModel.defaults.hokkuEnabled = categoryHokkuButton.isSelected
        } else if (sender == categoryCookiesButton) {
            viewModel.defaults.cookiesEnabled = categoryCookiesButton.isSelected
        } else if (sender == categoryEnglishButton) {
            viewModel.defaults.englishEnabled = categoryEnglishButton.isSelected
        }
        updateCategoryButton(sender)
        onCategorySettingChanged?()
    }

    @IBAction func onDoneButtonPressed(_ sender: Any) {
        onDonePressed?()
    }

    // MARK: - Helper

    func updateCategoryButton(_ sender: UIButton)
    {
        let color = sender.isSelected ? UIColor.tf_purple_button : UIColor.tf_gray_button
        sender.backgroundColor = color
    }
    
}
