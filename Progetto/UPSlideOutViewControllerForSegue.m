//
//  UPSlideOutViewControllerForSegue.m
//  Progetto
//
//  Created by Idriss Riouak on 03/02/17.
//  Copyright © 2017 Idriss Riouak. All rights reserved.
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
    if(_immagineGabri!=nil){
        _immagineGabri.layer.cornerRadius=_immagineGabri.frame.size.width/2;
        _immagineGabri.layer.borderWidth=3.0f;
        _immagineGabri.layer.borderColor=[UIColor whiteColor].CGColor;
        _immagineGabri.clipsToBounds=YES;
        _immagineIdriss.layer.cornerRadius=_immagineIdriss.frame.size.width/2;
        _immagineIdriss.layer.borderWidth=3.0f;
        _immagineIdriss.layer.borderColor=[UIColor whiteColor].CGColor;
        _immagineIdriss.clipsToBounds=YES;
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
