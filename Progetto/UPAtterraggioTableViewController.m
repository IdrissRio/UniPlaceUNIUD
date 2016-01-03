//
//  UPAtterraggioTableViewController.m
//  Progetto
//
//  Created by IdrissRio on 16/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPAtterraggioTableViewController.h"
#import "UPAltreCategorieCell.h"
#import "UPListaLuoghiNelleVicinanzeTableViewCell.h"
#import "UPNelleVicinanzeCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "NetworkLoadingManager.h"
#import "UPLuogo.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface UPAtterraggioTableViewController ()<CLLocationManagerDelegate>{
    __block NSMutableDictionary *luoghiVicini;
    __block NSArray *luoghiRecenti;
    __block NSArray *luoghiRecensiti;
    UPNelleVicinanzeCell* Header;
    NSMutableArray * annotationPoint;
    NSString * lastTouchd;
    NSData* lastTouchdImage;
    UPLuogo* preparedForSegue;
}

- (void)prelevaRecenti;
- (void)prelevaVicinanze;
- (void)prelevaMaggiormenteRecensiti;
- (void)prelevaTendenze;
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

@implementation UPAtterraggioTableViewController






- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id<MKAnnotation> annSelected = view.annotation;
    if ([annSelected isKindOfClass:[MKPointAnnotation class]])
    {
        MKPointAnnotation *dm = (MKPointAnnotation *)annSelected;
        NSLog(@"Pin touched: title=%@", dm.title);
        lastTouchd=dm.title;
    }
}


# pragma mark Gestione MKAnnotationView e PrePrepareForSegue
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation{
    NSString *AnnotationIdentifier = [NSString stringWithFormat:@"%@",[annotation title]];
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if(!view){
        view= [[MKPinAnnotationView alloc]initWithAnnotation:annotation	 reuseIdentifier:AnnotationIdentifier];
        view.canShowCallout=YES;
    }
    view.annotation = annotation;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    
    //Serve foto Luogo se esiste, altrimenti ci mettiamo l'icona di UP.
    NSDictionary * dict= [self cercaCorrispondenzaConTitolo:lastTouchd];
    
    imageView.image = [UIImage imageWithData:[dict objectForKey:@"FotoProfilo"]];
    view.leftCalloutAccessoryView = imageView;
    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoDark];
    ;
    return view;}


//Preparo il luogo da mandare nell'altra view.
- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control{
    NSDictionary* dict= [self cercaCorrispondenzaConTitolo:lastTouchd];
    //Preparo l'oggetto da mandare nella pagina recensioni
    if(dict!=nil){
        preparedForSegue=[[UPLuogo alloc]initWithIndirizzo:[dict objectForKey:@"Indirizzo"] telefono:[dict objectForKey:@"Telefono"] nome:[dict objectForKey:@"Nome"] longitudine:[dict objectForKey:@"Longitudine"] latitudine:[dict objectForKey:@"Latitudine"] immagine:UIImagePNGRepresentation([view image]) tipologia:[dict objectForKey:@"Categoria"]];
    }
}




- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NetworkLoadingManager *recentUploader = [[NetworkLoadingManager alloc]init];
        NSURLRequest *request = [recentUploader createBodyWithURL:@"http://mobdev2015.com/preleva_nuovi.php" Parameters:nil DataImage:nil ImageInformations:nil];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(data){
                NSError *parseError;
                luoghiRecenti = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                if (luoghiRecenti) {
                    NSString *esito = [NSString stringWithString: [luoghiRecenti valueForKey:@"success"]];
                    
                    if([esito isEqualToString:@"1"]){
                        NSLog(@"%@", luoghiRecenti);
                    }
                    
                    
                } else NSLog(@"parseError = %@ \n", parseError);
                
            }
            
        }] resume];
    }//if
    
    if(self.pageIndex == 2){
        NetworkLoadingManager *recentUploader = [[NetworkLoadingManager alloc]init];
        NSURLRequest *request = [recentUploader createBodyWithURL:@"http://mobdev2015.com/preleva_recensiti.php" Parameters:nil DataImage:nil ImageInformations:nil];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(data){
                NSError *parseError;
                luoghiRecensiti = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                if (luoghiRecensiti) {
                    NSString *esito = [NSString stringWithString: [luoghiRecensiti valueForKey:@"success"]];
                    
                    if([esito isEqualToString:@"1"]){
                        NSLog(@"%@", luoghiRecensiti);
                    }
                    
                } else NSLog(@"parseError = %@ \n", parseError);
                
            }
            
        }] resume];
        
    }//if
    
    if(self.pageIndex == 3){
        
        NetworkLoadingManager *recentUploader = [[NetworkLoadingManager alloc]init];
        NSURLRequest *request = [recentUploader createBodyWithURL:@"http://mobdev2015.com/preleva_tendenze.php" Parameters:nil DataImage:nil ImageInformations:nil];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(data){
                NSError *parseError;
                luoghiRecensiti = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                if (luoghiRecensiti) {
                    NSString *esito = [NSString stringWithString: [luoghiRecensiti valueForKey:@"success"]];
                    
                    if([esito isEqualToString:@"1"]){
                        NSLog(@"%@", luoghiRecensiti);
                    }
                    
                    
                } else NSLog(@"parseError = %@ \n", parseError);
                
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







#pragma mark Gestione MKPointAnnotation
//Se viene effettuato un tap sulla cell di un luogo, la mappa nell'header viene focalizzata su quel determinato luogo
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Controllo per non lanciare l'eccezione outOfBounds
    if([indexPath row]<=annotationPoint.count-1)
        [Header.mappaLuogo selectAnnotation:annotationPoint[[indexPath row]] animated:YES];
}

//Funzione che ritorna il Dictionary relativo al MKPointAnnotation selezionato
-(NSDictionary *)cercaCorrispondenzaConTitolo:(NSString *)titolo{
    for(int i=0;i<luoghiVicini.count;++i){
        NSDictionary* dict = [luoghiVicini objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSString*titolo=[dict objectForKey:@"Nome"];
        if([titolo isEqualToString:titolo]){
            return dict;
        }
    }
    return nil;
}

-(void)inserisciNotation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if(self.pageIndex==0){
        annotationPoint=[[NSMutableArray alloc]init];
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
                
                NSString* indirizzo=[dict objectForKey:@"Indirizzo"];
                if(indirizzo!=nil)
                    point.subtitle=[NSString stringWithFormat:@"%@",indirizzo];
                [annotationPoint addObject:point];
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
            UPListaLuoghiNelleVicinanzeTableViewCell* cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.longitudine=[longitudine doubleValue];
            cell.latitudine=[latitudine doubleValue];
            cell.labelNome.text=[dict objectForKey:@"Nome"];
            cell.immagineLuogo.image =[UIImage imageNamed:@"ManEtta.png"];
            
            // cell.imageView.image=[UIImage imageWithData:[dict objectForKey:@"fotoProfilo"] scale:0.5];
        }
        
        
        
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}



#pragma mark Gestione Tipo, Grandezza e Contenuto TableviewCell


//Determino quali sono le cell selezionabili. In questo caso Tutte.
- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    return path;
}

