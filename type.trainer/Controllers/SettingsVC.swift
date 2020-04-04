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
    var onShouldDismissVC: ((_ vc: UIViewController)->())?

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
        notificationSwitch.isOn = viewModel.settings.notifications
        strictTypingSwitch.isOn = viewModel.settings.strictTyping

        settingsTitleLabel.text = viewModel.data.settingsTitle
        notificationTitleLabel.text = viewModel.data.notificationsTitle
        strictTypingTitleLabel.text = viewModel.data.strictTypingTitle

        notificationDescriptionLabel.attributedText = viewModel.data.notificationsInfo.justified
        strictTypingDescriptionLabel.attributedText = viewModel.data.strictTypingInfo.justified

        categoryClassicButton.isSelected = viewModel.settings.classicEnabled
        categoryQuotesButton.isSelected = viewModel.settings.quotesEnabled
        categoryHokkuButton.isSelected = viewModel.settings.hokkuEnabled
        categoryCookiesButton.isSelected = viewModel.settings.cookiesEnabled
        categoryEnglishButton.isSelected = viewModel.settings.englishEnabled

        updateCategoryButton(categoryClassicButton)
        updateCategoryButton(categoryQuotesButton)
        updateCategoryButton(categoryHokkuButton)
        updateCategoryButton(categoryCookiesButton)
        updateCategoryButton(categoryEnglishButton)

        doneButton.setTitle(viewModel.data.doneTitle, for: .normal)

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
            viewModel.settings.notifications = notifications
            onNotificationsSettingChanged?(notifications)
        } else if sender == strictTypingSwitch {
            viewModel.settings.strictTyping = strictTypingSwitch.isOn
        }
    }

    @IBAction func onCategoryButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender == categoryClassicButton) {
            viewModel.settings.classicEnabled = categoryClassicButton.isSelected
        } else if (sender == categoryQuotesButton) {
            viewModel.settings.quotesEnabled = categoryQuotesButton.isSelected
        } else if (sender == categoryHokkuButton) {
            viewModel.settings.hokkuEnabled = categoryHokkuButton.isSelected
        } else if (sender == categoryCookiesButton) {
            viewModel.settings.cookiesEnabled = categoryCookiesButton.isSelected
        } else if (sender == categoryEnglishButton) {
            viewModel.settings.englishEnabled = categoryEnglishButton.isSelected
        }
        updateCategoryButton(sender)
        onCategorySettingChanged?()
    }

    @IBAction func onDoneButtonPressed(_ sender: Any) {
        onShouldDismissVC?(self)
    }

    // MARK: - Helper

    func updateCategoryButton(_ sender: UIButton) {
        let color = sender.isSelected ? UIColor.tf_purple_button : UIColor.tf_gray_button
        sender.backgroundColor = color
    }
    
}
