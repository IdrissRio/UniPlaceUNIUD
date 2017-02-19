//
//  firstLoginScreenViewController.h
//  Progetto
//
//  Created by IdrissRio on 16/11/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UIViewController+TextFieldDelegate.h"
/*!
 * @class firstLoginScreenViewController
 * @superclass UIViewController
 * @brief firstLoginScreenViewController : UIViewController
 * @discussion firstLoginScreenViewController è una classe che definisce come deve apparire e quali sono i dati che devono essere caricati durante la prima schermata di login. Questa schermata apparirà solamente se l'utente non si è mai registrato o se dopo esseresi registrato avrà effettuata il logout.
 */

@interface firstLoginScreenViewController : UIViewController<FBSDKLoginButtonDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

/*! loginButton: rappresenta il bottone con la quale l'utente può ottenere le sue informazioni senza dovere compilare il form. Abbiamo utilizzato le GRAPH-API sviluppate da facebook.*/
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;


/*! loginWithoutFacebook:  è un botton che una volta premuto porta l'utente nella schermata di compilazione del form per la raccolata dati. La compilazione viene fatta manualmente senza l'utilizzo di Facebook. */
@property (weak, nonatomic) IBOutlet UIButton *loginWithoutFacebook;
/*! accediTasto:  è un botton che una volta premuto esegue una query sul db online e controlla che esista un utente con nomeutente e password uguali a quelli inserite dall'utente in questione. */
@property (weak, nonatomic) IBOutlet UIButton *accediTasto;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

/*!
 * @brief prepareInterface
 * @discussion prepareInterface: funzione che crea e dipone gli oggetti a runtime quando la view viene chiamata.
 */
-(void)prepareInterface;
- (void)setErrorBorder:(UITextField *)textField;

@end
