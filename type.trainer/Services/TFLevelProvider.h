//
//  DataProvider.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFLevel.h"
#import "TFSettingsVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFLevelProvider : NSObject

- (TFLevel *)nextLevelForSettings:(TFSettingsVM *)settings;

@end

NS_ASSUME_NONNULL_END
