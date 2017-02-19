
#import "userInfoViewController.h"
#import "accountInfoViewController.h"
#import "UPSelectUniversity.h"
#include <math.h>
// Non sono sicuro che serva, provare senza #define MAX_FIELD_LENGTH 10

@interface userInfoViewController()
{
    
    BOOL aviableNome;
    BOOL aviableCognome;
    BOOL aviableImmagineProfilo;
    BOOL aviableImmageUni;
}


- (void)canGoAhead;
- (void)setErrorBorder:(UITextField *)textField;


@end

@implementation userInfoViewController

#pragma mark Gestione preliminare delle view.

- (void)viewDidLoad {
  
    [super viewDidLoad];
    /*
    Modifico la forma dell'imageView relativa alla selezione dell'immagine profilo cambiandone la forma
    in un cerchio. In via del tutto indipendente dalla dimensione della imageview nell'InterfacE Builder, imposto il radiante facendo sì che sia sempre la metà della larghezza di essa. In seconda battuta imposterò un bordo bianco grande 3 px di colore bianco da mettere come contorno.
     */
    self.navigationController.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.imageProfileView.layer.cornerRadius = self.imageProfileView.frame.size.width / 2;
    self.imageProfileView.layer.borderWidth = 3.0f;
    self.imageProfileView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageProfileView.clipsToBounds = YES; //Necessario per visualizzare le modifiche apportate.
    
    // if([self.nomeTextField.text isEqualToString:@""])
    aviableNome = NO;
    aviableCognome = NO;
    aviableImmagineProfilo = NO;
    aviableImmageUni = NO;
    [self ifLoginWithFacebook];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)canGoAhead{
    if(aviableNome == YES && aviableCognome == YES && aviableImmageUni == YES && aviableImmagineProfilo == YES)
        self.avantiPressed.enabled = YES;
    else self.avantiPressed.enabled = NO;
}

-(void)ifLoginWithFacebook{
    if(_universitario!=nil ){
        
        [self.navigationItem setHidesBackButton:YES animated:YES];
        self.nomeTextField.text=_universitario.nome;
        self.cognomeTextField.text=_universitario.cognome;
        self.imageProfileView.image=[[UIImage alloc]initWithData:_universitario.fotoProfilo];
        if(![self.cognomeTextField.text isEqualToString:@""])
        aviableCognome = YES;
        if (![ self.nomeTextField.text isEqualToString:@""]) {
            aviableNome=YES;
        }
        // Portava a bug. aviableCognome = YES;
        
        if(_universitario.fotoProfilo!=nil)
        aviableImmagineProfilo = YES;
        
        //Riprendo tutte le informazioni e se ho scelto un'università viene modificata la label inferiore e l'immagine visualizzata
        if (_universitario.universita!=nil){
            self.imageUniView.image=[[UIImage alloc]initWithData:_universitario.LogoUni];
            self.labelUniversita.text=_universitario.universita;
            aviableImmageUni = YES;
            
        }
        [self canGoAhead];
    }
}

- (void)setErrorBorder:(UITextField *)textField{
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor redColor]CGColor];
    textField.layer.borderWidth= 1.0f;
    
}
#pragma mark Gestione dei tocchi relativi alle imageView.


