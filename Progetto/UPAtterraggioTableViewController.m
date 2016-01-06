//
//  UPAtterraggioTableViewController.m
//  Progetto
//
//  Created by IdrissRio on 16/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPAtterraggioTableViewController.h"
#import "UPCustomSectionCell.h"
#import "UPAltreCategorieCell.h"
#import "UPListaLuoghiNelleVicinanzeTableViewCell.h"
#import "UPNelleVicinanzeCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "NetworkLoadingManager.h"
#import "AddReviewController.h"
#import "UPLuogo.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface UPAtterraggioTableViewController ()<CLLocationManagerDelegate>{
    __block NSMutableDictionary *luoghiVicini;
    __block NSMutableDictionary *luoghiRecenti;
    __block NSMutableDictionary *luoghiRecensiti;
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
    [self mapView:mapView didSelectAnnotationView:view];
    NSMutableDictionary * dict= [self cercaCorrispondenzaConTitolo:lastTouchd];
    imageView.image = [UIImage imageWithData:[dict objectForKey:@"FotoProfilo"]];
    view.leftCalloutAccessoryView = imageView;
    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoDark];
    return view;
}


//Preparo il luogo da mandare nell'altra view.
- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control{
    if(self.pageIndex>0){
        [self mapView:mapView didSelectAnnotationView:view];
        
    }
        NSDictionary* dict= [self cercaCorrispondenzaConTitolo:lastTouchd];
        //Preparo l'oggetto da mandare nella pagina recensioni
        if(dict!=nil){
            preparedForSegue=[[UPLuogo alloc]initWithIndirizzo:[dict objectForKey:@"Indirizzo"] telefono:[dict objectForKey:@"Telefono"] nome:[dict objectForKey:@"Nome"] longitudine:[dict objectForKey:@"Longitudine"] latitudine:[dict objectForKey:@"Latitudine"] immagine:[dict objectForKey:@"FotoProfilo"] tipologia:[dict objectForKey:@"Categoria"] media:[[dict objectForKey:@"Media"]floatValue] andID:[[dict objectForKey:@"ID"] integerValue]];
            [self performSegueWithIdentifier:@"luogoInfoSegue" sender:self];
        }

}




- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(reloadDownloadDati)
                  forControlEvents:UIControlEventValueChanged];
    [Header.mappaLuogo setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadDownloadDati{
    [self downloadDati];
    [self.tableView reloadData];
    
    [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1];
}

-(void)downloadDati{
    luoghiVicini=nil;
    luoghiRecenti=nil;
    luoghiRecensiti=nil;
    
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
                luoghiVicini = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                if (luoghiVicini) {
                    NSString *esito = [NSString stringWithString: [luoghiVicini valueForKey:@"success"]];
                    
                    if([esito isEqualToString:@"1"]){
                        NSLog(@"%@", luoghiVicini );
                        
                        for(int i=0;i<luoghiVicini.count;i++){
                            NSString* percorsoImmagineLocale =[[luoghiVicini objectForKey:[NSString stringWithFormat:@"%d",i]] objectForKey:@"PercorsoImmagine"];
                            if(![percorsoImmagineLocale isEqualToString:@"0"] && percorsoImmagineLocale!=nil){
                                NSString * tmpUrlImmagine = [NSString stringWithFormat:@"http://mobdev2015.com%@", [percorsoImmagineLocale substringFromIndex:1]];
                                
                                NSString *urlImmagine=[tmpUrlImmagine stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                                NSData* tmp=[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImmagine]];
                                if(tmp!=nil){
                                    [[luoghiVicini objectForKey:[NSString stringWithFormat:@"%d",i]] setObject:tmp forKey:@"FotoProfilo"];
                                }
                            }
                        }
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
                luoghiRecenti = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                if (luoghiRecenti) {
                    NSString *esito = [NSString stringWithString: [luoghiRecenti valueForKey:@"success"]];
                    
                    if([esito isEqualToString:@"1"]){
                        NSLog(@"%@", luoghiRecenti);
                        for(int i=0;i<luoghiRecenti.count;i++){
                            NSString* percorsoImmagineLocale =[[luoghiRecenti objectForKey:[NSString stringWithFormat:@"%d",i]] objectForKey:@"PercorsoImmagine"];
                            if(![percorsoImmagineLocale isEqualToString:@"0"] && percorsoImmagineLocale!=nil){
                                NSString * tmpUrlImmagine = [NSString stringWithFormat:@"http://mobdev2015.com%@", [percorsoImmagineLocale substringFromIndex:1]];
                                
                                NSString *urlImmagine=[tmpUrlImmagine stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                                NSData* tmp=[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImmagine]];
                                if(tmp!=nil){
                                    [[luoghiRecenti objectForKey:[NSString stringWithFormat:@"%d",i]] setObject:tmp forKey:@"FotoProfilo"];
                                }
                            }
                        }
                        [self performSelectorOnMainThread:@selector(inserisciNotation) withObject:nil waitUntilDone:YES];
                    }
                } else NSLog(@"parseError = %@ \n", parseError);
                
            }
            
        }] resume];
    }//if
    
    
    if(self.pageIndex == 2){
        
        NetworkLoadingManager *recentUploader = [[NetworkLoadingManager alloc]init];
        NSURLRequest *request = [recentUploader createBodyWithURL:@"http://mobdev2015.com/preleva_tendenze.php" Parameters:nil DataImage:nil ImageInformations:nil];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(data){
                NSError *parseError;
                luoghiRecensiti = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                if (luoghiRecensiti) {
                    NSString *esito = [NSString stringWithString: [luoghiRecensiti valueForKey:@"success"]];
                    
                    if([esito isEqualToString:@"1"]){
                        NSLog(@"%@", luoghiRecensiti);
                        for(int i=0;i<luoghiRecensiti.count;i++){
                            NSString* percorsoImmagineLocale =[[luoghiRecensiti objectForKey:[NSString stringWithFormat:@"%d",i]] objectForKey:@"PercorsoImmagine"];
                            if(![percorsoImmagineLocale isEqualToString:@"0"] && percorsoImmagineLocale!=nil){
                                NSString * tmpUrlImmagine = [NSString stringWithFormat:@"http://mobdev2015.com%@", [percorsoImmagineLocale substringFromIndex:1]];
                                
                                NSString *urlImmagine=[tmpUrlImmagine stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                                NSData* tmp=[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImmagine]];
                                if(tmp!=nil){
                                    [[luoghiRecensiti objectForKey:[NSString stringWithFormat:@"%d",i]] setObject:tmp forKey:@"FotoProfilo"];
                                }
                            }
                        }
                        [self performSelectorOnMainThread:@selector(inserisciNotation) withObject:nil waitUntilDone:YES];
                        
                    }
                    
                    
                } else NSLog(@"parseError = %@ \n", parseError);
                
            }
            
        }] resume];
        
    }//if
    
    if(self.pageIndex == 3){
        NetworkLoadingManager *recentUploader = [[NetworkLoadingManager alloc]init];
        NSURLRequest *request = [recentUploader createBodyWithURL:@"http://mobdev2015.com/preleva_recensiti.php" Parameters:nil DataImage:nil ImageInformations:nil];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(data){
                NSError *parseError;
                luoghiRecensiti = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                if (luoghiRecensiti) {
                    NSString *esito = [NSString stringWithString: [luoghiRecensiti valueForKey:@"success"]];
                    
                    if([esito isEqualToString:@"1"]){
                        NSLog(@"%@", luoghiRecensiti);
                        for(int i=0;i<luoghiRecensiti.count;i++){
                            NSString* percorsoImmagineLocale =[[luoghiRecensiti objectForKey:[NSString stringWithFormat:@"%d",i]] objectForKey:@"PercorsoImmagine"];
                            if(![percorsoImmagineLocale isEqualToString:@"0"] && percorsoImmagineLocale!=nil){
                                NSString * tmpUrlImmagine = [NSString stringWithFormat:@"http://mobdev2015.com%@", [percorsoImmagineLocale substringFromIndex:1]];
                                
                                NSString *urlImmagine=[tmpUrlImmagine stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                                NSData* tmp=[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImmagine]];
                                if(tmp!=nil){
                                    [[luoghiRecensiti  objectForKey:[NSString stringWithFormat:@"%d",i]] setObject:tmp forKey:@"FotoProfilo"];
                                }
                            }
                        }
                        [self performSelectorOnMainThread:@selector(inserisciNotation) withObject:nil waitUntilDone:YES];
                        
                    }
                    
                } else NSLog(@"parseError = %@ \n", parseError);
                
            }
            
        }] resume];
        
    }//if

    
    
    

}
- (void)viewWillAppear:(BOOL)animated{
    [self downloadDati];
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

-(void)visualizzaRecenti{
    for(int i=0;i<luoghiRecenti.count;++i){
        NSDictionary* dict = [luoghiRecenti objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSString *longitudine=[dict objectForKey:@"Longitudine"];
        NSString *latitudine=[dict objectForKey:@"Latitudine"];
        if(longitudine!=nil && latitudine!=nil){
            UPAltreCategorieCell* cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake([latitudine doubleValue],[longitudine doubleValue]);
            //Ora Focalizzo la mappa sul punto newCenter
            MKCoordinateRegion mapRegion;
            mapRegion.center = newCenter;
            mapRegion.span.latitudeDelta = 0.001;
            mapRegion.span.longitudeDelta = 0.001;
            [cell.mappaLuogo setRegion:mapRegion animated:YES];
            //Inserisco un MKpointAnnotation nella mappa nel punto desiderato;
            MKPointAnnotation * point= [[MKPointAnnotation  alloc]init];
            
            point.coordinate =newCenter;
            point.title=[dict objectForKey:@"Nome"];
            NSString* indirizzo=[dict objectForKey:@"Indirizzo"];
            if(indirizzo!=nil)
                point.subtitle=[NSString stringWithFormat:@"%@",indirizzo];
            [annotationPoint addObject:point];
            [cell.mappaLuogo addAnnotation:point];
            cell.mappaLuogo.delegate=self;
            [cell.mappaLuogo selectAnnotation:point animated:YES];
            cell.indirizzoLuogo.text=[NSString stringWithFormat:@"%@ - %@",[dict objectForKey:@"Nome"],[dict objectForKey:@"Indirizzo"]];
        }
    }
}

- (void)prelevaTendenze{
    
}
-(void)visualizzaDiTendenza{
    for(int i=0;i<luoghiRecensiti.count;++i){
        NSDictionary* dict = [luoghiRecensiti objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSString *longitudine=[dict objectForKey:@"Longitudine"];
        NSString *latitudine=[dict objectForKey:@"Latitudine"];
        if(longitudine!=nil && latitudine!=nil){
            UPAltreCategorieCell* cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake([latitudine doubleValue],[longitudine doubleValue]);
            //Ora Focalizzo la mappa sul punto newCenter
            MKCoordinateRegion mapRegion;
            mapRegion.center = newCenter;
            mapRegion.span.latitudeDelta = 0.001;
            mapRegion.span.longitudeDelta = 0.001;
            [cell.mappaLuogo setRegion:mapRegion animated:YES];
            //Inserisco un MKpointAnnotation nella mappa nel punto desiderato;
            MKPointAnnotation * point= [[MKPointAnnotation  alloc]init];
            
            point.coordinate =newCenter;
            point.title=[dict objectForKey:@"Nome"];
            NSString* indirizzo=[dict objectForKey:@"Indirizzo"];
            if(indirizzo!=nil)
                point.subtitle=[NSString stringWithFormat:@"%@",indirizzo];
            [annotationPoint addObject:point];
            [cell.mappaLuogo addAnnotation:point];
            cell.mappaLuogo.delegate=self;
            [cell.mappaLuogo selectAnnotation:point animated:YES];
            cell.indirizzoLuogo.text=[NSString stringWithFormat:@"%@ - %@",[dict objectForKey:@"Nome"],[dict objectForKey:@"Indirizzo"]];
        }
    }
    
}

- (void)prelevaMaggiormenteRecensiti{
    
}


-(void)visualizzaMaggiormenteRecensiti{
    for(int i=0;i<luoghiRecensiti.count;++i){
        NSDictionary* dict = [luoghiRecensiti objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSString *longitudine=[dict objectForKey:@"Longitudine"];
        NSString *latitudine=[dict objectForKey:@"Latitudine"];
        if(longitudine!=nil && latitudine!=nil){
            UPAltreCategorieCell* cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake([latitudine doubleValue],[longitudine doubleValue]);
            //Ora Focalizzo la mappa sul punto newCenter
            MKCoordinateRegion mapRegion;
            mapRegion.center = newCenter;
            mapRegion.span.latitudeDelta = 0.001;
            mapRegion.span.longitudeDelta = 0.001;
            [cell.mappaLuogo setRegion:mapRegion animated:YES];
            //Inserisco un MKpointAnnotation nella mappa nel punto desiderato;
            MKPointAnnotation * point= [[MKPointAnnotation  alloc]init];
            point.coordinate =newCenter;
            point.title=[dict objectForKey:@"Nome"];
            NSString* indirizzo=[dict objectForKey:@"Indirizzo"];
            if(indirizzo!=nil)
                point.subtitle=[NSString stringWithFormat:@"%@",indirizzo];
            [annotationPoint addObject:point];
            cell.mappaLuogo.delegate=self;
            [cell.mappaLuogo addAnnotation:point];
            [cell.mappaLuogo selectAnnotation:point animated:YES];
            cell.indirizzoLuogo.text=[NSString stringWithFormat:@"%@ - %@",[dict objectForKey:@"Nome"],[dict objectForKey:@"Indirizzo"]];
        }
    }
    
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
-(NSMutableDictionary *)cercaCorrispondenzaConTitolo:(NSString *)titolo{
    NSMutableDictionary* tmp;
    if(self.pageIndex==0){
        tmp=luoghiVicini;
    }else if(self.pageIndex==1){
        tmp=luoghiRecenti;
    }else if(self.pageIndex==2){
        tmp=luoghiRecensiti;
    }else if(self.pageIndex==3){
        tmp=luoghiRecensiti;
    }

    for(int i=0;i<tmp.count;++i){
        NSMutableDictionary* dict = [tmp objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSString*placeTitle=[dict objectForKey:@"Nome"];
        if([placeTitle isEqualToString:titolo]){
            return dict;
        
    }
    }
    
    
    return nil;
}

-(void)inserisciNotation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if(self.pageIndex==0){
        annotationPoint=[[NSMutableArray alloc]init];
        Header.mappaLuogo.delegate=self;
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
        
        for(int i=0;i<luoghiVicini.count;i++){
            NSDictionary* dict = [luoghiVicini objectForKey:[NSString stringWithFormat:@"%d",i]];
            NSLog(@"Modifico le TableViewCell");
            NSString *longitudine=[dict objectForKey:@"Longitudine"];
            NSString *latitudine=[dict objectForKey:@"Latitudine"];
            if(longitudine!=nil && latitudine!=nil){
                UPListaLuoghiNelleVicinanzeTableViewCell* cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.labelNome.text=[NSString stringWithFormat:@"Nome: %@",[dict objectForKey:@"Nome"]];
                cell.labelIndirizzo.text=[NSString stringWithFormat:@"Indirizzo: %@",[dict objectForKey:@"Indirizzo"]];
                NSString* tel=[dict objectForKey:@"NumeroTelefonico"];
                if(![tel isEqualToString:@""])
                    cell.labelTelefono.text=[NSString stringWithFormat:@"Tel: %@",tel];
                else
                    cell.labelTelefono.text=@"Nessun numero di Telefono Registrato";
                cell.immagineLuogo.image =[UIImage imageWithData:[dict objectForKey:@"FotoProfilo"]];
                cell.immagineLuogo.layer.cornerRadius=cell.immagineLuogo.frame.size.width/2;
                cell.immagineLuogo.layer.borderColor=[UIColor whiteColor].CGColor;
                cell.immagineLuogo.layer.borderWidth=2.0f;
                cell.immagineLuogo.clipsToBounds=YES;
                cell.immagineLuogo.hidden=NO;
                [cell.indicatorActivity stopAnimating];
                [cell.indicatorActivity setHidden:YES];
            }
        }
    }
    
    if(self.pageIndex==1){
        [self visualizzaRecenti];
    }
    if(self.pageIndex==2){
        [self visualizzaDiTendenza];
    }
    if(self.pageIndex==3){
        [self visualizzaMaggiormenteRecensiti];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}



#pragma mark Gestione Tipo, Grandezza e Contenuto TableviewCell


//Determino quali sono le cell selezionabili. In questo caso Tutte.
- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    if(self.pageIndex==0){
        return path;
    }
    return nil;
}

//Customizzo la mappa nell'Header.
-(UITableViewCell *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
    }
#endif
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    if(self.pageIndex==0){
        
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
    if (self.pageIndex==1) {
        UPCustomSectionCell* cell=(UPCustomSectionCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPCustomSection" owner:self options:nil];
        cell= [nib objectAtIndex:0];
        
        cell.labelTitolo.text=@"Luoghi Nuovi";
        return cell;
    }
    if (self.pageIndex==2) {
        UPCustomSectionCell* cell=(UPCustomSectionCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPCustomSection" owner:self options:nil];
        cell= [nib objectAtIndex:0];
        
        cell.labelTitolo.text=@"Di Tendenza";
        return cell;
    }
    if (self.pageIndex==3) {
        UPCustomSectionCell* cell=(UPCustomSectionCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPCustomSection" owner:self options:nil];
        cell= [nib objectAtIndex:0];
        cell.labelTitolo.text=@"Più Recensiti";
        return cell;
    }
    
    
    
    return nil;
}


//Gestico la grandezza dell'Header. La prima mappa che viene visualizzata nel pageIndex==0 è una section.
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.pageIndex==0)
        return 290;
    return 60;
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

        NSLog(@"Modifico le TableViewCell UPlistaLuoghiNelleVicinanze");
        NSString *longitudine=[dict objectForKey:@"Longitudine"];
        NSString *latitudine=[dict objectForKey:@"Latitudine"];
        //Controllo che esistano la longitudine e latitudine in quanto nella string JSON ci sono dati relativi al successo della query.
        if(longitudine!=nil && latitudine!=nil){
            cell.labelNome.text=[NSString stringWithFormat:@"Nome: %@",[dict objectForKey:@"Nome"]];
            cell.labelIndirizzo.text=[NSString stringWithFormat:@"Indirizzo: %@",[dict objectForKey:@"Indirizzo"]];
            NSString* tel=[dict objectForKey:@"NumeroTelefonico"];
            if(![tel isEqualToString:@""])
                cell.labelTelefono.text=[NSString stringWithFormat:@"Tel: %@",tel];
            else
                cell.labelTelefono.text=@"Nessun numero di Telefono Registrato";
            //Se l'utente non ha inserito alcuna immagine profilo per UPLuogo, dovremmo  metterci un placeholder con il logo di uniplace
            cell.immagineLuogo.image =[UIImage imageWithData:[dict objectForKey:@"FotoProfilo"]];
            cell.immagineLuogo.layer.cornerRadius=cell.immagineLuogo.frame.size.width/2;
            cell.immagineLuogo.layer.borderColor=[UIColor whiteColor].CGColor;
            cell.immagineLuogo.layer.borderWidth=2.0f;
            cell.immagineLuogo.clipsToBounds=YES;
            [cell.indicatorActivity stopAnimating];
            [cell.indicatorActivity setHidden:YES];
            
            
        }
        return cell;
        
    }else if(self.pageIndex==1){
        UPAltreCategorieCell *cell = (UPAltreCategorieCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPAltreCategorieCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        NSMutableDictionary* dict =[[NSMutableDictionary alloc]initWithDictionary:[luoghiRecenti objectForKey:[NSString stringWithFormat:@"%ld",(long)[indexPath row]]]];
        NSLog(@"Modifico le TableViewCell UPAltreCategorieCell");
        NSString *longitudine=[dict objectForKey:@"Longitudine"];
        NSString *latitudine=[dict objectForKey:@"Latitudine"];
        if(longitudine!=nil && latitudine!=nil){
            CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake([latitudine doubleValue],[longitudine doubleValue]);
            //Ora Focalizzo la mappa sul punto newCenter
            MKCoordinateRegion mapRegion;
            mapRegion.center = newCenter;
            mapRegion.span.latitudeDelta = 0.001;
            mapRegion.span.longitudeDelta = 0.001;
            [cell.mappaLuogo setRegion:mapRegion animated:YES];
            //Inserisco un MKpointAnnotation nella mappa nel punto desiderato;
            MKPointAnnotation * point= [[MKPointAnnotation  alloc]init];
            point.coordinate =newCenter;
            point.title=[dict objectForKey:@"Nome"];
            NSString* indirizzo=[dict objectForKey:@"Indirizzo"];
            if(indirizzo!=nil)
                point.subtitle=[NSString stringWithFormat:@"%@",indirizzo];
            [annotationPoint addObject:point];
            [cell.mappaLuogo addAnnotation:point];
            cell.mappaLuogo.delegate=self;
            [cell.mappaLuogo selectAnnotation:point animated:YES];
            
            cell.indirizzoLuogo.text=[NSString stringWithFormat:@"%@ - %@",[dict objectForKey:@"Nome"],[dict objectForKey:@"Indirizzo"]];
        }
        return cell;
    }else if(self.pageIndex==2){
        UPAltreCategorieCell *cell = (UPAltreCategorieCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPAltreCategorieCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        NSMutableDictionary* dict =[[NSMutableDictionary alloc]initWithDictionary:[luoghiRecensiti objectForKey:[NSString stringWithFormat:@"%ld",(long)[indexPath row]]]];
        NSLog(@"Modifico le TableViewCell UPAltreCategorieCell");
        NSString *longitudine=[dict objectForKey:@"Longitudine"];
        NSString *latitudine=[dict objectForKey:@"Latitudine"];
        if(longitudine!=nil && latitudine!=nil){
            CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake([latitudine doubleValue],[longitudine doubleValue]);
            //Ora Focalizzo la mappa sul punto newCenter
            MKCoordinateRegion mapRegion;
            mapRegion.center = newCenter;
            mapRegion.span.latitudeDelta = 0.001;
            mapRegion.span.longitudeDelta = 0.001;
            [cell.mappaLuogo setRegion:mapRegion animated:YES];
            //Inserisco un MKpointAnnotation nella mappa nel punto desiderato;
            MKPointAnnotation * point= [[MKPointAnnotation  alloc]init];
            
            point.coordinate =newCenter;
            point.title=[dict objectForKey:@"Nome"];
            NSString* indirizzo=[dict objectForKey:@"Indirizzo"];
            if(indirizzo!=nil)
                point.subtitle=[NSString stringWithFormat:@"%@",indirizzo];
            [annotationPoint addObject:point];
            [cell.mappaLuogo addAnnotation:point];
            cell.mappaLuogo.delegate=self;
            [cell.mappaLuogo selectAnnotation:point animated:YES];
            cell.indirizzoLuogo.text=[NSString stringWithFormat:@"%@ - %@",[dict objectForKey:@"Nome"],[dict objectForKey:@"Indirizzo"]];
        }
        return cell;
        
    }else if (self.pageIndex==3){
        UPAltreCategorieCell *cell = (UPAltreCategorieCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPAltreCategorieCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        NSMutableDictionary* dict =[[NSMutableDictionary alloc]initWithDictionary:[luoghiRecensiti objectForKey:[NSString stringWithFormat:@"%ld",(long)[indexPath row]]]];
        NSLog(@"Modifico le TableViewCell UPAltreCategorieCell");
        NSString *longitudine=[dict objectForKey:@"Longitudine"];
        NSString *latitudine=[dict objectForKey:@"Latitudine"];
        if(longitudine!=nil && latitudine!=nil){
            CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake([latitudine doubleValue],[longitudine doubleValue]);
            //Ora Focalizzo la mappa sul punto newCenter
            MKCoordinateRegion mapRegion;
            mapRegion.center = newCenter;
            mapRegion.span.latitudeDelta = 0.001;
            mapRegion.span.longitudeDelta = 0.001;
            [cell.mappaLuogo setRegion:mapRegion animated:YES];
            //Inserisco un MKpointAnnotation nella mappa nel punto desiderato;
            MKPointAnnotation * point= [[MKPointAnnotation  alloc]init];
            point.coordinate =newCenter;
            point.title=[dict objectForKey:@"Nome"];
            NSString* indirizzo=[dict objectForKey:@"Indirizzo"];
            if(indirizzo!=nil)
                point.subtitle=[NSString stringWithFormat:@"%@",indirizzo];
            [annotationPoint addObject:point];
            [cell.mappaLuogo addAnnotation:point];
            cell.mappaLuogo.delegate=self;
            [cell.mappaLuogo selectAnnotation:point animated:YES];
            cell.indirizzoLuogo.text=[NSString stringWithFormat:@"%@ - %@",[dict objectForKey:@"Nome"],[dict objectForKey:@"Indirizzo"]];
        }
        return cell;
        
    }
    return nil;
}

//Modifica la gandezza delle Celle in base all'indexPath e al pageIndex

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.pageIndex==0){
        return 122;
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



- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if([segue.identifier isEqualToString:@"luogoInfoSegue"]){
         if([segue.destinationViewController isKindOfClass:[AddReviewController class]]){
             AddReviewController* svc=(AddReviewController *)segue.destinationViewController;
             svc.luogo=preparedForSegue;
         }
     }
 }



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

