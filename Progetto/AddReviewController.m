#import "AddReviewController.h"
#import "NetworkLoadingManager.h" // Fornisce l'oggetto per poter costruire il corpo delle richieste HTTP.

#import "UPViewCommento.h"
/*
 * CHE COSA MANCA: per completare l'inserimento della recensione è necessario prelevare l'utente che inserisce
 * la recensione e l'ID del luogo, con ovviamente nome e coordinate (non ne sono ancora certo). L'ID serve per
 * andare a modificare il numero di recensioni del luogo e la sua media in O(1).
 *
 */

// Utilizzo di un'anonymous category al fine di poter dichiarare variabili non accessibili da altri oggetti.
@interface AddReviewController() <UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    // Gestisce la selezione dell'immagine.
    BOOL ImageSelected;
    // Contiene il valore convertito dal numero di stelle selezionate.
    NSString *voto;
    float offset;
    __block NSMutableDictionary *recensioni;

}
@end








@implementation AddReviewController


-(void)UPSetRateView:(StarRatingView*)star editable:(BOOL)editable rating:(float)rating{
    star.notSelectedImage = [UIImage imageNamed:@"vuota.png"];
    star.fullSelectedImage = [UIImage imageNamed:@"piena.png"];
    star.editable=editable;
    star.maxRating=5;
    star.rating=rating;
    star.delegate=self;
}

-(void)loadUPLuogo{
    self.textViewRecensione.delegate=self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapGesture];
    self.immagineSottoBlur.image=[UIImage imageWithData:self.luogo.immagine];
    self.immagineSopraBlur.image=[UIImage imageWithData:self.luogo.immagine];
    self.labelNome.text=[NSString stringWithFormat:@"%@",self.luogo.nome];
    self.labelIndirizzo.text=[NSString stringWithFormat:@"%@",self.luogo.indirizzo];
    if(self.luogo.telefono!=nil)
        self.labelTelefono.text=[NSString stringWithFormat:@"%@",self.luogo.telefono];
    else
        self.labelTelefono.text=@"Numero telefonico non presente.";
    [self UPSetRateView:self.rateViewByUser editable:YES rating:0];
    self.labelMedia.text=[NSString stringWithFormat:@"%.2f ",self.luogo.media];

    
    //Gestione dei UIBarButtonItem
    UIImage *immagineCamera = [UIImage imageNamed:@"cameraIcon.png"];
    UIButton *bottoneCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottoneCamera setFrame:CGRectMake(0, 0, 35, 35)];
    [bottoneCamera setBackgroundImage:immagineCamera forState:UIControlStateNormal];
    UIImage *immagineInvia = [UIImage imageNamed:@"invia.png"];
    UIButton *bottoneInvia = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottoneInvia setFrame:CGRectMake(0, 0, 35, 35)];
    [bottoneInvia setBackgroundImage:immagineInvia forState:UIControlStateNormal];
    [bottoneCamera addTarget:self action:@selector(ActionCamera) forControlEvents:UIControlEventTouchUpInside];
    [bottoneInvia addTarget:self action:@selector(ActionInvia) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonCamera = [[UIBarButtonItem alloc] initWithCustomView:bottoneCamera];
    [barButtonCamera setTag:1];
    UIBarButtonItem *barButtonInvia = [[UIBarButtonItem alloc] initWithCustomView:bottoneInvia];
    [barButtonInvia setTag:0];
    [barButtonInvia setEnabled:NO];
    self.navigationItem.rightBarButtonItems= @[barButtonInvia,barButtonCamera];
}



/*
 * Alla pressione del tasto, verranno caricati tutti i dati relativi alla recensione mediante l'utilizzo di
 * un oggetto di tipo NetworkLoadingManager, custom, che genera una NSURLMutableRequest utilizzata da una
 * NSURLSession la quale comunica in modo vero e proprio con il server. Durante l'operazione, l'utente viene
 * informato del corso dell'operazione mediante un UIAlertController che visualizza uno spinner indicante il
 * progresso. L'esito viene visualizzato prelevando dall'array JSON mandato in risposta dal server il campo
 * opportuno.
 */



