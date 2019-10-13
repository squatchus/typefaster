//
//  LeaderboardService.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFLeaderboardService.h"

@import GameKit;

@interface TFLeaderboardService() <GKGameCenterControllerDelegate>

@property (nonatomic, strong) NSString* leaderboardIdentifier;
@property BOOL gameCenterEnabled;
@property int score;

@end

@implementation TFLeaderboardService

-(void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if (viewController)
        {
            [self.rootVC presentViewController:viewController animated:YES completion:nil];
        }
        else
        {
            if ([GKLocalPlayer localPlayer].authenticated)
            {
                self.gameCenterEnabled = YES;
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    if (error)
                    {
//                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else
                    {
                        self.leaderboardIdentifier = leaderboardIdentifier;
                        
                        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
                        leaderboardRequest.identifier = leaderboardIdentifier;
                        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
                            if (error)
                            {
//                                NSLog(@"%@", [error localizedDescription]);
                            }
                            else
                            {
                                self.score = (int)leaderboardRequest.localPlayerScore.value;
                                self.onScoreReceived ? self.onScoreReceived(self.score) : nil;
                            }
                        }];
                    }
                }];
            }
            else self.gameCenterEnabled = NO;
        }
    };
}

- (BOOL)canShowLeaderboard;
{
    return (self.gameCenterEnabled && self.leaderboardIdentifier);
}

- (void)showLeaderboard
{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = self.leaderboardIdentifier;
    [self.rootVC presentViewController:gcViewController animated:YES completion:nil];
}

- (void)reportScore:(int)score
{
    if (self.gameCenterEnabled)
    {
        GKScore *scoreToReport = [[GKScore alloc] initWithLeaderboardIdentifier:self.leaderboardIdentifier];
        scoreToReport.value = score;
        [GKScore reportScores:@[scoreToReport] withCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
//                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

- (UIViewController *)rootVC
{
    id<UIApplicationDelegate> app = UIApplication.sharedApplication.delegate;
    return app.window.rootViewController;
}

#pragma mark - GKGameCenterControllerDelegate

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
