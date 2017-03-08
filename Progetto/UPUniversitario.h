//
//  UPUniversitario.h
//  Progetto
//
//  Created by Idriss Riouak on 02/02/17.
//  Copyright © 2017 Idriss Riouak. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class UPUniversitario
 * @brief UPUniversitario : NSObject
 * @discussion UPUniversitario è la classe che implementa l'oggetto Studente Universitario, con le sue informazioni personali.
 * @superclass SuperClass: NSObject
 */
@interface UPUniversitario : NSObject{

}
/*! nome identifica il nome dello studente */
@property (weak,nonatomic) NSString* nome;
/*! cognome identifica il cognome dello studente */
@property (weak,nonatomic) NSString *cognome;
/*! email identifica l'email dello studente */
@property (strong,nonatomic) NSString *email;
/*! password identifica la password con la quale l'utente può loggarsi in sicurezza */
@property (weak,nonatomic) NSString *password;
/*! nomeUtente identifica il nomeUtente dello studente e verrà utilizzato insieme alla password per poter loggarsi.*/
@property (weak,nonatomic) NSString *nomeUtente;
/*! universita identifica l'università che l'utente frequenta e dunque anche i luoghi (città) a lui vicini. */
@property (weak,nonatomic) NSString *universita;
/*! fotoProfilo è l'immagine del profilo dell'utente */
@property (strong,nonatomic) NSData *fotoProfilo;

@property (strong,nonatomic)NSData *LogoUni;


/*!
 * @brief initWithNome:(NSString *)nome cognome:(NSString *)cognome email:(NSString *)email password:(NSString *) password nomeUtente:(NSString *) nomeUtente universita:(NSString *) universita fotoProfilo:(NSData *) fotoProfilo;;
 * @discussion Costruttore che prende come parametri tutti i campi necessari a creare uno oggetto di tipo Universitario.
 */
-(id) initWithNome:(NSString *)nome
           cognome:(NSString *)cognome
             email:(NSString *)email
          password:(NSString *) password
        nomeUtente:(NSString *) nomeUtente
        universita:(NSString *) universita
       fotoProfilo:(NSData *) fotoProfilo
 LogoUniversita:(NSData*)LogoUni;


/*!
 * @brief initWithUniversitario:(UPUniversitario *)Universitario;
  * @discussion Costruttore di copia che prende come parametro uno studente.
 */
-(id) initWithUniversitario:(UPUniversitario *)Universitario;


@end
