//
//  UPCategoriePageViewController.h
//  Progetto
//
//  Created by Idriss Riouak on 04/03/17.
//  Copyright © 2017 Idriss Riouak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPCategoriePageViewController : UIViewController<UIPageViewControllerDataSource>
@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@end
