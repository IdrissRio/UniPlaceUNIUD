#import "AddReviewController.h"
#import "NetworkLoadingManager.h"

@interface AddReviewController ()
{
    BOOL ImageSelected;
    NSString *voto;
}
@end

@implementation AddReviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ImageSelected = NO;
    self.rateView.notSelectedImage = [UIImage imageNamed:@"vuota.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"mezza.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"piena.png"];
    self.rateView.rating = 0;
    self.rateView.editable = YES;
    self.rateView.maxRating = 5;
    self.rateView.delegate = self;
}

- (void)viewDidUnload
{
    [self setRateView:nil];
    [super viewDidUnload];
}

- (void)StarRatingView:(StarRatingView *)rateView ratingDidChange:(float)rating{
    voto = [NSString stringWithFormat:@"%f", rating];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Gestione chiamata HTTP


- (IBAction)sendButtonPressed:(id)sender {
    
    // Prelevo la data odierna
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/M/d";
    NSString *dataOdierna = [formatter stringFromDate:[NSDate date]];
    NSLog(@"data: %@", dataOdierna);
    // Dictionary contenente i campi di testo da inserire singolarmente
    // nella recensione.
    NSDictionary *testualiRecensione = [NSDictionary dictionaryWithObjectsAndKeys: dataOdierna, @"dataRecensione",
                                        self.recensioneTexfField.text, @"recensione", voto, @"voto", nil];
    NSString *url = @"http://mobdev2015.com/aggiungirecensione.php";
    NetworkLoadingManager *loader = [[NetworkLoadingManager alloc] init];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Inserimento recensione.. \n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125,50,30,30)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [alert.view addSubview:spinner];
    [spinner startAnimating];
    
    NSArray *infoImmagine = @[@"luogo", @"photo"];
    NSData *dataImmagine;
    if(ImageSelected == YES) dataImmagine = UIImageJPEGRepresentation(self.immagineRecensione.image, 0.9);
    else dataImmagine = nil;
    NSURLRequest *request = [loader createBodyWithURL:url Parameters:testualiRecensione DataImage:dataImmagine ImageInformations:infoImmagine];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    // Creo una NSURLSessionConfiguration necessaria al fine di creare una
    // NSURLSession.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Invio la richiesta vera e propria, visualizzando il risultato
    // in console.
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
        NSError *parseError;
        NSDictionary *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (datiUtente) {
            NSString *esito = [NSString stringWithString: [datiUtente objectForKey:@"success"]];
            
            if([esito isEqualToString:@"1"])
                dispatch_async(dispatch_get_main_queue(), ^{
                [self setReviewResult:1];
                });
            
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    //Inizializzo un oggetto di tipo touch contenente uno dei tocchi effettuati dall'utente preso dal metodo anyObject.
    UITouch *touch = [touches anyObject];
    
    //Se ho premuto l'immagine di default per la selezione del proprio avatar..
    if([touch view] == self.immagineRecensione){
        
        //Creo un oggetto di tipo UIImagepickerController che mi servirà per accedere alla galleria mediante il metodo
        //presentViewController:animated:completion:
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES; //L'utente potrà modificare l'immagine dalla galleria.
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //Indico come risorsa la Photo Library di iOS.
        
        //Il picker selezionato verrà visualizzato dal view Controller attuale mediante un'animazione.
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
}

/**
 @descr Metodo richiamato alla fine della selezione dell'immagine dalla galleria. Al suo interno verrà assegnata l'immagine scelta al campo imageProfileView e verrà chiusa la view di selezione dalla galleria.
 @param picker
 oggetto di tipo UIImagePickerController incaricato per scegliere l'immagine.
 @param info
 oggetto di tipo NSDictionary contenente l'immagine originale e nel nostro caso anche l'immagine modificata.
 **/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.immagineRecensione.image = info[UIImagePickerControllerEditedImage];
    ImageSelected = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



#pragma mark Implementazione metodi della classe

- (void) setReviewResult:(int)Esito{
    if(Esito == 1){
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Recensione Inserita Correttamente"
                                                                         preferredStyle:UIAlertControllerStyleAlert ];
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:
                                       ^(UIAlertAction * action)
                                       {
                                           ImageSelected = NO;
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                           //[self performSegueWithIdentifier:@"ExampleMainSegue" sender:self];
                                           
                                       }];
            [errorAlert addAction:OkAction];
            [self presentViewController:errorAlert animated:YES completion:nil];
        }];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"La recensione non è stata inserita!"
                                                                         preferredStyle:UIAlertControllerStyleAlert ];
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [errorAlert addAction:OkAction];
            [self presentViewController:errorAlert animated:YES completion:nil];
            
        }];
    }
}

@end