//Customizzo la mappa nell'Header.
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


//Gestico la grandezza dell'Header. La prima mappa che viene visualizzata nel pageIndex==0 è una section.
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.pageIndex==0)
        return 290;
    else return 0;
}


//Gestisco come vengono crete le cell in base all'indexPath e all'PageIndex
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    //se pageIndex è zero allora creo delle tableViewCell customizzate per la prima pagina del pageViewController.
    if(self.pageIndex==0){
        UPListaLuoghiNelleVicinanzeTableViewCell*cell = (UPListaLuoghiNelleVicinanzeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        //Carico gli elementi dal Nib
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPListaLuoghiNelleVicinanze" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        NSMutableDictionary* dict =[[NSMutableDictionary alloc]initWithDictionary:[luoghiVicini objectForKey:[NSString stringWithFormat:@"%ld",(long)[indexPath row]]]];
        //Debug
        NSLog(@"Modifico le TableViewCell");
        NSString *longitudine=[dict objectForKey:@"Longitudine"];
        NSString *latitudine=[dict objectForKey:@"Latitudine"];
        //Controllo che esistano la longitudine e latitudine in quanto nella string JSON ci sono dati relativi al successo della query.
        if(longitudine!=nil && latitudine!=nil){
            cell.longitudine=[longitudine doubleValue];
            cell.latitudine=[latitudine doubleValue];
            cell.labelNome.text=[dict objectForKey:@"Nome"];
            // Prelevo il percorso al database locale salvato nella chiave PercorsoImmagine all'interno
            // dell'array
            NSString *percorsoImmagineLocale = [dict objectForKey:@"PercorsoImmagine"];
            
            // Se non è stringa vuota, sarà riempita dal percorso
            if(![percorsoImmagineLocale isEqualToString:@"0"]){
                // Concateno la stringa a meno del primo simbolo (che è un punto) con la stringa indicante il link
                NSString * urlImmagine = [NSString stringWithFormat:@"http://mobdev2015.com%@", [percorsoImmagineLocale substringFromIndex:1]];
                
                // Assegno l'immagine alla UIImage designata, andando a prelevare l'NSData mediante dataWithContentsOfURL
                // e poi assegnandolo all'immagine vera e propria mediante il metodo imaageWithData
                NSData* tmp=[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImmagine]];
                if(tmp!=nil)
                    [dict setObject:tmp forKey:@"FotoProfilo"];
                cell.immagineLuogo.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImmagine]]];
            }
            else
                //Da rimpiazzare con il luogo di UNIplace
                cell.immagineLuogo.image =[UIImage imageNamed:@"ManEtta.png"];
            
            //cell.immagineLuogo.image =[UIImage imageNamed:@"ManEtta.png"];
            
            
        }
        return cell;
        
    }else{
        //Se pageIndex è diverso da 0 allora creo delle tableviewcell chiamate UPAltreCategorieCell.
        UPAltreCategorieCell *cell = (UPAltreCategorieCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPAltreCategorieCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        return cell;
        
    }
    
}

//Modifica la gandezza delle Celle in base all'indexPath e al pageIndex

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.pageIndex==0){
        return 140;
    }
    return 240;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}



#pragma mark Gestione CLLOCationManager

- (CLLocationManager *)locationManager{
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
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

