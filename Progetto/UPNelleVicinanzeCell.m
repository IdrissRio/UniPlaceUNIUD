//
//  UPNelleVicinanzeCell.m
//  Progetto
//
//  Created by IdrissRio on 16/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import "UPNelleVicinanzeCell.h"

@implementation UPNelleVicinanzeCell{
    Boolean scroll;
}

- (void)awakeFromNib {
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
