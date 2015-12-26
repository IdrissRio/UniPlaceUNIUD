

#import "NetworkLoadingManager.h"

@interface NetworkLoadingManager()
{
    // Dal momento che non è possibile far ritornare la funzione all'interno di una NSURLSession, assegnerò il valore dell'esito
    // alla variabile booleana sottostante e ritornerò quest'ultima. E' possibile assegnarla all'interno di un blocco grazie al
    // presisso __block
    BOOL result;
}
@end

@implementation NetworkLoadingManager


- (NSURLRequest *)createBodyWithURL:(NSString *)url
                   Parameters:(NSDictionary *)parameters
                   DataImage:(NSData *)image
            ImageInformations:(NSArray *)informations{
    

    // Creo una stringa contenente un boundary identificativo
    NSString *boundary = [self generateBoundaryString];
    
    // Configuro la richiesta, con content type di tipo multipart in quanto dovrò inserire più elementi (testo nel dictionary e immagini)
    NSURL *urlFromString = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlFromString];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *httpBody = [NSMutableData data];
    
    // Per ogni campo all'interno del dictionary, inserisco una stringa
    // HTTP contenente le informazioni del campo testuale racchiuse tra i boundary, seguite dal suo valore
    
    // Per ogni entry del dictionary eseguo il contenuto del blocco, che
    // in questo caso non fa altro che prendere le informazioni e il
    // contenuto per costruire il corpo dell'HTTP
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // Aggiungo l'immagine con la stessa metodica dei campi testuali (ovvero
    // informazioni relative ad essa racchiuse tra boundary seguite dal
    // contenuto stesso. Ovviamente varieranno i tag HTTP).
    
    for(int i = 0; i < informations.count; i+=2){
    
        NSString *fileName = [informations objectAtIndex:i];
        NSString *fieldName = [informations objectAtIndex:i+1];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[NSData dataWithData:image]];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    }
    
     [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // Imposto il corpo della richiesta con il risultato del metodo
    request.HTTPBody = httpBody;
    
    return request;
}


- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}




@end
