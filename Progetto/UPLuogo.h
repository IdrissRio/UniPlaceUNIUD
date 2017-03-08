//
//  UPLuogo.h
//  Progetto
//
//  Created by Idriss Riouak on 28/02/17.
//  Copyright © 2017 Idriss Riouak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface UPLuogo : NSObject{
    NSString* longitudine;
    NSString* latitudine;
   
}
@property NSInteger identificativo;
@property(nonatomic,strong)NSString* indirizzo;
@property(nonatomic,weak)NSString* telefono;
@property(nonatomic,weak)NSString* nome;
@property(nonatomic,weak)NSData* immagine;
@property(nonatomic,weak)NSString* tipologia;
@property float media;
-(id)initWithIndirizzo:(NSString*)indirizzo
              telefono:(NSString*) telefono
                  nome:(NSString*)nome
           longitudine:(NSString*)longitud
            latitudine:(NSString*)latitud
              immagine:(NSData*)immagine
             tipologia:(NSString*)tipologia
                 media:(float)media
                 andID:(NSInteger )identificativo;
    


-(id)initWithLuogo:(UPLuogo *)luogo;


@end
