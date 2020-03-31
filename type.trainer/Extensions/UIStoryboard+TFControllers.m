//
//  UIStoryboard+TFControllers.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "UIStoryboard+TFControllers.h"

#import "type_trainer-Swift.h"

@implementation UIStoryboard (TFControllers)

+ (TFTypingVC *)typingVC
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"typing.vc"];
}

+ (TFResultsVC *)resultsVC
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"results.vc"];
}

@end
