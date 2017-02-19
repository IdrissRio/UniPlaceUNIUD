//
//  UPSelectUniversity.m
//  Progetto
//
//  Created by IdrissRio on 24/11/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPSelectUniversity.h"
#import "Foundation/Foundation.h"
@interface UPSelectUniversity (){
    NSString* nomeUni;
    UIImage* logoUni;
}


@end

@implementation UPSelectUniversity

- (void)viewDidLoad {
    [super viewDidLoad];
 
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
    return 19;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section){
        case 0:return 8;
        case 1:return 5;
        case 2:return 8;
        case 3: return 6;
        case 4:
        case 5:
        case 6:
        case 7:
            return 4;
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
            return 3;
        case 13:
        case 14:
            return 2;
        case 15:
        case 16:
        case 17:
        case 18:
            return 1;
        default:return 1;
    }

    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UPCustomCellUniversitaTableViewCell *x= [tableView cellForRowAtIndexPath:indexPath];
    logoUni=[x.fotoUniversita image];
    nomeUni=[x.nomeUniversita text];
    [self performSegueWithIdentifier:@"selectedUniversitySegue" sender:self];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectedUniversitySegue"]){
        if([segue.destinationViewController isKindOfClass:[userInfoViewController class]]){
            userInfoViewController* obj=(userInfoViewController *)segue.destinationViewController;
            obj.universitario=[[UPUniversitario alloc]init];
            obj.universitario.LogoUni= UIImagePNGRepresentation(logoUni);
            obj.universitario.universita=nomeUni;
            
            //Se email è nil allora rimane nil altrimenti se l'utente ha effettuato l'accesso con facebook viene manetenuta l'email.
            obj.universitario.email=_tieniInfoViewPrecedente.email;
            obj.universitario.nome=_tieniInfoViewPrecedente.nome;
            obj.universitario.cognome=_tieniInfoViewPrecedente.cognome;
            obj.universitario.fotoProfilo=_tieniInfoViewPrecedente.fotoProfilo;
         
        }
    }

}


@end
