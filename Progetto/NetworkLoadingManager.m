

#import "NetworkLoadingManager.h"

@interface NetworkLoadingManager()

@end

@implementation NetworkLoadingManager


/*
 * Il metodo principale della classe createBodyWithURL:Parameters:DataImage:ImageInformations si occupa di
 * creare un oggetto NSURLRequest contenente tutti i campi testuali e multimediali (nel nostro caso solamente foto)
 * da mandare al server. Esso prenderà in input l'URL del file che gestirà la richiesta a server, i parametri testuali
 * l'immagine da caraicare seguito da un array formato da due chiavi indicanti il nome e del file e il tag.
 */
- (NSURLRequest *)createBodyWithURL:(NSString *)url
                   Parameters:(NSDictionary *)parameters
                   DataImage:(NSData *)image
            ImageInformations:(NSArray *)informations{
    

    // Creo una stringa contenente un boundary identificativo
    NSString *boundary = [self generateBoundaryString];
    
    // Configuro la richiesta, con content type di tipo multipart in quanto dovrò inserire più elementi
    // (testo nel dictionary e immagini)
    NSURL *urlFromString = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlFromString];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *httpBody = [NSMutableData data];
    
    
    // Per ogni entry del dictionary eseguo il contenuto del blocco, che
    // in questo caso non fa altro che prendere le informazioni e il
    // contenuto per costruire il corpo della richiesta appendendo valori preceduti da un boundary per
    // identificarli uno dall'altro.
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // Aggiungo l'immagine con la stessa metodica dei campi testuali (ovvero
    // informazioni relative ad essa racchiuse tra boundary seguite dal
    // contenuto stesso. Ovviamente varieranno i tag HTTP)
    for(int i = 0; i < informations.count; i+=2){
    
        NSString *fileName = [informations objectAtIndex:i];
        NSString *fieldName = [informations objectAtIndex:i+1];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[NSData dataWithData:image]];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    }
    
    // Concateno l'ultimo boundary che chiuderà la richiesta.
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // Imposto il corpo della richiesta con il risultato del metodo
    request.HTTPBody = httpBody;
    
    return request;
}

/* Genero un boundary che divide i vari campi (testo o immagini nel caso di questo oggetto) all'interno del body
 * della chiamata HTTP. Esso è generato automaticamente da un oggetto di classe NSUIID (Universally Unique Identifiers) 
 * che mediante il metodo UIIDString ritorna una stringa a 128 bit, random, come richiesto.
 */
- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}




@end