/**
 @descr Metodo richiamato ogni volta che una o più dita toccano una view o una finestra.
 @param touches
        NSSet contente tutti i tocchi effettuati dall'utente.
 @param event
        Evento connesso al tocco effettuato.
**/
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    //Inizializzo un oggetto di tipo touch contenente uno dei tocchi effettuati dall'utente preso dal metodo anyObject.
    UITouch *touch = [touches anyObject];
    
    //Se ho premuto l'immagine di default per la selezione del proprio avatar..
    if([touch view] == self.imageProfileView){
        
        //Creo un oggetto di tipo UIImagepickerController che mi servirà per accedere alla galleria mediante il metodo
        //presentViewController:animated:completion:
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES; //L'utente potrà modificare l'immagine dalla galleria.
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //Indico come risorsa la Photo Library di iOS.
        
        //Il picker selezionato verrà visualizzato dal view Controller attuale mediante un'animazione.
        [self presentViewController:picker animated:YES completion:NULL];
        
    }else if([touch view] ==self.imageUniView){
        [self performSegueWithIdentifier:@"selectUniversitySegue" sender:self];
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
    
    self.imageProfileView.image = info[UIImagePickerControllerEditedImage];
    aviableImmagineProfilo = YES;
    [self canGoAhead];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark Gestione delle segue.

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    /*
     * Se è stato scelto di andare alla segue successiva contenente le informazioni
     * relative all'account, salvo tutte le informazioni ottenute in questa View.
     */
    if([segue.identifier isEqualToString:@"GoToAccountInfo"]){
        if([segue.destinationViewController isKindOfClass:[accountInfoViewController class]]){
            accountInfoViewController *accountView = (accountInfoViewController *) segue.destinationViewController;
            accountView.universitario=[[UPUniversitario alloc]init];
            accountView.universitario.nome = self.nomeTextField.text;
            accountView.universitario.cognome = self.cognomeTextField.text;
            accountView.universitario.email=self.universitario.email;
            accountView.universitario.fotoProfilo = UIImagePNGRepresentation(self.imageProfileView.image);
            accountView.universitario.universita = self.labelUniversita.text;
            accountView.universitario.LogoUni=self.universitario.LogoUni;
        }
    }
    /*
     * Se l'utente invece sta andando a selezionare l'università, salvo comunque tutte le informazioni
     * prese fino ad ora, con l'opportuno controllo sulla mail nel caso l'utente si sia registrato con
     * Facebook.
     */
    else if([segue.identifier isEqualToString:@"selectUniversitySegue"]){
       
        if([segue.destinationViewController isKindOfClass:[UPSelectUniversity class]]){
            UPSelectUniversity *accountView = (UPSelectUniversity *) segue.destinationViewController;
            accountView.tieniInfoViewPrecedente = [[UPUniversitario alloc]init];
            
            if(self.universitario.email != nil)
                accountView.tieniInfoViewPrecedente.email = self.universitario.email;
            
            accountView.tieniInfoViewPrecedente.nome = self.nomeTextField.text;
            accountView.tieniInfoViewPrecedente.cognome = self.cognomeTextField.text;
            accountView.tieniInfoViewPrecedente.fotoProfilo = UIImagePNGRepresentation(self.imageProfileView.image);
    }
    }
}

#pragma mark Gestione del cambiamento del contenuto inserito dall'utente

/*
 * I metodi di questo pragma verranno richiamati al cambiamento di testo della
 * view a cui sono delegati, controllando che non sia presente una stringa vuota e,
 * nel caso lo fosse, visualizzando un opportuno messaggio.
 */

- (IBAction)insertNomeDidChanged:(id)sender {
    self.nomeTextField.layer.borderColor = [[UIColor clearColor]CGColor];
    self.errorNomeInsert.hidden = YES;
    /*
    if([self.nomeTextField.text length] >= MAX_FIELD_LENGTH)
        self.nomeTextField.enabled = NO;
    else */
    if([self.nomeTextField.text isEqualToString:@""])
        aviableNome = NO;
    else aviableNome = YES;
    
    [self canGoAhead];
}

- (IBAction)insertCognomeDidChanged:(id)sender {
    /*
    if([self.cognomeTextField.text length] >= MAX_FIELD_LENGTH)
        self.cognomeTextField.enabled = NO;
    else */
    
    if([self.cognomeTextField.text isEqualToString:@""])
        aviableCognome = NO;
    else aviableCognome = YES;
    
    [self canGoAhead];
}

# pragma mark gestione delle textField ad inizio modifica

/*
 * I metodi di questo pragma si attiveranno ad inizio tocco su una textField
 * e non faranno altro che resettare il colore del bordo a quello originario 
 * facendo sparire eventuali messaggi d'errore.
 */

- (IBAction)insertNomeDidBegin:(id)sender {
    self.nomeTextField.layer.borderColor = [[UIColor clearColor]CGColor];
    self.errorNomeInsert.hidden = YES;

}
- (IBAction)insertCognomeDidBegin:(id)sender {
    self.cognomeTextField.layer.borderColor = [[UIColor clearColor]CGColor];
    self.errorCognomeInsert.hidden = YES;
}

# pragma mark gestione delle textField a fine modifica

/*
 * I metodi di questo pragma verranno richiamati alla fine inserimento della
 * view a cui sono delegati, controllando che non sia presente una stringa vuota e
 * , nel caso lo fosse, visualizzando un opportuno messaggio.
 */

- (IBAction)insertNomeDidEnd:(id)sender {
    if([self.nomeTextField.text isEqualToString:@""]){
        self.errorNomeInsert.hidden = NO;
        aviableNome = NO;
        [self setErrorBorder:self.nomeTextField];
    }
    else{
        self.errorNomeInsert.hidden = YES;
        aviableNome = YES;
    }
    [self canGoAhead];
}

- (IBAction)insertCognomeDidEnd:(id)sender {
    if([self.cognomeTextField.text isEqualToString:@""]){
        self.errorCognomeInsert.hidden = NO;
        aviableCognome = NO;
        [self setErrorBorder:self.cognomeTextField];
    }
    else{
        self.errorCognomeInsert.hidden = YES;
        aviableCognome = YES;
    }
    
    [self canGoAhead];
}

#pragma gestione della tastiera

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}


@end