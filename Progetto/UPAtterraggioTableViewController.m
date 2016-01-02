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
    __block NSDictionary *luoghiVicini;
   __block NSArray *luoghiRecenti;
    UPNelleVicinanzeCell* Header;
    
    
}

- (void)prelevaRecenti;
- (void)prelevaVicinanze;
- (void)prelevaMaggiormenteRecensiti;
- (void)prelevaTendenze;
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

@implementation UPAtterraggioTableViewController

-(void)inserisciNotation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if(self.pageIndex==0){
        for(int i=0;i<luoghiVicini.count;++i){
            NSDictionary* dict = [luoghiVicini objectForKey:[NSString stringWithFormat:@"%d",i]];
            NSLog(@"Aggiungo MKNotation");
            NSString *longitudine=[dict objectForKey:@"Longitudine"];
            NSString *latitudine=[dict objectForKey:@"Latitudine"];
            if(longitudine!=nil && latitudine!=nil){
                MKPointAnnotation * point= [[MKPointAnnotation  alloc]init];
                CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake([latitudine doubleValue],[longitudine doubleValue]);
                point.coordinate =newCenter;
                point.title=[dict objectForKey:@"Nome"];
                point.subtitle=@"salve";
                [Header.mappaLuogo addAnnotation:point];
            }
        }
    }
        for(int i=0;i<luoghiVicini.count;i++){
            NSDictionary* dict = [luoghiVicini objectForKey:[NSString stringWithFormat:@"%d",i]];
            NSLog(@"Modifico le TableViewCell");
            NSString *longitudine=[dict objectForKey:@"Longitudine"];
            NSString *latitudine=[dict objectForKey:@"Latitudine"];
            if(longitudine!=nil && latitudine!=nil){
                UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.textLabel.text=[dict objectForKey:@"Nome"];
                cell.imageView.image =[UIImage imageNamed:@"ManEtta.png"];
                //Quando gabri mette l'immagine profilo.
                // cell.imageView.image=[UIImage imageWithData:[dict objectForKey:@"fotoProfilo"] scale:0.5];
            }
               
            
         
        }
[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (CLLocationManager *)locationManager{
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
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
    
    return 10;
}

- (void)viewWillAppear:(BOOL)animated{

    
    /* La seguente serie di if scaricherà, in base all'indice della pagina che l'utente sta visualizzando, diverse
     * tipologie di luoghi:
     * - pageIndex = 0: verranno prelevati i luoghi più vicini alla posizione attuale.
     * - pageIndex = 1: verranno prelevati i luoghi aggiunti di recente partendo dai più nuovi.
     * - pageIndex = 2: verranno prelevati i luoghi di tendenza, ovvero i luoghi più recensiti negli ultimi
     * sette giorni.
     * - pageIndex = 3: verranno prelevati i luoghi più recensiti, in ordine decrescente.
     */
    
    
    if(self.pageIndex == 0){
        NSString *latitudine = [[NSString alloc] initWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
        NSString *longitudine = [[NSString alloc]initWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
        
        NSDictionary *coordinate = [NSDictionary dictionaryWithObjectsAndKeys:latitudine, @"latitudine",
                                    longitudine, @"longitudine", nil];
        
        NetworkLoadingManager *geoUploader = [[NetworkLoadingManager alloc]init];
        NSURLRequest *request = [geoUploader createBodyWithURL:@"http://mobdev2015.com/preleva_vicinanze.php" Parameters:coordinate DataImage:nil ImageInformations:nil];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionTask *task1 = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            if(data){
                NSError *parseError;
                luoghiVicini = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                if (luoghiVicini) {
                    NSString *esito = [NSString stringWithString: [luoghiVicini valueForKey:@"success"]];
                    
                    if([esito isEqualToString:@"1"]){
                        NSLog(@"%@", luoghiVicini );
                        [self performSelectorOnMainThread:@selector(inserisciNotation) withObject:nil waitUntilDone:YES];
                    }
                    else{
                        // Inserire eventualmente qualcosa.
                    }
                    
                }
                NSLog(@"parseError = %@ \n", parseError);
                
                //NSLog(@"responseString = %@ \n", [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
                
            }
        }];
        
        [task1 resume];

        
    }
    
    if(self.pageIndex == 1){

            
            NSString *latitudine = [[NSString alloc] initWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
            NSString *longitudine = [[NSString alloc]initWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
            
            NSDictionary *coordinate = [NSDictionary dictionaryWithObjectsAndKeys:latitudine, @"latitudine",
                                        longitudine,@"longitudine", nil];
            
            NetworkLoadingManager *geoUploader = [[NetworkLoadingManager alloc]init];
            NSURLRequest *request = [geoUploader createBodyWithURL:@"http://mobdev2015.com/preleva_vicinanze.php" Parameters:coordinate DataImage:nil ImageInformations:nil];
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            
            
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                NSLog(@"Entro dentro il compeltionHandler");
                if(data){
                    NSError *parseError;
                    luoghiRecenti = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                    if (luoghiRecenti) {
                        NSString *esito = [NSString stringWithString: [luoghiRecenti valueForKey:@"success"]];
                        
                        if([esito isEqualToString:@"1"]){
                            NSLog(@"%@", luoghiRecenti);
                        }
                        else{
                            // Inserire eventualmente qualcosa.
                        }
                        
                    } else NSLog(@"parseError = %@ \n", parseError);
                    
                    //NSLog(@"responseString = %@ \n", [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
                }
                
            }] resume];
    }//if
    
}



