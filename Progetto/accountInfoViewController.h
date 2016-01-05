

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h> // Per impostare i border nelle textField
#import "UPUniversitario.h"
#import "UIViewController+TextFieldDelegate.h"

@interface accountInfoViewController : UIViewController<UITextFieldDelegate>

@property (strong,nonatomic) UPUniversitario *universitario;

/* Property relative a tutti i textField della View AccountInfo. In ordine, esse
 * sono relative al nickname dell'utente, alla sua email, password e al suo campo
 * di conferma.
 */
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;

/* Property relative alle label della view AccountInfo che verranno visualizzate
 * nel caso in cui il campo non sia corretto secondo criteri che variano da dove
 * si inserisce.
 */
@property (weak, nonatomic) IBOutlet UILabel *errorNicknameInsert;
@property (weak, nonatomic) IBOutlet UILabel *errorEmailInsert;
@property (weak, nonatomic) IBOutlet UILabel *errorPasswordInsert;
@property (weak, nonatomic) IBOutlet UILabel *errorConfirmPasswordInsert;

// Property relativa al tasto di registrazione da premere per completare la
// recensione.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *endRegistrationButton;


@end