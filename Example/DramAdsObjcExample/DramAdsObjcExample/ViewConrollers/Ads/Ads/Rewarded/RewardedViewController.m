//
//  RewardedViewController.m
//  DramAdsObjcExample
//
//  Created by Khoren Asatryan on 23.09.23.
//

#import "RewardedViewController.h"
#import <DramAds/DramAds-Swift.h>

@interface RewardedViewController () <DMRewardedAdDelegate, DMRewardedAdUIDataSource>

@end

@implementation RewardedViewController

- (IBAction)didSelectLoadAdButton:(id)sender {
    
    //a23c4147ab4d03ecdb937b15a3c3dc60 2
    //c418065bb67183661a1249cbdebdf071 1
    
    __weak RewardedViewController *weakSelf = self;
    [DMRewardedAd loadAdWithPlacementKey:@"c418065bb67183661a1249cbdebdf071" success:^(DMRewardedAd * ad) {
        
        ad.delegate = weakSelf;
        ad.uiDataSource = weakSelf;
        [ad showIn:self];
        
    } failure:^(DMServiceAdError * error) {
        NSLog(@"%@", error.message);
    }];
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - DMRewardedAdDelegate

- (void)rewardedAdDidStartPlaying:(DMRewardedAd *)ad {
    NSLog(@"rewardedAd DidStartPlaying %@", ad.placementKey);
}

- (void)rewardedAdDidClicked:(DMRewardedAd *)ad {
    NSLog(@"rewardedAd AdDidClicked %@", ad.placementKey);
}

- (void)rewardedAdDidCompleted:(DMRewardedAd *)ad error:(DMServiceAdError *)error {
    NSLog(@"rewardedAd AdDidCompleted %@", ad.placementKey);
}

- (void)rewardedAdDidSendImpression:(DMRewardedAd *)ad error:(DMServiceAdError *)error {
    NSLog(@"rewardedAd AdDidSendImpression %@", ad.placementKey);
}

#pragma mark - DMRewardedAdUIDataSource

- (UIInterfaceOrientationMask)rewardedAdSupportedInterfaceOrientations:(DMRewardedAd *)ad {
    return self.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)rewardedAdPreferredInterfaceOrientationForPresentation:(DMRewardedAd *)ad {
    return self.preferredInterfaceOrientationForPresentation;
}

@end
