

#import <UIKit/UIKit.h>
#import "StarRatingView.h"
#import "UIViewController+TextFieldDelegate.h"

@interface AddReviewController : UIViewController <StarRatingViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *immagineRecensione;

@property (weak, nonatomic) IBOutlet StarRatingView *rateView;

@property (weak, nonatomic) IBOutlet UITextField *recensioneTexfField;

- (void) setReviewResult:(int)Esito;


@end

