
/*
 * NOME: Network Loading Manager
 * DESCRIZIONE: La classe si propone per gestire l'uploading dei dati su server. Vista la natura dei dati da salvare e gli 
 * oggetti messi a disposizione dal linguaggio, è possibile affidare tale operazione ad un oggetto designato il cui compito è 
 * quello di prendere dizionari testuali e di immagini in modo tale da iterare sugli elementi per formare richieste HTTP contenenti 
 * dati misti (testo e immagini). Questa scelta porta all'abbandono del formato JSON in upload, con il vantaggio di non dover
 * creare chiamate distinte per i dati testuali e per i campi. Ciò, relazionato anche al fatto che si è scelto di usare oggetti di 
 * tipo NSURLSession nelle chiamate per ragioni di efficienza, porta ad una maggiore semplicità e pulizia del codice.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NetworkLoadingManager : NSObject

- (NSURLRequest*) createBodyWithURL:(NSString *)url
                   Parameters:(NSDictionary *)parameters
                   DataImage:(NSData *)image
                   ImageInformations:(NSArray *)informations;
@end
