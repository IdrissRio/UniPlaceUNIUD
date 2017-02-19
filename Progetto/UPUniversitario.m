//
//  UPUniversitario.m
//  Progetto
//
//  Created by IdrissRio on 18/11/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPUniversitario.h"

@implementation UPUniversitario{
    
}


-(id) initWithNome:(NSString *)nome
           cognome:(NSString *)cognome
             email:(NSString *)email
          password:(NSString *)password
        nomeUtente:(NSString *)nomeUtente
        universita:(NSString *)universita
       fotoProfilo:(NSData *)fotoProfilo
 LogoUniversita:(NSData*)LogoUni{
    if (self = [super init]){
        _nome=nome;
        _cognome=cognome;
        _email=email;
        _password=password;
        _nomeUtente=nomeUtente;
        _universita=universita;
        _fotoProfilo=fotoProfilo;
        _LogoUni=LogoUni;
    }
    return self;
}

-(id) initWithUniversitario:(UPUniversitario *)Universitario{
    if (self = [super init]){
        _nome=Universitario.nome;
        _cognome=Universitario.cognome;
        _email=Universitario.email;
        _password=Universitario.password;
        _nomeUtente=Universitario.nomeUtente;
        _universita=Universitario.universita;
        _LogoUni=Universitario.LogoUni;
    }
    return self;
}


@end