#pragma mark Metodi per la gestione del download e salvataggio dei luoghi filtrati per categorie
/*
 * Prima vediamo se va tutto bene con il codice diretto negli if, poi mano a mano spostiamo tutto in 
 * funzioni apposite.
 *
 */

- (void)prelevaVicinanze{
   
}

- (void)prelevaRecenti{
    
   }

- (void)prelevaTendenze{
    
}

- (void)prelevaMaggiormenteRecensiti{
    
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    // Determine if row is selectable based on the NSIndexPath.
    
    if(self.pageIndex==0)
        if([path row]==0)
            return nil;
    return path;
}


-(UITableViewCell *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(self.pageIndex==0){
        static NSString *simpleTableIdentifier = @"SimpleTableCell";
        Header= (UPNelleVicinanzeCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPNelleVicinanzeCell" owner:self options:nil];
        Header= [nib objectAtIndex:0];
        [self.locationManager startUpdatingLocation];
        Header.mappaLuogo.delegate=self;
        [MKMapView class];
        MKCoordinateRegion mapRegion;
        mapRegion.center =  _locationManager.location.coordinate;
        mapRegion.span.latitudeDelta = 0.001;
        mapRegion.span.longitudeDelta = 0.001;
        [Header.mappaLuogo setRegion:mapRegion animated:YES];
        return Header;
    }
        
#ifdef __IPHONE_8_0
        if(IS_OS_8_OR_LATER) {
            [self.locationManager requestWhenInUseAuthorization];
        }
#endif
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.pageIndex==0)
    return 290;
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    
    if(self.pageIndex==0){
       
            UITableViewCell*cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            }
        
        
            NSDictionary* dict = [luoghiVicini objectForKey:[NSString stringWithFormat:@"%ld",(long)[indexPath row]]];
            NSLog(@"Modifico le TableViewCell");
            NSString *longitudine=[dict objectForKey:@"Longitudine"];
            NSString *latitudine=[dict objectForKey:@"Latitudine"];
            if(longitudine!=nil && latitudine!=nil){
                cell.textLabel.text=[dict objectForKey:@"Nome"];
                cell.imageView.image =[UIImage imageNamed:@"ManEtta.png"];
                //Quando gabri mette l'immagine profilo.
                // cell.imageView.image=[UIImage imageWithData:[dict objectForKey:@"fotoProfilo"] scale:0.5];
            }
            
            
        


        
        
            return cell;
        
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
            return 140;
    }
     return 240;
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

