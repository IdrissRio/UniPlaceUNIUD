/* Questa categoria porta ad estendere il normale utilizzo di una ViewController portandola a
 * rispondere ad eventuali cambiamenti sui sui campi di testo grazie a TextFieldDelegate, con la
 * possibilità di effettuare overriding dei suoi metodi. Per i nostri scopi, dal momento che si tratta
 * solamente di controllare il contenuto dei campi di testo, è stato fatto overriding del metodo
 * textFied:shouldChangeCharactersInRange:replacementString, per controllare l'inserimento carattere per
 * carattere al fine di non superare i limiti massimi di lunghezza imposti, e textFieldDidEndEditing al fine
 * di controllare se quanto inserito è conforme alla tipologia di textField (ad esempio se si stratta di un campo
 * email o meno. La categoria UITextField+RuntimeExtension precedentemente definita risulta utile dal momento che,
 * nel caso volessimo prelevare le chiavi di una textField, non sarà più necessario andare a prelevare il valore
 * relativo alla URDA ogni volta in cui è richiesto.
 */

#import "UIViewController+TextFieldDelegate.h"
#import "UITextField+RuntimeExtension.h"

/* Lo scopo di questo metodo, posto ad overriding, è quello di controllare ad ogni inserimento di carattere se, nel caso
 * la textField in esame abbia un metodo chiamato maxLength, di controllare se la posizione dello'ultimo carattere (location)
 * sommata alla lunghezza dei precedenti caratteri (length) superi la lunghezza complessiva del testo. In tal caso verrà
 * ritornare un valore falso, invalidando la possibilità di aggiungere ulteriore testo. Se invece c'è ancora spazio per inserire,
 * viene aggiornata la variabile controller newLength e ritornato YES dal metodo. Il primo if è necessario al fine di poter
 * gestire anche il copia / incolla di un test all'interno di un campo.
 */
@implementation UIViewController (TextFieldDelegate)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL shouldChange = YES;
    
    if(textField.maxLength){
        
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        shouldChange = (newLength > [textField.maxLength integerValue]) ? NO : YES;
        if(!shouldChange){
            return shouldChange;
        }
    }
    return shouldChange;
}

/* A fine inserimento (ovvero, quando l'utente clicca al di fuori della textField), nel caso in cui il campo sia indicato
 * come campo contenente indirizzi email, viene effettuato un controllo mediante il metodo stringisValidEmail: che mediante
 * l'uso di espressione regolare si accerta della correttezza di quanto inserito. In caso negativo, verrà mostrata una Alert
 * View indicando che quanto inserito non è conforme alla natura del campo, svuotandone il suo contenuto.
 */
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.isEMailAddress){
        if(![self stringIsValidEmail:textField.text] && ![textField.text isEqualToString:@""]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Email non valida."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:
                                       ^(UIAlertAction * action){
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                       }];
            [alert addAction:OkAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            
            textField.text = @"";
        }
    }
}

/* Questo metodo effettua il controllo su una stringa controllando che sia un effettivo indirizzo email. Esso è utilizzato
 * a fine inserimento nelle textfield che contengono campi di testo.
 */
-(BOOL) stringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
