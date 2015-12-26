
#import <objc/runtime.h>

#import "UITextField+RuntimeExtension.h"

static void *MaxLengthKey;
static void *IsEMailAddressKey;
@implementation UITextField (RuntimeExtension)
-(void)setMaxLength:(NSNumber *)maxLength{
    objc_setAssociatedObject(self, &MaxLengthKey, maxLength, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSNumber*)maxLength{
    return objc_getAssociatedObject(self, &MaxLengthKey);
}
-(void)setIsEMailAddress:(BOOL)isEMailAddress{
    objc_setAssociatedObject(self, &IsEMailAddressKey, [NSNumber numberWithBool:isEMailAddress], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)isEMailAddress{
    NSNumber* isEmailAddressNumber = objc_getAssociatedObject(self, &IsEMailAddressKey);
    return [isEmailAddressNumber boolValue];
}


@end
