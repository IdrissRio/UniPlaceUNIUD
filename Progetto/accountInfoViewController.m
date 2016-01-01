

#import "accountInfoViewController.h"
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "NetworkLoadingManager.h"
#define MAX_EMAIL_LENGTH 30
#define MAX_PASSWORD_LENGTH 20
@interface accountInfoViewController()
{
    //Variabili booleane utilizzate per verificare che il contenuto dei campi a loro associati sono corretti.
    bool aviableNickname;
    bool aviableEmail;
    bool aviablePassword;
    dispatch_group_t group;
    NSString *requestReply;
}

//Metodo utilizzato per contornare di rosso le textField in caso di errore.
- (void)setErrorBorder:(UITextField *)textField;
//Metodo utilizzato per verificare la corretta sintassi di una mail mediante espressioni regolari.
- (BOOL)isValidEmail:(NSString *)email;
//- (void)isDuplicated;
- (void)AlertSuccessfullRegistration;

@end



@implementation accountInfoViewController


#pragma mark Metodi di routine interni alla classe.


-(void)AlertSuccessfullRegistration{
    UIAlertController *confirmAlert=[UIAlertController alertControllerWithTitle:@"Fine" message:@"Registrazione effettuata con successo" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [confirmAlert addAction:okAction];
    [self dismissViewControllerAnimated:YES completion:^(){
        [self presentViewController:confirmAlert animated:YES completion:nil];
    }];
    
}
- (void)viewDidLoad {
    aviableNickname = NO;
    aviableEmail = NO;
    aviablePassword = NO;
    if(self.universitario.email!=nil){
        self.emailTextField.text=self.universitario.email;
        aviableEmail=YES;
    }
    self.navigationController.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)canFinishRegistration{
    if(aviableNickname == YES &&
       aviableEmail == YES &&
       aviablePassword == YES){
        
        self.endRegistrationButton.enabled = YES;
        
    }
    else self.endRegistrationButton.enabled = NO;
}


- (BOOL)isValidEmail:(NSString *)email
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)setErrorBorder:(UITextField *)textField{
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor redColor]CGColor];
    textField.layer.borderWidth= 1.0f;
}
#pragma mark Comunicazione con il server.

//Tasto premuto quando si schiaccia su 'Fine'.
- (IBAction)endRegistrationButtonPressed:(id)sender {
    
    
    NSData* fotoProfilo = self.universitario.fotoProfilo;
    [self salvaDatiNelDBnome:self.universitario.nome cognome:self.universitario.cognome email:self.emailTextField.text fotoProfilo:fotoProfilo nomeUtente:self.nicknameTextField.text universita:self.universitario.universita];
    
    /**
     Dal momento che UIAlertView è stata daprecata si è optato, come suggerito da Apple stessa, UIAlertController impostando come preferredStyle UIAlertControllStyleAlert. In questo modo abbiamo il nostro dialog di allerta a cui aggiungeremo, in una sua subview, un ActivityIndicator per far sì che l'utente sia più "confortato" nel fatto che qualcosa si stia muovendo nella sua attesa.
     **/
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Registrazione in corso \n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    /**
     Il nostro spinner, inizializzato con un rettangolo (misurato in punti) che verrà poi inserito come subview all'interno dell'UIAlertController. I parametri di CGRectMake indicano rispettivamente: la posizione sulle ascisse e sulla ordinate da cui far partire il rettangolo e quindi la sua larghezza e altezza.
     **/
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125,50,30,30)];
    //Imposto lo stile dell'indicatore
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    //Aggiungo alla view dell'alertController la view creata con lo spinner.
    [alert.view addSubview:spinner];
    //Faccio partire l'animazione dello spinner e conseguentemente quella di tutta l'alertView
    [spinner startAnimating];
    
    //Costruisco il dizionario contenente i vari campi di testo inseriti dall'utente. L'utilizzo dell'NSDictionary è per un fattore di comodità nella gestione dei vari campi mediante chiavi, addicendosi di più al contesto JSON.
    
    NSDictionary *userInfoToJSON = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    self.universitario.nome,@"nome",
                                    self.universitario.cognome, @"cognome",
                                    self.nicknameTextField.text, @"nomeUtente",
                                    self.emailTextField.text, @"email",
                                    self.passwordTextField.text, @"password",
                                    self.universitario.universita, @"universita",
                                    nil
                                    ];
    
    NetworkLoadingManager *loader = [[NetworkLoadingManager alloc] init];
    
    NSArray *infoImmagine = @[self.nicknameTextField.text, @"photo"];
    NSURLRequest * request = [loader createBodyWithURL:@"http://mobdev2015.com/register.php"
                                            Parameters:userInfoToJSON
                                             DataImage:self.universitario.fotoProfilo
                                     ImageInformations:infoImmagine];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    /*
     Invio la richiesta vera e propria, impostando anche un blocco di codice da eseguire quando verrà completata la
     richiesta. Ai fini di debug, stamperò il risultato mandato del file php
     */
    [self presentViewController:alert animated:YES completion:NULL];
    [[session  dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        if(!error){
            if(data){
                NSError *parseError;
                NSDictionary *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                NSString *titoloAlertController = [[NSString alloc]init];
                NSString *messaggioAlertController = [[NSString alloc]init];
                
                if (datiUtente) {
                    NSString *esito = [NSString stringWithString: [datiUtente objectForKey:@"esito"]];
                    NSString *emailDuplicata = [NSString stringWithString:[datiUtente objectForKey:@"emailDuplicata"]];
                    NSString *utenteDuplicato = [NSString stringWithString:[datiUtente objectForKey:@"utenteDuplicato"]];
                    
                    if([esito isEqualToString:@"1"]){
                        aviableNickname = YES;
                        aviableEmail = YES;
                        messaggioAlertController = @"Inserimento avvenuto";
                        titoloAlertController = @"Messaggio";
                        [self dismissViewControllerAnimated:NO completion:^{
                            [self performSegueWithIdentifier:@"successfulRegistrationSegue" sender:self];
                        }];
                    }
                    else{
                        messaggioAlertController = @"Email e/o password non corretti. Controlla i campi inseriti.";
                        titoloAlertController = @"Errore";
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:NO completion:^{
                        
                            UIAlertController *errorInsert = [UIAlertController alertControllerWithTitle:titoloAlertController message:messaggioAlertController preferredStyle:UIAlertControllerStyleAlert];
                            
                            if([utenteDuplicato isEqualToString:@"1"]){
                                [self setErrorBorder:self.nicknameTextField];
                                aviableNickname = NO;
                            }
                            else self.nicknameTextField.layer.borderColor = [[UIColor clearColor] CGColor];
                            
                            if([emailDuplicata isEqualToString:@"1"]){
                                [self setErrorBorder:self.emailTextField];
                                aviableEmail = NO;
                            }
                             else self.emailTextField.layer.borderColor = [[UIColor clearColor] CGColor];
                            
                            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                            [errorInsert addAction:okAction];
                            [self presentViewController:errorInsert animated:YES completion:nil];
                            
                        }];
                    });
                }
            }else
                NSLog(@"parseError = %@ \n", error);
            NSLog(@"responseString = %@ \n", [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:NULL];
                
            });
        }
        
    }]resume];
}





