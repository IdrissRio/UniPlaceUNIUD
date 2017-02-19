//
//  UPCategoriePageViewController.h
//  Progetto
//
//  Created by IdrissRio on 17/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPCategoriePageViewController : UIViewController<UIPageViewControllerDataSource>
@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@end
