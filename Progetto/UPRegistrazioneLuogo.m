

#import "UPRegistrazioneLuogo.h"
#import <QuartzCore/QuartzCore.h>
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#import <CoreLocation/CoreLocation.h>
#import "UPLuogo.h"
#import "NetworkLoadingManager.h"
@interface UPRegistrazioneLuogo ()<CLLocationManagerDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate
   >{
       BOOL immagineSelezionata;
       NSArray* pickerValues;
       UIImage* immagineInserita;
       NSString* selectedPicker;

}

@property (weak, nonatomic) IBOutlet UIImageView *imageViewLuogoSottoBlur;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLuogo;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurEffect;
@property (weak, nonatomic) IBOutlet UIButton *galleriaButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

@implementation UPRegistrazioneLuogo





- (IBAction)CheckInButtonItem:(id)sender {
    
    NSString* checkName;
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Inserimento luogo .."
                                                                 preferredStyle:UIAlertControllerStyleAlert ];
    [self presentViewController:errorAlert animated:YES completion:nil];
    
    self.pickerTipologia.dataSource = self;
    self.pickerTipologia.delegate = self;
    
    NetworkLoadingManager *locationUploader = [[NetworkLoadingManager alloc]init];
    
    NSString *latitudine = [[NSString alloc] initWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
    NSString *longitudine = [[NSString alloc]initWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
    
    
    NSString *immaginePresente = [[NSString alloc]init];
    NSData *immagineLuogo;
    NSArray *infoImmagine;
    
    if(immagineSelezionata){
        immagineLuogo = UIImageJPEGRepresentation(immagineInserita, 0.9);
        infoImmagine = @[self.nomeLuogoTextField.text, @"photo"];
        immaginePresente = @"si";
    }
    else{
        immaginePresente = @"no";
        immagineLuogo = nil;
        infoImmagine = nil;
    }
    if([_nomeLuogoTextField.text  isEqual: @""])
        checkName=NULL;
    else
        checkName=[NSString stringWithString:_nomeLuogoTextField.text];
    
    NSDictionary *parametriLuogo = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    checkName, @"nome",
                                    immaginePresente, @"immaginePresente",
                                    self.indirizzoLuogoTextField.text, @"indirizzo",
                                    self.telefonoLuogoTextField.text, @"numeroTelefonico",
                                    selectedPicker, @"categoria",
                                    latitudine, @"latitudine",
                                    longitudine, @"longitudine",
                                    nil];

    
   // UPLuogo *luogoDaInserire = [[UPLuogo alloc]initWithIndirizzo:self.indirizzoLuogoTextField.text telefono:self.telefonoLuogoTextField.text nome:self.nomeLuogoTextField.text longitudine:longitudine latitudine:latitudine immagine:immagineLuogo tipologia:selectedPicker];
    
     NSURLRequest *request = [locationUploader createBodyWithURL:@"http://mobdev2015.com/aggiungiluogo.php" Parameters:parametriLuogo DataImage:immagineLuogo ImageInformations:infoImmagine];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
            NSError *parseError;
            NSDictionary *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (datiUtente) {
                NSString *esito = [NSString stringWithString: [datiUtente objectForKey:@"success"]];
                
                if([esito isEqualToString:@"1"])
                    [self dismissViewControllerAnimated:NO completion:^(void){
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                
                else
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setReviewResult:0];
                    });
            } else
                NSLog(@"parseError = %@ \n", parseError);
            
            NSLog(@"responseString = %@ \n", [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setReviewResult:0];
            });
            
        } else
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setReviewResult:0];
            });
        
        
    }] resume];
}

- (CLLocationManager *)locationManager{
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}


- (void)viewDidLoad {
    
    selectedPicker=@"Biblioteca";
    immagineSelezionata = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.luogo= [[UPLuogo alloc]init];
    pickerValues=@[@"Biblioteca",@"Pub",@"Cantina",@"Casa",@"Ristoranti",@"Discoteca",@"Aula Studio",@"Palestra", @"Diparimento",@"Mensa",@"Altro..."];
    [super viewDidLoad];
    self.pickerTipologia.delegate=self;
    self.pickerTipologia.dataSource=self;
   
    self.cameraButton.layer.cornerRadius=5;
    self.galleriaButton.layer.cornerRadius=5;
    self.cameraButton.layer.borderColor=([UIColor whiteColor].CGColor);
    self.cameraButton.layer.borderWidth=2.0f;
    self.galleriaButton.layer.borderColor=([UIColor whiteColor].CGColor);
    self.galleriaButton.layer.borderWidth=2.0f;
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
    }
#endif
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];
    
    [MKMapView class];
    MKCoordinateRegion mapRegion;
    mapRegion.center =  _locationManager.location.coordinate;
    mapRegion.span.latitudeDelta = 0.001;
    mapRegion.span.longitudeDelta = 0.001;
    self.mappaLuogo.showsUserLocation=YES;
    [self.mappaLuogo setRegion:mapRegion animated:YES];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:_locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       [placemarks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                           if([obj isKindOfClass:[CLPlacemark class]]){
                               CLPlacemark *pm = (CLPlacemark *)obj;
                               self.indirizzoLuogoTextField.text= pm.name;
                           }
                       }]; }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Fetching values for user input
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    NSString *str = [pickerValues objectAtIndex:row];
    NSLog(@"%@", str);
    selectedPicker = str;
    
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerValues.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = pickerValues[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}


// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"%@", pickerValues[row]);
    selectedPicker = pickerValues[row];
    return pickerValues[row];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark gestione galleria e fotocamera



- (IBAction)immagineDaGalleria:(UIButton *)sender {
    //Creo un oggetto di tipo UIImagepickerController che mi servirà per accedere alla galleria mediante il metodo
    //presentViewController:animated:completion:
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES; //L'utente potrà modificare l'immagine dalla galleria.
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //Indico come risorsa la Photo Library di iOS.
    
    immagineSelezionata = YES;
    //Il picker selezionato verrà visualizzato dal view Controller attuale mediante un'animazione.
    [self presentViewController:picker animated:YES completion:NULL];

}
-(void)rendiVisibileImmagini{
    _imageViewLuogoSottoBlur.hidden=NO;
        _blurEffect.hidden=NO;
        _imageViewLuogo.hidden=NO;
         self.imageViewLuogo.image = immagineInserita;
    self.imageViewLuogoSottoBlur.image=immagineInserita;
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    immagineInserita = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self rendiVisibileImmagini];
    
}


- (IBAction)immagineDaFotocamera:(UIButton *)sender {
    immagineSelezionata=YES;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];

}


#pragma mark gestione della tastiera
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) setReviewResult:(int)Esito{
    if(Esito == 1){
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Luogo inserimento correttamente"
                                                                         preferredStyle:UIAlertControllerStyleAlert ];
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [errorAlert addAction:OkAction];
            [self presentViewController:errorAlert animated:YES completion:nil];
        }];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Il luogo non è stato inserito!"
                                                                         preferredStyle:UIAlertControllerStyleAlert ];
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Errore" style:UIAlertActionStyleDefault handler:nil];
            [errorAlert addAction:OkAction];
            [self presentViewController:errorAlert animated:YES completion:nil];
            
        }];
    }
}

@end
