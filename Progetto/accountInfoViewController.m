

#import "accountInfoViewController.h"
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
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
- (void)inviaImmagineProfilo;
- (void)inviaDatiUtente:(NSDictionary *)userInfoToJSON;
- (void)isDuplicated;


@end



@implementation accountInfoViewController


#pragma mark Metodi di routine interni alla classe.

/*
-(void)AlertSuccessfullRegistration{
    UIAlertController *confirmAlert=[UIAlertController alertControllerWithTitle:@"Fine" message:@"Registrazione effettuata con successo" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [confirmAlert addAction:okAction];
    [self dismissViewControllerAnimated:YES completion:^(){
        [self presentViewController:confirmAlert animated:YES completion:nil];
    }];

}*/
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


-(void)isDuplicated{
        NSLog(@"%@", requestReply);
    if([requestReply isEqualToString:@"Utente duplicato"] || [requestReply isEqualToString:@"Utente duplicatoMail duplicata"]){
            [self setErrorBorder:self.nicknameTextField];
            aviableNickname = NO;
    }
    else self.nicknameTextField.layer.borderColor = [[UIColor clearColor]CGColor];
        
    if([requestReply isEqualToString:@"Utente duplicatoMail duplicata"] || [requestReply isEqualToString:@"Mail duplicata"]){
        [self setErrorBorder:self.emailTextField];
        aviableEmail = NO;
    }
    else self.emailTextField.layer.borderColor = [[UIColor clearColor]CGColor];
    
    if(aviableEmail == YES && aviableNickname == YES)
        [self inviaImmagineProfilo];
        
    else{
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorInsert = [UIAlertController alertControllerWithTitle:@"Errore" message:@"Email e/o password errati. Controlla i dati inseriti" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [errorInsert addAction:okAction];
            [self presentViewController:errorInsert animated:YES completion:nil];
        }];
    }
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
   
    
    NSData* fotoProfilo=self.universitario.fotoProfilo;
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
    [self presentViewController:alert animated:YES completion:^{
        
        /*UIAlertController *confirmAlert=[UIAlertController alertControllerWithTitle:@"Fine" message:@"Registrazione effettuata con successo" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [confirmAlert addAction:okAction];*/
        [self dismissViewControllerAnimated:YES completion:^(){
            //[self presentViewController:confirmAlert animated:YES completion:nil];
            [self performSegueWithIdentifier:@"successfulRegistrationSegue" sender:self];
        }];

    
    }];
    
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

    [self inviaDatiUtente:userInfoToJSON];
    
}

- (void)inviaDatiUtente:(NSDictionary *)userInfoToJSON{
    //Un oggetto di tipo NSError servirà sia nell'encoding del JSON sia nella request inviata dalla NSURLSession.
    NSError *error;
    
    //Se l'oggetto passato è serializzabile (deve rispettare i requisiti visibili nella documentazione di NSJSONSerialization, si procederà al parsing..
    if([NSJSONSerialization isValidJSONObject:userInfoToJSON]){
        NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:userInfoToJSON options:0 error:&error];
        
        /*
         Costruisco la richiesta, indicando:
         - URL a cui fare riferimento, che nel nostro caso è il file JSON.
         - Lunghezza dell'oggetto JSON
         - Tipo di chiamata HTTP
         - I valori relativi ai campi HTTP "application/json" in quanto stiamo usando JSON e la lunghezza
         dell'oggetto passato.
         - Nel body della chiamata inserirerò l'oggetto JSON vero e proprio.
         */
        NSURL *url = [NSURL URLWithString:@"http://mobdev2015.com/register.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //La lunghezza dell'oggetto JSON
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[JSONdata length]];
        
        //Si veda la costruzione della richiesta di qualche riga più in alto.
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:JSONdata];
        
        /*
         Imposto l'oggetto che lancerà la richiesta precedentemente costruita. Esso, per performance, sarà un oggetto
         di tipo NSURLSession, che necessiterà di un oggetto NSURLSessionConfiguration. Il lancio vero e proprio avverrà
         nel metodo dataTaskWithRequest:completionHandler: in cui verrà indicata la richiesta da mandare, costruita prima,
         e il blocco di esecuzione da eseguire a fine richiesta, che ci renderà a conoscenza dell'esito della chiamata.
         Che cosa mandare indietro ovviamente è affidato a come sono stati scritti i file su lato server.
         
         */
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        /*
         Invio la richiesta vera e propria, impostando anche un blocco di codice da eseguire quando verrà completata la
         richiesta. Ai fini di debug, stamperò il risultato mandato del file php
         */
        [[session  dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            if(!error)
                 [self isDuplicated];
        }]resume];
    }
}

- (void)inviaImmagineProfilo{
    
    NSData *imageData = self.universitario.fotoProfilo;
    NSString *urlString = @"http://mobdev2015.com/invioImmagineProfilo.php";
    NSString *filename = [[NSString alloc]initWithFormat:@"%@", self.nicknameTextField.text];

    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:imageData]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    /*
     Invio la richiesta vera e propria, impostando anche un blocco di codice da eseguire quando verrà completata la
     richiesta. Ai fini di debug, stamperò il risultato mandato del file php
     */
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", requestReply);
    }] resume];
    
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
    else if([self isValidEmail:self.emailTextField.text] == NO)
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
    else{
        self.errorPasswordInsert.hidden = YES;
    }
    
    self.passwordConfirmTextField.enabled = NO;

    [self canFinishRegistration];
}

//Conferma Password
- (IBAction)insertPasswordConfirmDidChanged:(id)sender {
    
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
