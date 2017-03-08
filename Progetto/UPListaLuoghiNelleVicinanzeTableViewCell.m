//
//  UPListaLuoghiNelleVicinanzeTableViewCell.m
//  Progetto
//
//  Created by IdrissRio on 09/03/17.
//  Copyright © 2016 Idriss Riouak. All rights reserved.
//

#import "UPListaLuoghiNelleVicinanzeTableViewCell.h"
#import <QuartzCore/QuartzCore.h> // Per impostare i border nelle textField
@implementation UPListaLuoghiNelleVicinanzeTableViewCell

- (void)awakeFromNib {
        [super awakeFromNib];
    NSLog(@"UPListaLuoghiNelleVicinanzeTableViewCell - awakeFromNib: image Rounded" );
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
