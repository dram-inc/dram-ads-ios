//
//  DramAdsViewController.m
//  DramAdsObjcExample
//
//  Created by Khoren Asatryan on 23.09.23.
//

#import "DramAdsViewController.h"
#import "DramAds/DramAds-Swift.h"

@interface DramAdsViewController ()

@end

@implementation DramAdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DMEnvironment *enviorment = [[DMEnvironment alloc] initWithType: DMEnvironmentTypeDemo];
    [DMDram.sharedManager configureWithEnvironment:enviorment];
}


@end
