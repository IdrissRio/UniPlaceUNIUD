
#import "firstLoginScreenViewController.h"
#import "UPUniversitario.h"
#import "userInfoViewController.h"
#import "AppDelegate.h"
#import "NetworkLoadingManager.h"
@interface firstLoginScreenViewController (){
    UPUniversitario* soloFacebookUniversitario;
    NSString *serverReply;
    
}
-(void)setErrorResult;
@end

@implementation firstLoginScreenViewController

#pragma mark Login

/* Alla pressione del tasto per accedere all'applicazione, verranno prelevati i campi relativi all'username
 * e alla password in modo tale da essere mandati al server che, nel caso siano corretti, darà una risposta
 * positiva facendo si che l'utente possa accedere alle funzionalità dell'applicazione. Oltre a questo, verranno
 * inviate in risposta tutte le informazioni relative all'utente per essere salvate su database locale in modo
 * tale da non dover più chiedere un futuro accesso. In caso contrario invece, l'utente verrà informato
 * dell'insuccesso del login con messaggio e relativi campi di testo colorati in rosso.
 */
- (IBAction)loginButtonPressed:(id)sender {
    
    // Prelevo username e password inseriti dai textField salvandoli in un NSDictionary.
    NSString *user = self.usernameTextField.text;
    NSString *pass = self.passwordTextField.text;
    
    if([user isEqualToString:@""] || [pass isEqualToString:@""]){
        return;
    }
    NSDictionary *credenziali = [NSDictionary dictionaryWithObjectsAndKeys:user, @"username", pass, @"password", nil];
    
    // Creo l'UIAlertController che apparirà durante il caricamento dei dati, informando l'utente
    // dell'operazione in corso.
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Accesso in corso \n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // All'UIAlertController inserisco una subview sotto alla scritta di accesso contenente uno spinner.
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125,50,30,30)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [alert.view addSubview:spinner];
    
    // Avvio l'animazione dello spinner e visualizzo l'UIAlertController, contenente lo spinner stesso come scritto sopra.
    [spinner startAnimating];
    [self presentViewController:alert animated:YES completion:nil];
    
    // Istanzio l'oggetto uploadManager di tipo NetworkLoadingManager utilizzato per eseguire la comunicazione vera e propria
    // mediante il metodo createBodyWithURL:Parameters:DataImage: il quale date le credenziali salvate precedentemente nell'NS
    // Dictionary e il link al file delegato a gestire la richiesta su server, ritornerà un oggetto di tipo NSURLRequest che
    // conterrà il corpo vero e proprio della richiesta.
    NetworkLoadingManager * uploadManager = [[NetworkLoadingManager alloc]init];
    NSURLRequest * request  = [uploadManager createBodyWithURL:@"http://mobdev2015.com/login.php" Parameters:credenziali DataImage:nil ImageInformations:nil];
    
    // L'oggetto request verrà usato dall'oggeto di tipo NSURLSession per comunicare.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        // Istanzio un oggetto di tipo UPUniversitario che sarà riempito con tutti i dati dell'utente scaricati dal
        // server per poi essere salvato su database locale.
        UPUniversitario *universitarioLoggato = [[UPUniversitario alloc] init];
        // Oggetto di tipo NSError necessario per l'imminente decodifica da JSON a NSDictionary.
        NSError *parseError;
        
        // Codifico il JSON ottenuto dal server in un NSDictionary.
        NSDictionary *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        // Se ho ricevuto qualcosa in risposta dal server e sono riuscito a convertirlo da JSON ad array, cerco
        // il valore relativo all'esito, contraddistinto dalla chiave "success".
        if (datiUtente) {
            NSString *esito = [NSString stringWithString: [datiUtente objectForKey:@"success"]];
            
            // Se l'esito della stringa adibita è pari a 1, invoco il metodo delegato nel main thread
            // che in base al parametro, indicato da un numero che può essere 0 oppure 1, visualizzerà o
            // meno un messaggio di errore.
            if([esito isEqualToString:@"1"]){
                NSLog(@"responseObject = %@", datiUtente);
                
                // Prelevo i percorsi locali nel database dell'immagine università e immagine profilo ed entrambi i valori
                // verranno sottratti del primo carattere e concatenati ad una stringa statica indicante il link principale
                // al sito che, completato di esse, genererà un indirizzo da cui prelevare l'immagine.
                NSString *localProfilePath = [NSString stringWithString: [datiUtente objectForKey:@"immagineProfilo"]];
                NSString *localUniPath = [NSString stringWithString: [datiUtente objectForKey:@"immagineUni"]];
                
                NSString * urlProfileImage = [NSString stringWithFormat:@"http://mobdev2015.com%@", [localProfilePath substringFromIndex:1]];
                NSString * urlUniImage = [NSString stringWithFormat:@"http://mobdev2015.com%@", [localUniPath substringFromIndex:1]];
                
                /* DEBUG: stampo in consile il percorso completo
                NSLog(@"%@", urlProfileImage);
                NSLog(@"%@", urlUniImage);
                */
                
                // Assegno ogni campo dell'NSDictionary contenente la risposta in JSON all'oggetto di tipo UPUniversitario
                universitarioLoggato.nome = [datiUtente objectForKey:@"nome"];
                universitarioLoggato.cognome = [datiUtente objectForKey:@"cognome"];
                universitarioLoggato.email = [datiUtente objectForKey:@"email"];
                universitarioLoggato.nomeUtente = [datiUtente objectForKey:@"nomeUtente"];
                
                // Dai due percorsi link precedentemente costruiti, ottengo le due immagini sotto forma di NSData.
                universitarioLoggato.LogoUni = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlUniImage]];
                universitarioLoggato.fotoProfilo = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlProfileImage]];
                
                // Assegnati tutti i valori all'oggetto di tipo UPUniversitario, è possibile richiamare il metodo salvaDatiNel
                // DBnome:cognome:email:fotoProfilo:nomeUtente:universita, il quale come indicato dal nome salverà i valori
                // di questo oggetto nel db locale, sfruttando CoreData.
                [self salvaDatiNelDBnome:universitarioLoggato.nome cognome:universitarioLoggato.nome email:universitarioLoggato.email fotoProfilo:universitarioLoggato.fotoProfilo nomeUtente:universitarioLoggato.nomeUtente universita:universitarioLoggato.universita];
                
                // Ora che è stato completato il tutto, interrompo la visualizzazione
                // dell'UIAlertController ed eseguo la segue che mi porterà alla home dell'applicazione per
                // gli utenti loggati.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:alert completion:nil];
                    [self performSegueWithIdentifier:@"successfulLoginSegue" sender:self];
                });
                
              // In caso contrario, eseguo il metodo setLoginResult che, passando come parametro a zero, mostrerà un
              // messaggio di errore indicando l'errato inserimento. La necessità di eseguirlo nel main thread è data
              // dal fatto che si sta eseguendo in via generale un cambiamento all'UI, e in questo caso è richiesto
              // dagli oggetti di tipo UIAlertController per non far crashare l'applicazione.
            } else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setErrorResult];
                    
                });
                
            }
            // Se la conversione è fallita, verrà stampato a console il messaggio di errore con quanto scaricato
            // dal server, indicando comunque che c'è stato un errore nella comunicazione.
        } else
            NSLog(@"parseError = %@ \n", parseError);
        
        // DEBUG: stampo l'esito della risposta: NSLog(@"responseString = %@ \n", [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
    
    // Faccio partire il task dell'NSURLSession
    }] resume];
    
    
    
    
}


