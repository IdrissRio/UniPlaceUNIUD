//
//  UPUniversitario.m
//  Progetto
//
//  Created by Idriss Riouak on 01/02/17.
//  Copyright © 2017 Idriss Riouak. All rights reserved.
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
