/*
 * Questa categoria vuole fornire i meccanismi base con cui
 * gestire il valore degli User Defined Runtime Attributes indicati nelle relative
 * TextField all'interno dell'interface builder. Per ogni property qui presente infatti,
 * si vuole andare a prelevare la relativa chiave dalla componente grafica, inizializzando
 * le relative variabili di controllo. Al momento, gli UDRA di un textField possono indicare:
 * - La lunghezza massima del campo (maxLength)
 * - La natura del campo di testo, se conterrà un indirizzo email o meno (isEmailAddress).
 */
#import <UIKit/UIKit.h>

@interface UITextField (RuntimeExtension)
@property(nonatomic, assign) NSNumber* maxLength;
@property(nonatomic, assign) BOOL isEMailAddress;
@end
