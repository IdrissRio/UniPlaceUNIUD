//
//  UPLuogo.m
//  Progetto
//
//  Created by IdrissRio on 22/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPLuogo.h"

@implementation UPLuogo
-(id)initWithIndirizzo:(NSString *)indirizzo
              telefono:(NSString *)telefono
                  nome:(NSString *)nome
           longitudine:(double)longitud
            latitudine:(double)latitud
              immagine:(NSData *)immagine
             tipologia:(NSString *)tipologia{
    if (self = [super init]){
        _nome=nome;
        _telefono=telefono;
        _indirizzo=indirizzo;
        longitudine=longitud;
        latitudine=latitud;
        _immagine=immagine;
        _tipologia=tipologia;
    }
    return self;
}


-(id)initWithLuogo:(UPLuogo *)luogo{
     if (self = [super init]){
    _nome=luogo.nome;
    _telefono=luogo.telefono;
    _indirizzo=luogo.indirizzo;
    longitudine=luogo->longitudine;
    latitudine=luogo->latitudine;
    _immagine=luogo.immagine;
         _tipologia=luogo.tipologia;
     }
    return self;
}
@end