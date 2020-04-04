//
//  TypingVC.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 31.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class TypingVC: UIViewController, UITextViewDelegate {

    var viewModel: TypingVM!
    
    var onViewWillAppear: ((_ vc: TypingVC)->())?
    var onMistake: (()->())?
    var onDonePressed: (()->())?
    var onLevelCompleted: ((_ viewModel: TypingVM)->())?
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var levelTextView: TextView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    var maxKeyboardHeight: CGFloat = 0
    
    init() {
        super.init(nibName: "TypingVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // will update view model
        onViewWillAppear?(self)
        
        let currentWord = Bundle.main.loadNibNamed("CurrentWordView", owner: self, options: nil)?.first as! CurrentWordView
        currentWord.shift.layer.cornerRadius = 4
        currentWord.backspace.layer.cornerRadius = 4
        levelTextView.inputAccessoryView = currentWord
        
        statsLabel.text = "0"
        secondsLabel.text = "0:00"
        levelTextView.becomeFirstResponder()
        setupViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        levelTextView.resignFirstResponder()
    }
    
    // MARK: - View Model Management
    
    func setupViewModel() {
        viewModel.onSessionStarted = { [weak self] in
            self?.secondsLabel.textColor = UIColor.tf_purple_text
        }
        viewModel.onTimerUpdated = { [weak self] (min, sec) in
            self?.secondsLabel.text = String(format: "%d:%02d", min, sec)
        }
        viewModel.onSessionEnded = { [weak self] in
            self?.secondsLabel.textColor = UIColor.tf_light_text
            self?.onLevelCompleted?(self!.viewModel)
        }
        completeButton.setTitle(viewModel.completeTitle, for: .normal)
        statsLabel.text = viewModel.enteredCharsNumber
        levelTextView.viewModel = viewModel
        updateTextViewLayout()
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let result = viewModel.input(text, in: range)
        // show results
        statsLabel.text = viewModel.enteredCharsNumber
        levelTextView.reloadViewModel()
        // respond to results
        if result == .impossible {
            self.pulseTextViewBackgroundColor()
        } else if (result == .mistaken) {
            onMistake?()
        }
        // we called update manually, therefore
        return false
    }
    
    // MARK: - IBActions
    
    @IBAction func onDoneButtonPressed(sender: UIButton) {
        onDonePressed?()
    }
    
    // MARK: - Helpers
    
    func updateTextViewLayout() {
        var size = view.frame.size
        size.width -= 24 // with 12+12 margins
        size.height *= 0.66 // 2/3 of the screen
        for c in levelTextView.constraints {
            if c.firstAttribute == .height { c.constant = size.height }
            if c.firstAttribute == .width { c.constant = size.width }
        }
        view.layoutIfNeeded()
        
        size = levelTextView.sizeThatFits(size)

        for c in levelTextView.constraints {
            if c.firstAttribute == .height { c.constant = size.height }
            if c.firstAttribute == .width { c.constant = size.width }
        }
        view.layoutIfNeeded()
    }
    
    func pulseTextViewBackgroundColor() {
        UIView.animate(withDuration: 0.15, animations: {
            self.view.backgroundColor = UIColor.tf_background_red
        }) { (finished) in
            UIView.animate(withDuration: 0.15) {
                self.view.backgroundColor = UIColor.tf_background
            }
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let frameEnd = notification.userInfo![frameKey] as! NSValue
        let duration = notification.userInfo![durationKey] as! TimeInterval
        let keyboardFrame = frameEnd.cgRectValue
        if (keyboardFrame.size.height > maxKeyboardHeight) {
            maxKeyboardHeight = keyboardFrame.size.height
        }
        UIView.animate(withDuration: duration) {
            self.bottomMargin.constant = self.maxKeyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as! TimeInterval
        UIView.animate(withDuration: duration) {
            self.bottomMargin.constant = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}
