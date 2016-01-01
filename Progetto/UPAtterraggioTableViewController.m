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
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
     * L'utente verrà notificato durante il download dei dati da un AlertController solamente la prima volta che visualizza
     * questa view, e non nei successivi possibili ritorni dovuti agli swipe.
     */
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Aggiornamento luoghi in corso"
                                                                 preferredStyle:UIAlertControllerStyleAlert ];
    [self presentViewController:errorAlert animated:YES completion:nil];
    
    
    /*
     * La richiesta da inviare al server utilizzerà sempre il metodo createBodyWithUrl:Parameters:DataImage:Image
     * Informations fornito dalla classe NetworkLoadingManager, il quale conterrà solamente il link della richiesta
     * dal momento che non dovranno essere passati dati al server.
     */
    NetworkLoadingManager *downloader = [[NetworkLoadingManager alloc]init];
    NSURLRequest *request = [downloader createBodyWithURL:@"http://mobdev2015.com/prelevaluoghi.php" Parameters:nil DataImage:nil ImageInformations:nil];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
            NSError *parseError;
            /*
             * La scelta di deserializzare i dati in un NSArray e non in un NSDictionary è dovuta ad una questione di comodità
             * per poter prelevare i vari elementi dell'array contenenti a loro volta zero, uno o più NSDictionary. Ciascuno
             * di essi avrà al suo interno tutti i campi prelevati dal database, utilizzati per poi riempire le righe della
             * lista.
             */
            NSArray *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (datiUtente) {
                NSString *esito = [NSString stringWithString: [datiUtente valueForKey:@"success"]];
                
                // Se l'operazione da server è andata a buon fine, la chiave "success" vale 1.
                if([esito isEqualToString:@"1"]){
                    
                    /*
                     * DEBUG: ti ho lasciato i quattro array iterati dal for sottostante in modo che tu abbia tutte
                     * le informazioni prelevate, prendi ciò che ti serve e manipola pure le righe qui sotto.
                     */
                    biblioteche = [datiUtente valueForKey:@"Biblioteche"];
                    for(NSDictionary *dict in biblioteche){
                        NSLog(@"%@", [dict objectForKey:@"FotoProfilo"]);
                        NSLog(@"%@", [dict objectForKey:@"ID"]);
                        NSLog(@"%@", [dict objectForKey:@"Nome"]);
                        NSLog(@"%@", [dict objectForKey:@"NumeroTelefonico"]);
                        NSLog(@"%@", [dict objectForKey:@"Indirizzo"]);
                        NSLog(@"%@", [dict objectForKey:@"Latitudine"]);
                        NSLog(@"%@", [dict objectForKey:@"Longitudine"]);
                        NSLog(@"%@", [dict objectForKey:@"Media"]);
                        
                    }
                    
                    gastronomie = [datiUtente valueForKey:@"Gastronomia"];
                    for(NSDictionary *dict in gastronomie){
                        NSLog(@"%@", [dict objectForKey:@"FotoProfilo"]);
                        NSLog(@"%@", [dict objectForKey:@"ID"]);
                        NSLog(@"%@", [dict objectForKey:@"Nome"]);
                        NSLog(@"%@", [dict objectForKey:@"NumeroTelefonico"]);
                        NSLog(@"%@", [dict objectForKey:@"Indirizzo"]);
                        NSLog(@"%@", [dict objectForKey:@"Latitudine"]);
                        NSLog(@"%@", [dict objectForKey:@"Longitudine"]);
                        NSLog(@"%@", [dict objectForKey:@"Media"]);
                        
                    }
                    
                    vitaNotturna = [datiUtente valueForKey:@"Vita Notturna"];
                    for(NSDictionary *dict in vitaNotturna){
                        NSLog(@"%@", [dict objectForKey:@"FotoProfilo"]);
                        NSLog(@"%@", [dict objectForKey:@"ID"]);
                        NSLog(@"%@", [dict objectForKey:@"Nome"]);
                        NSLog(@"%@", [dict objectForKey:@"NumeroTelefonico"]);
                        NSLog(@"%@", [dict objectForKey:@"Indirizzo"]);
                        NSLog(@"%@", [dict objectForKey:@"Latitudine"]);
                        NSLog(@"%@", [dict objectForKey:@"Longitudine"]);
                        NSLog(@"%@", [dict objectForKey:@"Media"]);
                        
                    }
                    
                    varie = [datiUtente valueForKey:@"Varie"];
                    for(NSDictionary *dict in varie){
                        NSLog(@"%@", [dict objectForKey:@"FotoProfilo"]);
                        NSLog(@"%@", [dict objectForKey:@"ID"]);
                        NSLog(@"%@", [dict objectForKey:@"Nome"]);
                        NSLog(@"%@", [dict objectForKey:@"NumeroTelefonico"]);
                        NSLog(@"%@", [dict objectForKey:@"Indirizzo"]);
                        NSLog(@"%@", [dict objectForKey:@"Latitudine"]);
                        NSLog(@"%@", [dict objectForKey:@"Longitudine"]);
                        NSLog(@"%@", [dict objectForKey:@"Media"]);
                        
                    }
                    
                    
                    // Faccio sparire l'AlertViewController
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setReviewResult:1];
                    });
                }
                else // In caso di esito negativo, faccio sparire semplicemente l'AlertView.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setReviewResult:0];
                    });
                
            } else // Se la conversione è andata male, stampo il messaggio di errore (DEBUG)
                NSLog(@"parseError = %@ \n", parseError);
            
        } else // Se non ho prelevato nessun dato, esco.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setReviewResult:0];
  
            });
        

      
        
        
    }] resume];
    

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

    return 10;
}
- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    // Determine if row is selectable based on the NSIndexPath.
    
    if(self.pageIndex==0)
        if([path row]==0)
            return nil;
    return path;
    

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

