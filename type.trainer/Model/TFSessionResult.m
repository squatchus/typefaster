//
//  TFLevelSession.m
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFSessionResult.h"

@implementation TFSessionResult

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init])
    {
        _seconds = [dict[@"seconds"] intValue];
        _symbols = [dict[@"symbols"] intValue];
        _mistakes = [dict[@"mistakes"] intValue];
    }
    return self;
}

- (NSDictionary *)dict
{
    return @{ @"seconds": @(self.seconds),
              @"symbols": @(self.symbols),
              @"mistakes": @(self.mistakes) };
}

- (int)signsPerMin
{
    return (int)((float)self.symbols / (float)self.seconds * 60.0);
}



@end
