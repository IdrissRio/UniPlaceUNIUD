/*
 * L'implementazione del comportamento della categoria UITextField+RuntimeExtension, definito
 * nell'omonimo header file, è reso possibile accedendo mediante il metodo objc_setAssociatedObject()
 * alle chiavi indicate nei parametri e assegnandole a relative variabili.
 */
#import <objc/runtime.h>

#import "UITextField+RuntimeExtension.h"

/* Variabili contenenti i valori delle due tipologie di UDRA di una textField. La necessità
 * di utilizzare un tipo statico è data dal fatto che queste categorie non vorranno passare per
 * un oggetto in cui mantenerle ma, nello stesso stile dinamico degli UDRA, nella classe stessa. 
 */
static void *MaxLengthKey;
static void *IsEMailAddressKey;

/* Questa funzione imposta il valore della variabile maxLength nella variabile MaxLengthKey prelevandolo
 * dall'attributo maxLength. L'oggetto in questione su cui lavorare è se stesso (self), riferito al componente
 * grafico associato, con un riferimento di tipo strong (retain) ad esso come indicato nell'ultimo parametro.
 */
@implementation UITextField (RuntimeExtension)
-(void)setMaxLength:(NSNumber *)maxLength{
    objc_setAssociatedObject(self, &MaxLengthKey, maxLength, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/* Funzione che svolge il lavoro inverso a quello del setter, andando solamente a prelevare il valore del
 * puntatore MaxLengthKey
 */
-(NSNumber*)maxLength{
    return objc_getAssociatedObject(self, &MaxLengthKey);
}

/* Funzione che, come setMaxLength, preleva il valore dell'URDA di nome isEmailAddress dall'oggetto self con associazione
 * strong e lo assegna al relativo puntatore dopo che è stato convertito ad intero in quanto l'URDA in questione è un
 * boolean.
 */
-(void)setIsEMailAddress:(BOOL)isEMailAddress{
    objc_setAssociatedObject(self, &IsEMailAddressKey, [NSNumber numberWithBool:isEMailAddress], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/* Funzione che ritorna il valore della chiave associata a isEmailAddress, riconvertendolo da intero a booleano.
 */
-(BOOL)isEMailAddress{
    NSNumber* isEmailAddressNumber = objc_getAssociatedObject(self, &IsEMailAddressKey);
    return [isEmailAddressNumber boolValue];
}


@end