#pragma mark Metodi di controllo ad inizio inserimento nelle varie textField

//Nome utente.
- (IBAction)insertNicknameDidBegin:(id)sender {
    self.nicknameTextField.layer.borderColor=[[UIColor clearColor]CGColor];
    self.errorNicknameInsert.hidden = YES;
}
//Email.
- (IBAction)insertEmailDidBegin:(id)sender {
    self.errorEmailInsert.hidden = YES;
    self.emailTextField.layer.borderColor = [[UIColor clearColor] CGColor];
}

//Password.
- (IBAction)insertPasswordDidBegin:(id)sender {
    self.errorPasswordInsert.hidden = YES;
    self.passwordTextField.layer.borderColor = [[UIColor clearColor] CGColor];
}

//Conferma password.
- (IBAction)insertConfirmPasswordDidBegin:(id)sender {
    self.passwordConfirmTextField.layer.borderColor = [[UIColor clearColor] CGColor];
    self.errorConfirmPasswordInsert.hidden = YES;
}

#pragma mark Metodi di controllo durante l'inserimento nelle varie textField
//Nome utente
- (IBAction)insertNicknameDidChanged:(id)sender {
    if([self.nicknameTextField.text isEqualToString:@""]){
        self.errorNicknameInsert.hidden = NO;
        aviableNickname = NO;
        [self setErrorBorder:self.nicknameTextField];
    }
    else{
        self.errorNicknameInsert.hidden = YES;
        aviableNickname = YES;
    }
    
    
    [self canFinishRegistration];
}



//Email
- (IBAction)insertEmailDidChanged:(id)sender {
    if([self.emailTextField.text isEqualToString:@""]){
        self.errorEmailInsert.hidden = NO;
        self.errorEmailInsert.text = @"Questo campo non può essere lasciato vuoto";
        aviableEmail = NO;
        [self setErrorBorder:self.emailTextField];
    }
    
    if(self.emailTextField.text.length >= MAX_EMAIL_LENGTH)
        self.emailTextField.enabled = NO;
    else self.emailTextField.enabled = YES;
    
    if([self isValidEmail:self.emailTextField.text] == NO)
        aviableEmail = NO;
    else{
        self.errorEmailInsert.hidden = YES;
        self.emailTextField.layer.borderColor = [[UIColor clearColor] CGColor];
        aviableEmail = YES;
    }
    
    
    [self canFinishRegistration];
    
}

