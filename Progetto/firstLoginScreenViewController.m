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
@interface firstLoginScreenViewController (){
    UPUniversitario* soloFacebookUniversitario;
     NSString *serverReply;
    
}
-(void)checkCredentials;
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
        

        NSError *error;
       
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:credenziali options:0 error:&error];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[JSONData length]];
        NSURL *url = [NSURL URLWithString:@"http://mobdev2015.com/login.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:JSONData];
        
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            // If something goes wrong, an error message is showed.
            if (error) {
                NSLog(@"%@", error);
                return;
            }
            // If nothing is retrieved, the method returns.
            if (!data) {
                return;
            }
            if([[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:@"0"])
            {
                // Setting the global variabile equal to string 0, codificated as Error login singleton, and calling the login controller
                // method to set up the error login message.
                serverReply = @"0";
                [self checkCredentials];
                return;
            }
            
            UPUniversitario *universitarioLoggato = [[UPUniversitario alloc] init];
            // Otherwise, the JSON received will be converted into an array and the contets will be printed, showing
            // an error message if the serialitazion goes wrong.
            NSError *parseError;
            NSDictionary *datiUtente = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (datiUtente && !error) {
                
                // Because is known at this point that the login is completed, the login succeded method is set. This part of code
                // should be placed at the end of the method, but due to the asynchronous nature of NSURLSession, it is possibile
                // to assign the JSON fields to our UPUniversitarioObject and setting the login at the same time by using dispatch_async
                // related to the main thread (obtained by get_global_queue(0,0) method).
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    serverReply = @"1";
                    [self checkCredentials];

                });
                
                NSLog(@"responseObject = %@", datiUtente);
                // After we've received the informations stored into the JSON array, the field related to the profile image is retreived and used to load the phisycal image. The same mechanics will happen for the university Image. This  synchronous but fits with the login design.
                // We start by getting the local path on the server of the two images related to the user.
                NSString *localProfilePath = [NSString stringWithString: [datiUtente objectForKey:@"immagineProfilo"]];
                NSString *localUniPath = [NSString stringWithString: [datiUtente objectForKey:@"immagineUni"]];
                
                // Ceating the complete url for the image profile and the university image by appending the local path
                // previously obtained deleting the dot '.' from the begin of the string.
                NSString * urlProfileImage = [NSString stringWithFormat:@"http://mobdev2015.com%@", [localProfilePath substringFromIndex:1]];
                NSString * urlUniImage = [NSString stringWithFormat:@"http://mobdev2015.com%@", [localUniPath substringFromIndex:1]];
                
                // Printing the result just for debugging purposes.
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
                } else {
                NSLog(@"parseError = %@", parseError);
                NSLog(@"responseString = %@", universitarioLoggato);
            }
            
        }] resume];
        
       
        
        
    }
}

-(void)checkCredentials{
    if(![serverReply isEqualToString:@"0"]){
        [self dismissViewControllerAnimated:NO completion:^{

            [self performSegueWithIdentifier:@"successfulLoginSegue" sender:self];
        }];
        
        
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Errore" message:@"Email e/o Password non corretti." preferredStyle:UIAlertControllerStyleAlert ];
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [errorAlert addAction:OkAction];
            [self presentViewController:errorAlert animated:YES completion:nil];
            [self loginError];
        }];
    }

}
#pragma mark Metodi di routine della classe.

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