#pragma mark Metodi di routine della classe.

/*
 * Metodo richiamato in caso di inserimento non riuscito informando l'utente sia tramite messaggio relativo che
 * tramite colorazione dei campi di testo necessari per l'accesso in rosso.
 */
- (void) setErrorResult{
    
    // Chiudo l'UIAlertController in rosso e nel blocco di completamento istanzio un altro oggetto dello stesso tipo
    // inserendo un messaggio di errore e un UIAlertAction rappresentante un bottone per poter chiudere la visualizzazione
    // dell'oggetto di tipo UIAlertController appena creato.
    [self dismissViewControllerAnimated:NO completion:^{
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Username e/o password errati!"
                                                                     preferredStyle:UIAlertControllerStyleAlert ];
        UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        
        // Aggiungo all'UIAlertController l'UIAlertAction, facendo il ruolo del parent nei suoi confronti.
        [errorAlert addAction:OkAction];
        [self presentViewController:errorAlert animated:YES completion:nil];
        
        // Richiamo il metodo setErrorBorder due volte, una per textField da colorare in rosso.
        [self setErrorBorder:self.usernameTextField];
        [self setErrorBorder:self.passwordTextField];
    }];
}

/*
 * Metodo richiamato passando come parametro un'UITextField in modo tale da colorare i suoi 
 * bordi di rosso, indicando un errore.
 */
