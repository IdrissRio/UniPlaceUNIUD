//
//  UPListaLuoghiNelleVicinanzeTableViewCell.h
//  Progetto
//
//  Created by IdrissRio on 02/01/16.
//  Copyright © 2016 Idriss e Gabriele. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPListaLuoghiNelleVicinanzeTableViewCell : UITableViewCell{
    
}
@property double longitudine;
@property double latitudine;
@property (strong, nonatomic) IBOutlet UILabel *labelNome;
@property (strong, nonatomic) IBOutlet UILabel *labelIndirizzo;
@property (strong, nonatomic) IBOutlet UILabel *labelTelefono;
@property (strong, nonatomic) IBOutlet UIImageView *immagineLuogo;

@end
