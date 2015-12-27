//
//  UPSlideOutViewControllerForSegue.m
//  Progetto
//
//  Created by IdrissRio on 26/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPSlideOutViewControllerForSegue.h"
#import "SWRevealViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface UPSlideOutViewControllerForSegue ()
@property (nonatomic,strong) CLLocationManager *locationManager;
@end





@implementation UPSlideOutViewControllerForSegue

- (CLLocationManager *)locationManager{
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _locationManager = [[CLLocationManager alloc]init];
    if(_longitudineLabel!=nil){
        _longitudineLabel.text=[NSString stringWithFormat:@"%f",_locationManager.location.coordinate.longitude];
        _latituineLabel.text=[NSString stringWithFormat:@"%f",_locationManager.location.coordinate.latitude];
        _altitudineLabel.text=[NSString stringWithFormat:@"%f",_locationManager.location.altitude];
    }
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