-(void)setErrorBorder:(UITextField *)textField{
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor redColor]CGColor];
    textField.layer.borderWidth= 1.0f;
}

-(void)prepareInterface{
    self.loginButton.readPermissions =  @[@"public_profile", @"email", @"user_friends"];
    self.loginButton.delegate=self;
    self.loginWithoutFacebook.layer.cornerRadius=3;
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareInterface];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    if([FBSDKAccessToken currentAccessToken]){
        NSLog(@"Utente gia loggato con facebook");
    }
}


-(void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
             error:(NSError *)error{
    //Se non sono stati riscontrati errori e l'utente non si è cancellato da Facebook allora possiamo ricavere i dati.
    if (error==nil && !result.isCancelled) {
        soloFacebookUniversitario=[[UPUniversitario alloc]init];
        NSLog(@"Ti stai loggando utilizzando Facebook");
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        [params setValue:@"id,first_name,last_name,email,picture.type(large)" forKey:@"fields"];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             NSURL* url= [[NSURL alloc]initWithString:[[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"]];
             NSData* dataFoto=[[NSData alloc]initWithContentsOfURL:url];
             soloFacebookUniversitario.nome=[result objectForKey:@"first_name"];
             soloFacebookUniversitario.cognome=[result objectForKey:@"last_name"];
             soloFacebookUniversitario.email=[result objectForKey:@"email"];
             soloFacebookUniversitario.fotoProfilo=dataFoto;
             [self performSegueWithIdentifier:@"loginWithFacebook" sender:self];
         }];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

/*
 * A fine dell'inserimento in una textField verrà fatta sparire la tastiera.
 */
-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog(@"Logout withFacebook");
}


#pragma mark gestione del db e salvataggio del nuovo utente.
-(void)salvaDatiNelDBnome:(NSString*)nome
                  cognome:(NSString*)cognome
                    email:(NSString*)email
              fotoProfilo:(NSData*)fotoProfilo
               nomeUtente:(NSString*)nomeUtente
               universita:(NSString*)universita{
    AppDelegate *objApp=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context=[objApp managedObjectContext];
    NSEntityDescription* entityDesc=[NSEntityDescription entityForName:@"Utente" inManagedObjectContext:context];
    NSManagedObject* persona=[[NSManagedObject alloc]initWithEntity:entityDesc insertIntoManagedObjectContext:context];
    [persona setValue:nome forKey:@"nome"];
    [persona setValue:cognome forKey:@"cognome"];
    [persona setValue:email forKey:@"email"];
    [persona setValue:fotoProfilo forKey:@"fotoprofilo"];
    [persona setValue:nomeUtente forKey:@"nomeutente"];
    [persona setValue:universita forKey:@"universita"];
    NSError* err;
    NSLog(@"Salvo utente nel db locale: \n");
    NSLog(@"%@\n",nome);
    NSLog(@"%@\n",cognome);
    NSLog(@"%@\n",email);
    NSLog(@"%@\n",universita);
    NSLog(@"%@\n",nomeUtente);
    //  NSLog(@"%@\n",fotoProfilo);
    [context save:&err];
    if(err!=nil)
        NSLog(@"%@",err.description);
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loginWithFacebook"]){
        if([segue.destinationViewController isKindOfClass:[userInfoViewController class]]){
            userInfoViewController* obj=(userInfoViewController *)segue.destinationViewController;
            obj.universitario=[[UPUniversitario alloc]initWithUniversitario:soloFacebookUniversitario];
            obj.universitario.nome=soloFacebookUniversitario.nome;
            obj.universitario.cognome=soloFacebookUniversitario.cognome;
            NSString * email= [[NSString alloc]initWithString:soloFacebookUniversitario.email];
            obj.universitario.email=email;
            obj.universitario.fotoProfilo=soloFacebookUniversitario.fotoProfilo;
            
            
        }
    }
    
}



@end