-(void)ActionInvia
{
    // Prelevo la data odierna
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/M/d";
    NSString *dataOdierna = [formatter stringFromDate:[NSDate date]];
    NSLog(@"data: %@", dataOdierna);
    
    // Creo l'UIAlertController che verrà visualizzato mentre l'operazione è in corso, munito di spinner di tipo
    // UIActivityIndicatorview
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Inserimento recensione in corso \n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Creo l'UIActivityIndicatorView che fungerà da spinner mediante un rettangolo, indicando coordinate iniziale
    // di creazione, larghezza e altezza. Verrà inoltre assegnato ad esso uno stile di visualizzazione per poi
    // essere aggiunto come subview alla view padre che è l'UIAlertController.
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125,50,30,30)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [alert.view addSubview:spinner];
    [spinner startAnimating];
    
    // Specifico il l'array contenente i file dell'immagine, l'immagine in se convertita in NSData e una stringa che
    // farà da controllo nel caso l'utente abbia selezionato un'immagine da caricare o meno. Il tutto verrà poi mandato
    // al server.
    NSArray *infoImmagine;
    NSData *dataImmagine;
    NSString *immaginePresente;
    
    // Se è stata selezionata un'immagine, la vado a prelevare altrimenti verrà messa a nil in quanto non presente.
    if(ImageSelected == YES){
        dataImmagine = UIImageJPEGRepresentation(self.immagineSopraBlur.image, 0.9);
        infoImmagine = @[@"luogo", @"photo"];
        immaginePresente = @"si";
        
    }else{
        dataImmagine = nil;
        infoImmagine = nil;
        immaginePresente = @"no";
    }
    // Dictionary contenente i campi di testo da inserire singolarmente nella recensione.
    NSDictionary *testualiRecensione =nil;
    //[NSDictionary dictionaryWithObjectsAndKeys: dataOdierna, @"dataRecensione",self.recensioneTexfField.text, @"recensione", voto, @"voto", immaginePresente, @"immaginePresente", nil];
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
                if([esito isEqualToString:@"1"]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setReviewResult:1];
                    });
                }
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

-(void)ActionCamera
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Fotocamera o Galleria?" message:@"Desideri inserire una foto dalla galleria oppure scattarla dalla fotocamera?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *fotocameraAction = [UIAlertAction actionWithTitle:@"Fotocamera" style:UIAlertActionStyleDefault handler:
                               ^(UIAlertAction * action)
                               {
                                   
                                   [self dismissViewControllerAnimated:YES completion:nil];
                                   [self performSelectorOnMainThread:@selector(immagineDaFotocamera) withObject:nil waitUntilDone:YES];
                               }];
    
    UIAlertAction *galleriaAction = [UIAlertAction actionWithTitle:@"Galleria" style:UIAlertActionStyleDefault handler:
                                   ^(UIAlertAction * action)
                                   {
                                       
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       [self performSelectorOnMainThread:@selector(immagineDaGalleria) withObject:nil waitUntilDone:YES];
                                       
                                   }];
    UIAlertAction *annulla = [UIAlertAction actionWithTitle:@"Annulla" style:UIAlertActionStyleDefault handler:
                                     ^(UIAlertAction * action)
                                     {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                         
                                         
                                     }];
    [alert addAction:fotocameraAction];
    [alert addAction:galleriaAction];
    [alert addAction:annulla];
    

}



- (void)immagineDaGalleria {
    //Creo un oggetto di tipo UIImagepickerController che mi servirà per accedere alla galleria mediante il metodo
    //presentViewController:animated:completion:
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES; //L'utente potrà modificare l'immagine dalla galleria.
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //Indico come risorsa la Photo Library di iOS.
    
    //Il picker selezionato verrà visualizzato dal view Controller attuale mediante un'animazione.
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.immagineSopraBlur.image = info[UIImagePickerControllerEditedImage];
    if(self.immagineSopraBlur.image!=self.immagineSottoBlur.image){
        for(UIBarButtonItem *rightButton in self.navigationItem.rightBarButtonItems){
            if(rightButton.tag==0){
                ImageSelected=YES;
                rightButton.enabled=YES;
            }
        }
        self.immagineSottoBlur.image=self.immagineSottoBlur.image;
    }
    self.immagineSottoBlur.image=self.immagineSopraBlur.image;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
}


- (void)immagineDaFotocamera{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if(![textView.text isEqualToString:@"Scrivi qua la tua recensione ..."]){
        for(UIBarButtonItem *rightButton in self.navigationItem.rightBarButtonItems){
            if(rightButton.tag==0){
                rightButton.enabled=YES;
            }
        }
    }
}

