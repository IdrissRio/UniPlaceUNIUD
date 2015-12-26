

#import "UIViewController+TextFieldDelegate.h"
#import "UITextField+RuntimeExtension.h"

@implementation UIViewController (TextFieldDelegate)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL shouldChange = YES;
    
    if(textField.maxLength){
        
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
            shouldChange = (newLength > [textField.maxLength integerValue]) ? NO : YES;
        if(!shouldChange){
            return shouldChange;
        }
    }
    return shouldChange;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.isEMailAddress){
        if(![self stringIsValidEmail:textField.text] && ![textField.text isEqualToString:@""]){
            
            UIAlertView *noMailAddressAlert = [[UIAlertView alloc]
                           initWithTitle:@"Email non valida" message:[NSString stringWithFormat:@"%@ non è una mail valida.", textField.text] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [noMailAddressAlert show];
            textField.text = @"";
        }
    }
}

-(BOOL) stringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
