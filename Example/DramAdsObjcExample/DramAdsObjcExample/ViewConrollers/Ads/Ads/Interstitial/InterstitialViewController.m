//
//  InterstitialViewController.m
//  DramAdsObjcExample
//
//  Created by Khoren Asatryan on 24.09.23.
//

#import "InterstitialViewController.h"
#import <DramAds/DramAds-Swift.h>

@interface InterstitialViewController ()<DMInterstitialAdDelegate>

@end

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didSelectLoadAdButton:(id)sender {
    
    __weak InterstitialViewController *weakSelf = self;
    [DMInterstitialAd loadAdWithPlacementKey:@"a1d76e5f0ed9bc739e711e9fd2382954" success:^(DMInterstitialAd * ad) {
        [weakSelf showAd:ad];
    } failure:^(DMServiceAdError * error) {
        NSLog(@"%@", error.message);
    }];
 
}

-(void)showAd:(DMInterstitialAd *)ad {
    ad.delegate = self;
    [ad showIn: self];
}

#pragma mark - DMInterstitialAdDelegate

- (void)interstitialAdDidStartPlaying:(DMInterstitialAd *)ad {
    NSLog(@"interstitial AdDidStartPlaying %@", ad.placementKey);
}

- (void)interstitialAdDidSkiped:(DMInterstitialAd *)ad {
    NSLog(@"interstitial AdDidSkiped %@", ad.placementKey);
}

- (void)interstitialAdDidClicked:(DMInterstitialAd *)ad {
    NSLog(@"interstitial AdDidClicked %@", ad.placementKey);
}

- (void)interstitialAdDidSendImpression:(DMInterstitialAd *)ad error:(DMServiceAdError *)error {
    NSLog(@"interstitial AdDidSendImpression %@ %@", ad.placementKey, error.message);
}

- (void)interstitialAdDidCompleted:(DMInterstitialAd *)ad error:(DMServiceAdError *)error {
    NSLog(@"interstitial AdDidCompleted %@ %@", ad.placementKey, error.message);
}

@end
