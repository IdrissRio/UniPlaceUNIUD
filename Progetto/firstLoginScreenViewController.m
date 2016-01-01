//
//  firstLoginScreenViewController.m
//  Progetto
//
//  Created by IdrissRio on 16/11/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//




#import "firstLoginScreenViewController.h"
#import "UPUniversitario.h"
#import "userInfoViewController.h"
#import "AppDelegate.h"
#import "NetworkLoadingManager.h"
@interface firstLoginScreenViewController (){
    UPUniversitario* soloFacebookUniversitario;
    NSString *serverReply;
    
}
-(void)setLoginResult:(int)Esito;
@end

@implementation firstLoginScreenViewController

#pragma mark Login

- (IBAction)loginButtonPressed:(id)sender {
    
    NSString *user = self.usernameTextField.text;
    NSString *pass = self.passwordTextField.text;
    
    NSDictionary *credenziali = [NSDictionary dictionaryWithObjectsAndKeys:user, @"username", pass, @"password", nil];
    
    if([NSJSONSerialization isValidJSONObject:credenziali]){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Accesso in corso \n\n\n"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125,50,30,30)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [alert.view addSubview:spinner];
        [spinner startAnimating];
        [self presentViewController:alert animated:YES completion:nil];
        
        
        NetworkLoadingManager * uploadManager = [[NetworkLoadingManager alloc]init];
        NSURLRequest * request  = [uploadManager createBodyWithURL:@"http://mobdev2015.com/login.php" Parameters:credenziali DataImage:nil ImageInformations:nil];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            
            UPUniversitario *universitarioLoggato = [[UPUniversitario alloc] init];
            // Otherwise, the JSON received will be converted into an array and the contets will be printed, showing
            // an error message if the serialitazion goes wrong.
            NSError *parseError;
            
            NSDictionary *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            // Se ho ricevuto qualcosa in risposta dal server e sono riuscito a convertirlo da JSON ad array
            if (datiUtente) {
                NSString *esito = [NSString stringWithString: [datiUtente objectForKey:@"success"]];
                
                // Se l'esito della stringa adibita è pari a 1, invoco il metodo delegato nel main thread
                // che in base al parametro, indicato da un numero che può essere 0 oppure 1, visualizzerà o
                // meno un messaggio di errore.
                if([esito isEqualToString:@"1"]){
                    NSLog(@"responseObject = %@", datiUtente);
                    
                    NSString *localProfilePath = [NSString stringWithString: [datiUtente objectForKey:@"immagineProfilo"]];
                    NSString *localUniPath = [NSString stringWithString: [datiUtente objectForKey:@"immagineUni"]];

                    NSString * urlProfileImage = [NSString stringWithFormat:@"http://mobdev2015.com%@", [localProfilePath substringFromIndex:1]];
                    NSString * urlUniImage = [NSString stringWithFormat:@"http://mobdev2015.com%@", [localUniPath substringFromIndex:1]];
                    
                    NSLog(@"%@", urlProfileImage);
                    NSLog(@"%@", urlUniImage);
                    
                    // Assigning every field of the JSON aaray to the object which contains the logged user data.
                    universitarioLoggato.nome = [datiUtente objectForKey:@"nome"];
                    universitarioLoggato.cognome = [datiUtente objectForKey:@"cognome"];
                    universitarioLoggato.email = [datiUtente objectForKey:@"email"];
                    universitarioLoggato.nomeUtente = [datiUtente objectForKey:@"nomeUtente"];
                    
                    // If the data needs to be assigned to a UIImage, the static method imageWithData: is required for each
                    // of the fields above, as parameter.
                    universitarioLoggato.LogoUni = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlUniImage]];
                    universitarioLoggato.fotoProfilo = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlProfileImage]];
                    
                    [self salvaDatiNelDBnome:universitarioLoggato.nome cognome:universitarioLoggato.nome email:universitarioLoggato.email fotoProfilo:universitarioLoggato.fotoProfilo nomeUtente:universitarioLoggato.nomeUtente universita:universitarioLoggato.universita];
                  
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:alert completion:nil];
                    [self performSegueWithIdentifier:@"successfulLoginSegue" sender:self];
                    });
                    
                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setLoginResult:0];
                        
                    });
                    
                }
                // Se la conversione è fallita, verrà stampato a console il messaggio di errore con quanto scaricato
                // dal server, indicando comunque che c'è stato un errore nella comunicazione.
            } else
                NSLog(@"parseError = %@ \n", parseError);
            
            NSLog(@"responseString = %@ \n", [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
            
        }] resume];
        
        
        
        
    }
}


#pragma mark Metodi di routine della classe.

- (void) setLoginResult:(int)Esito{
  
    if(Esito == 0){
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:@"Username e/o password errati!"
                                                                         preferredStyle:UIAlertControllerStyleAlert ];
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Errore" style:UIAlertActionStyleDefault handler:nil];
            [errorAlert addAction:OkAction];
            [self presentViewController:errorAlert animated:YES completion:nil];
            
            
            [self setErrorBorder:self.usernameTextField];
            [self setErrorBorder:self.passwordTextField];
        }];
    }
}

-(void)loginError{
    [self setErrorBorder:self.usernameTextField];
    [self setErrorBorder:self.passwordTextField];
    self.errorLabel.text = @"Username e/o password non corretti.";
    self.errorLabel.textColor = [UIColor redColor];
    self.errorLabel.hidden = NO;
}

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
