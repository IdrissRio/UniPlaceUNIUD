//
//  UPSlideOutMenuTabelViewControllerTableViewController.m
//  Progetto
//
//  Created by IdrissRio on 26/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPSlideOutMenuTabelViewControllerTableViewController.h"
#import "UPProfiloSlideOutMenu.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "SWRevealViewController.h"
@interface UPSlideOutMenuTabelViewControllerTableViewController (){
        NSManagedObjectContext* context;
    NSArray * menu;
}

@end

@implementation UPSlideOutMenuTabelViewControllerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    menu = @[@"Home",@"LeMieCoordinateAttuali" ,@"UniPlace", @"ChiSiamo",@"Copyright"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 13;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row==0){
        static NSString *simpleTableIdentifier = @"SimpleTableCell";
        NSFetchRequest * request=[[NSFetchRequest alloc]init];
        AppDelegate *objApp=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        context=[objApp managedObjectContext];
        NSEntityDescription *entitydesc=[NSEntityDescription entityForName:@"Utente" inManagedObjectContext:context];
        request = [[NSFetchRequest alloc]init];
        [request setEntity:entitydesc];
        NSPredicate * predicate =[ NSPredicate predicateWithFormat:@"nome like %@",@"*"];
        [request setPredicate:predicate];
        NSError * error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        UIImage * fotoProfiloUtente;
        NSString* nome;
        NSString* cognome;
        for(NSManagedObject* obj in results){
            nome=[obj valueForKey:@"nome"];
            cognome=[obj valueForKey:@"cognome"];
            fotoProfiloUtente=[[UIImage alloc]initWithData:[obj valueForKey:@"fotoprofilo"]];
        }
        UPProfiloSlideOutMenu *cell = (UPProfiloSlideOutMenu *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPProfiloSlideOutMenuCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.nomeCognomeLabel.text= [NSString stringWithFormat:@"%@ %@",nome,cognome];
        cell.userImageProfile.image=fotoProfiloUtente;
        cell.userImageProfile.layer.cornerRadius=cell.userImageProfile.frame.size.width/2;
       // UIColor * UPGreenColor=[UIColor colorWithRed:1.0/255.0 green:106.0/255.0 blue:127.0/255.0 alpha:1];

        cell.userImageProfile.layer.borderWidth=3.0f;
        cell.userImageProfile.layer.borderColor=[UIColor whiteColor].CGColor;
        cell.userImageProfile.clipsToBounds=YES;

        return cell;
    }else if(indexPath.row<=menu.count){
        NSString *simpleTableIdentifier =[menu objectAtIndex:indexPath.row-1];
        UITableViewCell*cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        return cell;
    }else{
        static NSString *simpleTableIdentifier = @"SimpleTableCell";
        UITableViewCell*cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        return cell;
    }

    

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
    return 145;
    }else return 60;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
    
    
}
@end
