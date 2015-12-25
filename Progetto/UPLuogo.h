//
//  UPLuogo.h
//  Progetto
//
//  Created by IdrissRio on 22/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface UPLuogo : NSObject{
    double longitudine;
    double latitudine;
}

@property(nonatomic,weak)NSString* indirizzo;
@property(nonatomic,weak)NSString* telefono;
@property(nonatomic,weak)NSString* nome;
@property(nonatomic,weak)NSData* immagine;
@property(nonatomic,weak)NSString* tipologia;
-(id)initWithIndirizzo:(NSString*)indirizzo
              telefono:(NSString*) telefono
                  nome:(NSString*)nome
           longitudine:(double)longitud
            latitudine:(double)latitud
              immagine:(NSData*)immagine
             tipologia:(NSString*)tipologia;
    


-(id)initWithLuogo:(UPLuogo *)luogo;


@end
