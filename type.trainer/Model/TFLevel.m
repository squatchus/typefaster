//
//  TFLevel.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFLevel.h"

#define kLevelKeyTitle @"title"
#define kLevelKeyAuthor @"author"
#define kLevelKeyText @"text"
#define kLevelKeyCategory @"category"

@implementation TFLevel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init])
    {
        _dict = dict;
        _title = dict[kLevelKeyTitle];
        _author = dict[kLevelKeyAuthor];
        _text = dict[kLevelKeyText];
        _category = dict[kLevelKeyCategory];
        
        NSMutableArray *tokens = [NSMutableArray new];
        NSString *curTokenString = @"";
        int curTokenStart=-1, curTokenEnd=-1;
        NSCharacterSet *letters = [self cyrillicLetters];
        for (int i=0; i<self.text.length; i++) {
            unichar c = [self.text characterAtIndex:i];
            NSString *cString = [NSString stringWithCharacters:&c length:1];
            if ([letters characterIsMember:c]) {
                if (curTokenString.length == 0) curTokenStart = i;
                curTokenString = [NSString stringWithFormat:@"%@%@", curTokenString, cString];
            }
            else {
                if (curTokenString.length > 0) {
                    curTokenEnd = i-1;
                    TFToken *token = [[TFToken alloc] initWithString:curTokenString startIndex:curTokenStart endIndex:curTokenEnd];
                    [tokens addObject:token];
                    curTokenString = @"";
                }
                TFToken *token = [[TFToken alloc] initWithString:cString startIndex:i endIndex:i];
                [tokens addObject:token];
            }
        }
        if (curTokenString.length > 0) {
            curTokenEnd = (int)self.text.length-1;
            TFToken *token = [[TFToken alloc] initWithString:curTokenString startIndex:curTokenStart endIndex:curTokenEnd];
            [tokens addObject:token];
        }
        _tokens = tokens.copy;
    }
    return self;
}

- (NSCharacterSet *)cyrillicLetters
{
    NSString *string = @"абвгдеёжзийклмнопрстуфхцчшщьыъэюя";
    string = [string stringByAppendingString:[string uppercaseString]];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:string];
    return set;
}

- (nullable TFToken *)tokenByPosition:(int)position
{
    for (TFToken *t in _tokens)
    {
        if (position >= t.startIndex && position <= t.endIndex)
        {
            return t;
        }
    }
    return nil;
}

@end