-(void)VisualizzaRecensioni{
    if(recensioni.count>=3){
        self.labelCaricamento.text=@"Recensioni:";
    }else{
        self.labelCaricamento.text=@"Nessuna Recensione Inserita.";
    }
    for(int i=0;i<recensioni.count;++i){
        NSDictionary* singolaRecensione = [recensioni objectForKey:[NSString stringWithFormat:@"%d",i]];
        if([singolaRecensione objectForKey:@"Descrizione"]!=nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UPViewCommento" owner:self options:nil];
            UPViewCommento* viewRecensione=[nib objectAtIndex:0];
            viewRecensione.textViewRecensione.text=[singolaRecensione objectForKey:@"Descrizione"];
            viewRecensione.labelAutore.text=[NSString stringWithFormat:@"Autore: %@",[singolaRecensione objectForKey:@"Recensitore"]];
            viewRecensione.dataRecensione.text=[NSString stringWithFormat:@"Data: %@",[singolaRecensione objectForKey:@"DataRecensione"]];
            [self UPSetRateView:viewRecensione.ratingView editable:NO rating:[[singolaRecensione objectForKey:@"Voto"]floatValue]];
            CGRect frame= viewRecensione.frame;
            frame.size.width=self.view.frame.size.width;
            frame.origin.y = offset;
            offset+=230;
            viewRecensione.frame=frame;
            [self.viewWithChild addSubview:viewRecensione];
        }
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    [self.scrollView setDelegate:self];
    [self loadUPLuogo];
    offset=590;
  

}

- (void)viewDidLayoutSubviews {
    [self.scrollView setContentSize:CGSizeMake(320, offset)];
}

- (void)viewDidUnload
{
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



#pragma mark download delle recensioni del luogo selezionato

- (void)downloadRecensioni:(int)idLuogo{
    
    // Creo l'oggetto che gestirà il download delle recensioni. L'NSDictionary contenente le informazioni da mandare
    // server sarà solamente riempito con l'id del luogo dal quale si vogliono tutte le recensioni.
    NetworkLoadingManager *recensioniDownloader = [[NetworkLoadingManager alloc]init];
    NSDictionary *parametriRecensioni = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:idLuogo], @"idLuogo", nil];
    
    // Ottengo il corpo della richiesta da dare alla NSURLSession per completare la comunicazione.
    NSURLRequest * request = [recensioniDownloader createBodyWithURL:@"http://mobdev2015.com/preleva_recensioni.php" Parameters:parametriRecensioni DataImage:nil ImageInformations:nil];
    
    // Costruisco un oggetto di tipo NSURLSessionConfiguration utile all'istanziazione di un oggetto di
    // tipo NSURLSession.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
       
        
        if(data){
            NSError *parseError;
            
            // Decodifico il JSON ricevuto in un NSArray.
            recensioni = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            
            // Se c'è qualcosa, vado a prelevare l'oggetto contenente il valore dell'esito della risposta.
            if (recensioni) {
                NSString *esito = [NSString stringWithString: [recensioni valueForKey:@"success"]];
                
                // Se l'esito è positivo, scandisco il dictionary prelevando le immagini della recensione dove presenti.
                if([esito isEqualToString:@"1"]){
                    NSLog(@"%@", recensioni );
                     [self performSelectorOnMainThread:@selector(VisualizzaRecensioni) withObject:nil waitUntilDone:YES];
                    for(int i=0; i< recensioni.count; i++){
                        
                        // Prelevo l'eventuale path all'immagine su server
                        NSString* percorsoImmagineLocale =[[recensioni objectForKey:[NSString stringWithFormat:@"%d",i]] objectForKey:@"PercorsoImmagine"];
                        
                        // Se non vale 0 o è presente, accodo all'url principale il percorso dell'immagine, senza il primo
                        // carattere indicante il puntino '.'
                        if(![percorsoImmagineLocale isEqualToString:@"0"] && percorsoImmagineLocale!=nil){
                            NSString * tmpUrlImmagine = [NSString stringWithFormat:@"http://mobdev2015.com%@", [percorsoImmagineLocale substringFromIndex:1]];
                            
                            // Nel path ottenuto rimpiazzo gli spazi con il %20 indicante pur sempre lo spazio ma per una
                            // maggiore compatibilità di decodifica tra charset del server (UTF8) e charset dell'applicazione.
                            NSString *urlImmagine = [tmpUrlImmagine stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                            
                            // Preparato il path e normalizzato, scarico l'immagine dall'url generato.
                            NSData* tmp = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlImmagine]];
                            
                            if(tmp != nil){
                                
                                // Se è stato scaricato qualcosa, aggiungo all'oggetto iterato (in posizione i) una coppia
                                // contenente l'NSData dell'immagine con la chiave FotoRecensione,
                                [[recensioni objectForKey:[NSString stringWithFormat:@"%d",i]] setObject:tmp forKey:@"FotoRecensione"];
                            }
                        }
                    }
                }
            }
        }

        
    }]resume];
    
    
    
    return;
}


#pragma mark Implementazione metodi della classe

/* Gestore dell'esito della recensione dal punto di vista degli alertView. In base all'esito fornito, 
    che può essere 0 o 1, verrà chiusa l'alertView attuale e presentato un messaggio di avvenuta conferma
    dell'inserimento della recensione o di errore.
 */
- (void) setReviewResult:(int)Esito{
    if(Esito == 1){
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Recensione Inserita Correttamente"
                                                                         preferredStyle:UIAlertControllerStyleAlert ];
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:
                                       ^(UIAlertAction * action)
                                       {
                                           
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                           
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


#pragma mark Gestione della tastiera
-(void)touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
    NSArray *subviews = [self.view subviews];
    for (id objects in subviews) {
        if ([objects isKindOfClass:[UITextView class]]) {
            UITextView *textView = objects;
            if ([objects isFirstResponder]) {
                [textView resignFirstResponder];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self downloadRecensioni:(int)self.luogo.identificativo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

-(void)dismissKeyboard
{
    
    [_textViewRecensione resignFirstResponder];
}


@end
