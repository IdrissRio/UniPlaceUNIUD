//
//  UPCategoriePageViewController.m
//  Progetto
//
//  Created by IdrissRio on 17/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPCategoriePageViewController.h"
#import "UPAtterraggioTableViewController.h"
#import "SWRevealViewController.h"
@interface UPCategoriePageViewController ()

@end

@implementation UPCategoriePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    UIColor * UPGreenColor=[UIColor colorWithRed:1.0/255.0 green:106.0/255.0 blue:127.0/255.0 alpha:1];
    self.navigationController.navigationBar.barTintColor = UPGreenColor;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewController"];
    self.pageViewController.dataSource = self;
    
    UPAtterraggioTableViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((UPAtterraggioTableViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((UPAtterraggioTableViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == 4) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (UPAtterraggioTableViewController *)viewControllerAtIndex:(NSUInteger)index
{

    if (  (index >= 4)) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    UPAtterraggioTableViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UPAtterraggioTableViewController"];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
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
