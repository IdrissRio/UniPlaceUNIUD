//
//  anagraficaApplianceViewController.h
//  Progetto
//
//  Created by Gabriele Etta on 19/11/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UPUniversitario.h"
#import "UIViewController+TextFieldDelegate.h"

@interface userInfoViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *avantiPressed;
@property (strong,nonatomic) UPUniversitario *universitario;
@property (strong, nonatomic) IBOutlet UITextField *nomeTextField;
@property (strong, nonatomic) IBOutlet UITextField *cognomeTextField;
@property (strong, nonatomic) IBOutlet UIImageView *imageProfileView;
@property (strong, nonatomic) IBOutlet UIImageView *imageUniView;
@property (weak, nonatomic) IBOutlet UILabel *errorNomeInsert;
@property (weak, nonatomic) IBOutlet UILabel *errorCognomeInsert;
@property (weak, nonatomic) IBOutlet UILabel *labelUniversita;
@property (nonatomic, assign)NSNumber *maxlength;
/*!
 * @brief ifLoginWithFacebook
 * @discussion ifLoginWithFacebook: controlla se l'utente si è registrato con facebook e se si è registrato con facebook allora procede con il riempimento dei TextFiled e dell'immagine */
-(void)ifLoginWithFacebook;



@end
