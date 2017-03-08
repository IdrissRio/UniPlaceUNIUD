//
//  UPNelleVicinanzeCell.m
//  Progetto
//
//  Created by Idriss Riouak on 09/02/17.
//  Copyright © 2017 Idriss Riouak. All rights reserved.
//

#import "UPNelleVicinanzeCell.h"

@implementation UPNelleVicinanzeCell{
    Boolean scroll;
}
@synthesize mappaLuogo;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    scroll=false;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cambiaProprietaScroll:(id)sender {
    if(scroll==false){
        [self.immagineScroll setImage:[UIImage imageNamed:@"unlock.png"] forState:UIControlStateNormal];
        self.mappaLuogo.scrollEnabled=true;
        scroll=true;
    }else{
        [self.immagineScroll setImage:[UIImage imageNamed:@"lock.png"] forState:UIControlStateNormal];
        self.mappaLuogo.scrollEnabled=false;
        scroll=false;
    }
}


@end
