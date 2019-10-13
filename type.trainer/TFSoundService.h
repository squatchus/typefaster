//
//  sounds.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface TFSoundService : NSObject

- (void)playKeyboardClickSound;
- (void)playButtonClickSound;
- (void)playErrorSound;
- (void)playNewRecordSound;
- (void)playNewRankSound;

@end

NS_ASSUME_NONNULL_END
