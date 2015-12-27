//
//  UPSlideOutViewControllerForSegue.h
//  Progetto
//
//  Created by IdrissRio on 26/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPSlideOutViewControllerForSegue : UIViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UILabel *longitudineLabel;
@property (strong, nonatomic) IBOutlet UILabel *latituineLabel;
@property (strong, nonatomic) IBOutlet UILabel *altitudineLabel;
@property (strong, nonatomic) IBOutlet UIImageView *immagineGabri;
@property (strong, nonatomic) IBOutlet UIImageView *immagineIdriss;
@property (strong, nonatomic) IBOutlet UILabel *labelBenvenuto;

@end
