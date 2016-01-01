//
//  UPAtterraggioTableViewController.m
//  Progetto
//
//  Created by IdrissRio on 16/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPAtterraggioTableViewController.h"
#import "UPAltreCategorieCell.h"
#import "UPNelleVicinanzeCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "NetworkLoadingManager.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface UPAtterraggioTableViewController ()<CLLocationManagerDelegate>{
    NSArray *varie;
    NSArray *biblioteche;
    NSArray *gastronomie;
    NSArray *vitaNotturna ;
    
}
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

@implementation UPAtterraggioTableViewController



- (CLLocationManager *)locationManager{
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}


-(void)viewWillAppear:(BOOL)animated{
    
    // Si vogliono cercare i luoghi più vicini alla posizione attuale. Per
    // farlo, prelevo latitudine e longitudine.
    NSString *latitudine = [[NSString alloc] initWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
    NSString *longitudine = [[NSString alloc]initWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
    
    // Costruisco il corpo della richiesta da mandare al server contenente solamente
    // i due campi appena prelevati, creando l'oggetto apposito.
    NetworkLoadingManager *positionUploader = [[NetworkLoadingManager alloc]init];
    
    // Inserisco latitudine e longitudine in un dictionary come richiesto dal metodo.
    NSDictionary *parametri = [NSDictionary dictionaryWithObjectsAndKeys:latitudine, @"latitudine",
                               longitudine, @"longitudine",
                               nil];
    
    NSURLRequest * request = [positionUploader createBodyWithURL:@"http://mobdev2015.com/preleva_vicinanze.php" Parameters:parametri DataImage:nil ImageInformations:nil];
    
    // Creo la NSURLSessionConfiguration e la relativa NSURLSession
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError *error){
        if(data){
            NSError *parseError;
            NSDictionary *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (datiUtente) {
                NSString *esito = [NSString stringWithString: [datiUtente objectForKey:@"success"]];
                
                if([esito isEqualToString:@"1"]){
                    // Inserisci qui il metodo.
                }
                    
            }else NSLog(@"parseError = %@ \n", parseError);
            
            NSLog(@"responseString = %@ \n", [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
            
        }

    }]resume];
    
    
    
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    
    if(self.pageIndex==0){
        if([indexPath row]==0){
            UPAltreCategorieCell*cell = (UPAltreCategorieCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPNelleVicinanzeCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
#ifdef __IPHONE_8_0
            if(IS_OS_8_OR_LATER) {
 
                [self.locationManager requestWhenInUseAuthorization];
                
            }
#endif
            [self.locationManager startUpdatingLocation];
            
            [MKMapView class];
            MKCoordinateRegion mapRegion;
            mapRegion.center =  _locationManager.location.coordinate;
            mapRegion.span.latitudeDelta = 0.001;
            mapRegion.span.longitudeDelta = 0.001;
            [cell.mappaLuogo setRegion:mapRegion animated:YES];
            for(NSDictionary *dict in varie){
                NSLog(@"Aggiungo MKNotation");
                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                NSString *longitudine=[dict objectForKey:@"Longitudine"];
                NSString *latitudine=[dict objectForKey:@"Latitudine"];
                CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake([latitudine doubleValue],[longitudine doubleValue]);
                point.coordinate =newCenter;
                point.title = [dict objectForKey:@"Nome"];
                point.subtitle = [dict objectForKey:@"Indirizzo"];
                [cell.mappaLuogo addAnnotation:point];
            }
            
            
            return cell;
        }
        else{
            UITableViewCell*cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            }
            return cell;
        }
    }else{
        UPNelleVicinanzeCell *cell = (UPNelleVicinanzeCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPAltreCategorieCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        return cell;
        
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.pageIndex==0){
        if([indexPath row]>0)
            return 140;
        else
            return 290;
    }else return 240;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) setReviewResult:(int)Esito{
    if(Esito == 1){
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Problema nel prelevre i luoghi!"
                                                                         preferredStyle:UIAlertControllerStyleAlert ];
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Errore" style:UIAlertActionStyleDefault handler:nil];
            [errorAlert addAction:OkAction];
            [self presentViewController:errorAlert animated:YES completion:nil];
            
        }];
    }
}

@end