//Password
- (IBAction)insertPasswordDidChanged:(id)sender {
    if([self.passwordTextField.text isEqualToString:@""]){
        self.errorPasswordInsert.hidden = NO;
        [self setErrorBorder:self.passwordTextField];
        self.passwordConfirmTextField.enabled = NO;
        self.passwordConfirmTextField.text = @"";
        aviablePassword = NO;
    }
    else if(self.passwordTextField.text.length >= MAX_PASSWORD_LENGTH)
        self.passwordTextField.enabled = NO;
    else
        self.passwordTextField.enabled = YES;
        
    
    self.errorPasswordInsert.hidden = YES;
    self.passwordConfirmTextField.enabled = NO;
    
    [self canFinishRegistration];
}

//Conferma Password
- (IBAction)insertPasswordConfirmDidChanged:(id)sender {
    
    
    
    if(self.passwordConfirmTextField.text.length >= MAX_PASSWORD_LENGTH)
        self.passwordConfirmTextField.enabled = NO;
    else
        self.passwordConfirmTextField.enabled = YES;
    
    if([self.passwordConfirmTextField.text isEqualToString:@""]){
        self.errorConfirmPasswordInsert.hidden = NO;
        self.errorConfirmPasswordInsert.text = @"Non è possibile lasciare questo campo vuoto";
        [self setErrorBorder:self.passwordConfirmTextField];
        aviablePassword = NO;
    }

    else if([self.passwordConfirmTextField.text isEqualToString:self.passwordTextField.text]){
        self.errorConfirmPasswordInsert.hidden = NO;
        self.errorConfirmPasswordInsert.text = @"Le password coincidono";
        self.errorConfirmPasswordInsert.textColor = [UIColor greenColor];
        self.passwordConfirmTextField.layer.borderColor = [[UIColor clearColor] CGColor];
        aviablePassword = YES;
    }
    else{
        self.errorConfirmPasswordInsert.hidden = NO;
        self.errorConfirmPasswordInsert.textColor = [UIColor redColor];
        self.errorConfirmPasswordInsert.text = @"Le password non coincidono";
        [self setErrorBorder:self.passwordConfirmTextField];
        aviablePassword = NO;
    }
    
    [self canFinishRegistration];
}


#pragma mark Metodi di controllo a fine inserimento, riconosciuti quando l'utente clicca al di fuori della textField.
//Nome Utente
- (IBAction)insertNicknameDidEnd:(id)sender {
    
    if([self.nicknameTextField.text isEqualToString:@""]){
        aviableNickname = NO;
        self.errorNicknameInsert.hidden = NO;
        [self setErrorBorder:self.nicknameTextField];
    }
    else{
        aviableNickname = YES;
        self.errorNicknameInsert.hidden = YES;
        self.nicknameTextField.layer.borderColor=[[UIColor clearColor]CGColor];
        
        
    }
    [self canFinishRegistration];
    
}

//Email
- (IBAction)insertEmailDidEnd:(id)sender {
    if([self isValidEmail:self.emailTextField.text] == NO){
        aviableEmail= NO;
        self.errorEmailInsert.hidden = NO;
        self.errorEmailInsert.text = @"Inserire un indirizzo di email valido.";
        [self setErrorBorder:self.emailTextField];
    }
    else{
        
        aviableEmail = YES;
        self.errorEmailInsert.hidden = YES;
        self.emailTextField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    [self canFinishRegistration];
}

//Password
- (IBAction)insertPasswordDidEnd:(id)sender {
    if([self.passwordTextField.text isEqualToString:@""]){
        self.errorPasswordInsert.hidden = NO;
        [self setErrorBorder:self.passwordTextField];
        self.passwordConfirmTextField.enabled = NO;
        self.passwordConfirmTextField.text = @"";
        aviablePassword = NO;
    }
    else{
        
        self.errorPasswordInsert.hidden = YES;
        self.passwordTextField.layer.borderColor = [[UIColor clearColor] CGColor];
        self.passwordConfirmTextField.enabled = YES;
    }
    
    [self canFinishRegistration];
}

//Conferma password
- (IBAction)insertPasswordConfirmDidEnd:(id)sender {
    
    self.errorConfirmPasswordInsert.hidden = YES;
    self.passwordConfirmTextField.layer.borderColor = [[UIColor clearColor] CGColor];
    
    if([self.passwordConfirmTextField.text isEqualToString:@""]){
        self.errorConfirmPasswordInsert.hidden = NO;
        self.errorConfirmPasswordInsert.text = @"Non è possibile lasciare questo campo vuoto";
        self.errorConfirmPasswordInsert.textColor = [UIColor redColor];
        [self setErrorBorder:self.passwordConfirmTextField];
        aviablePassword = NO;
    }
    
    else if([self.passwordConfirmTextField.text isEqualToString:self.passwordTextField.text] == NO){
        aviablePassword = NO;
        self.errorConfirmPasswordInsert.hidden = NO;
        self.errorConfirmPasswordInsert.text = @"Le password non coincidono";
        self.errorConfirmPasswordInsert.textColor = [UIColor redColor];
        
        [self setErrorBorder:self.passwordConfirmTextField];
        
    }
    
    [self canFinishRegistration];
    
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


@end
