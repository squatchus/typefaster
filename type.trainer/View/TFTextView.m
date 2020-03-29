//
//  TFTextView.m
//  type.trainer
//
//  Created by Sergey Mazulev on 29.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

#import "TFTextView.h"

@implementation TFTextView

- (void)setSelectedRange:(NSRange)selectedRange
{
    NSRange cursorRange = self.viewModel.getCursorRange;
    [super setSelectedRange:cursorRange];
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange
{
    NSRange range = self.viewModel.getCursorRange;
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [self positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    [super setSelectedTextRange:textRange];
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    NSRange cursorRange = self.viewModel.getCursorRange;
    [super setMarkedText:markedText selectedRange:cursorRange];
}

- (void)setAttributedMarkedText:(NSAttributedString *)markedText selectedRange:(NSRange)selectedRange
{
    NSRange cursorRange = self.viewModel.getCursorRange;
    [super setAttributedMarkedText:markedText selectedRange:cursorRange];
}

@end
