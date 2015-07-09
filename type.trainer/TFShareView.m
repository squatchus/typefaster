//
//  TFShareView.m
//  type.trainer
//
//  Created by Squatch on 09.07.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFShareView.h"

#define kSharedTextNumberOfLines 4

@implementation TFShareView

- (void)updateWithText:(NSString *)text author:(NSString *)author andSpeed:(int)speed {
    NSArray *components = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    int numberOfLines = kSharedTextNumberOfLines;
    if (components.count > numberOfLines) {
        NSMutableArray *firstLines = [NSMutableArray arrayWithArray:components];
        [firstLines removeObjectsInRange:NSMakeRange(numberOfLines, components.count - numberOfLines)];
        text = [firstLines componentsJoinedByString:@"\n"];
        text = [NSString stringWithFormat:@"%@...", text];
    }
    
    _textView.text = text;
    
    int lastDigit = speed % 10;
    NSString *ending = (lastDigit == 1)?@"":((lastDigit > 1 && lastDigit < 5)?@"а":@"ов");
    _speedLabel.text = [NSString stringWithFormat:@"Скорость набора - %d знак%@ в мин.", speed, ending];
    _authorLabel.text = [NSString stringWithFormat:@"© %@", author];
    
    [self layoutIfNeeded];
    CGSize size = [_textView sizeThatFits:CGSizeMake(_textView.frame.size.width, CGFLOAT_MAX)];
    CGFloat newWidth = _textView.frame.size.width - size.width;
    CGFloat newHeight = _textView.frame.size.height - size.height;
    CGSize sizeDelta = CGSizeMake(newWidth, newHeight);
    CGRect frame = self.frame;
    frame.size.width = frame.size.width - sizeDelta.width;
    frame.size.height = frame.size.height - sizeDelta.height+10;
    self.frame = frame;
    [self layoutIfNeeded];
}

- (UIImage *)renderImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
