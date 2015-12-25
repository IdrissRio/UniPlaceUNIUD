//
//  accountInfoViewController.h
//  ProgettouserInfoViewController
//
//  Created by Gabriele Etta on 21/11/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h> // Per impostare i border nelle textField
#import "UPUniversitario.h"

@interface accountInfoViewController : UIViewController

@property (strong,nonatomic) UPUniversitario *universitario;
//@property (retain, nonatomic) NSString *nome;
//@property (retain, nonatomic) NSString *cognome;
//@property (retain, nonatomic) NSString *email;
//@property (retain, nonatomic) UIImage *imageProfileView;
//@property (strong, nonatomic) UIImage *imageUniView;
//@property (retain, nonatomic) NSString *nomeUni;

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorNicknameInsert;
@property (weak, nonatomic) IBOutlet UILabel *errorEmailInsert;

@property (weak, nonatomic) IBOutlet UILabel *errorPasswordInsert;
@property (weak, nonatomic) IBOutlet UILabel *errorConfirmPasswordInsert;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *endRegistrationButton;


@end