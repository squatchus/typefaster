//
//  TextView.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 31.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class TextView: UITextView {

    weak var viewModel: TFTypingVM? {
        didSet {
            reloadViewModel()
        }
    }
    
    var currentWordView: CurrentWordView {
        inputAccessoryView as! CurrentWordView
    }
    
    func reloadViewModel() {
        if let viewModel = self.viewModel {
            attributedText = viewModel.getText()
            selectedRange = viewModel.getCursorRange()
            currentWordView.label.attributedText = viewModel.getCurrentWord()
            currentWordView.backspace.isHidden = viewModel.backspaceHidden()
            currentWordView.shift.isHidden = viewModel.shiftHidden()
        }
    }
    
    // prevent smart input from 'swipe to type'
    // which brokes cursor position
    override var selectedRange: NSRange {
        get {
            super.selectedRange
        } set(newValue) {
            let range = viewModel?.getCursorRange() ?? newValue
            super.selectedRange = range
        }
    }
    
    override var selectedTextRange: UITextRange? {
        get {
            super.selectedTextRange
        } set(newValue) {
            if let range = viewModel?.getCursorRange() {
                let beginning = beginningOfDocument
                if let start = position(from: beginning, offset: range.location) {
                    if let end = position(from: start, offset: range.length) {
                        super.selectedTextRange = textRange(from: start, to: end)
                    }
                }
            } else {
                super.selectedTextRange = newValue
            }
        }
    }
    
}
