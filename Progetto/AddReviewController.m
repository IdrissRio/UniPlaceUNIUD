#import "AddReviewController.h"
#import "NetworkLoadingManager.h" // Fornisce l'oggetto per poter costruire il corpo delle richieste HTTP.

/*
 * CHE COSA MANCA: per completare l'inserimento della recensione è necessario prelevare l'utente che inserisce
 * la recensione e l'ID del luogo, con ovviamente nome e coordinate (non ne sono ancora certo). L'ID serve per
 * andare a modificare il numero di recensioni del luogo e la sua media in O(1).
 *
 */

// Utilizzo di un'anonymous category al fine di poter dichiarare variabili non accessibili da altri oggetti.
@interface AddReviewController ()
{
    // Gestisce la selezione dell'immagine.
    BOOL ImageSelected;
    // Contiene il valore convertito dal numero di stelle selezionate.
    NSString *voto;
}
@end

@implementation AddReviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // Per ora non ho selezionato nessuna immagine.
    ImageSelected = NO;
    
    /*
     * Inizializzazione della view relativa al voto del luogo: assegno l'immagine relativa alla stella piena (selezionata)
     * o vuota (non selezionata), il voto iniziale, quello massimo, il suo delegate (che è la view stessa in quanto nell'header
     * è già stato indicato l'utilizzo del delegate apposito), e il fatto che sia modificabile nel suo valore.
     */
    self.rateView.notSelectedImage = [UIImage imageNamed:@"vuota.png"];
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

/*
 * Questo metodo viene richiamato non appena l'utente seleziona un voto diverso da quello precedente. 
 * Esso non farà altro che andare a modificare il valore della variabile globale voto, in modo tale
 * da essere accessibile ovunque nella view.
 */
- (void)StarRatingView:(StarRatingView *)rateView ratingDidChange:(float)rating{
    voto = [NSString stringWithFormat:@"%f", rating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark Gestione chiamata HTTP


/*
 * Alla pressione del tasto, verranno caricati tutti i dati relativi alla recensione mediante l'utilizzo di
 * un oggetto di tipo NetworkLoadingManager, custom, che genera una NSURLMutableRequest utilizzata da una 
 * NSURLSession la quale comunica in modo vero e proprio con il server. Durante l'operazione, l'utente viene
 * informato del corso dell'operazione mediante un UIAlertController che visualizza uno spinner indicante il
 * progresso. L'esito viene visualizzato prelevando dall'array JSON mandato in risposta dal server il campo
 * opportuno.
 */

- (IBAction)sendButtonPressed:(id)sender {
    
    // Prelevo la data odierna
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/M/d";
    NSString *dataOdierna = [formatter stringFromDate:[NSDate date]];
    NSLog(@"data: %@", dataOdierna);
    
    // Creo l'UIAlertController che verrà visualizzato mentre l'operazione è in corso, munito di spinner di tipo
    // UIActivityIndicatorview
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Inserimento recensione in corso \n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125,50,30,30)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [alert.view addSubview:spinner];
    [spinner startAnimating];
    
    // array contenente il nome testuale del file e il tag necessario per poter essere passato in POST.
    NSArray *infoImmagine;
    NSData *dataImmagine;
    NSString *immaginePresente;
    // Se è stata selezionata un'immagine, la vado a preparare dalla property apposta, altrimenti verrà messa a nil.
    if(ImageSelected == YES){
        dataImmagine = UIImageJPEGRepresentation(self.immagineRecensione.image, 0.9);
        infoImmagine = @[@"luogo", @"photo"];
        immaginePresente = @"si";
        
    }else{
        dataImmagine = nil;
        infoImmagine = nil;
        immaginePresente = @"no";
    }
    // Dictionary contenente i campi di testo da inserire singolarmente nella recensione.
    NSDictionary *testualiRecensione = [NSDictionary dictionaryWithObjectsAndKeys: dataOdierna, @"dataRecensione",
                                        self.recensioneTexfField.text, @"recensione", voto, @"voto", immaginePresente, @"immaginePresente", nil];
    NSString *url = @"http://mobdev2015.com/aggiungirecensione.php";
    NetworkLoadingManager *loader = [[NetworkLoadingManager alloc] init];

    // Creo la NSURLRequest mediante il metodo fornito dall'oggetto loader di tipo NetworkLoadingManager.
    NSURLRequest *request = [loader createBodyWithURL:url Parameters:testualiRecensione DataImage:dataImmagine ImageInformations:infoImmagine];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    // Creo una NSURLSessionConfiguration necessaria al fine di creare una NSURLSession per poter poi comunicare
    // con il servcer.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Invio la richiesta vera e propria, visualizzando il risulta in console.
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
        NSError *parseError;
        NSDictionary *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            // Se ho ricevuto qualcosa in risposta dal server e sono riuscito a convertirlo da JSON ad array
            if (datiUtente) {
            NSString *esito = [NSString stringWithString: [datiUtente objectForKey:@"success"]];
            
            // Se l'esito della stringa adibita è pari a 1, invoco il metodo delegato nel main thread
            // che in base al parametro, indicato da un numero che può essere 0 oppure 1, visualizzerà o
            // meno un messaggio di errore.
            if([esito isEqualToString:@"1"])
                dispatch_async(dispatch_get_main_queue(), ^{
                [self setReviewResult:1];
                });
            
            else
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setReviewResult:0];
                });
        
        // Se la conversione è fallita, verrà stampato a console il messaggio di errore con quanto scaricato
        // dal server, indicando comunque che c'è stato un errore nella comunicazione.
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

/*
 @descr Metodo richiamato alla fine della selezione dell'immagine dalla galleria. Al suo interno verrà assegnata l'immagine scelta al campo imageProfileView e verrà chiusa la view di selezione dalla galleria.
 @param picker
 oggetto di tipo UIImagePickerController incaricato per scegliere l'immagine.
 @param info
 oggetto di tipo NSDictionary contenente l'immagine originale e nel nostro caso anche l'immagine modificata.
 */
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
