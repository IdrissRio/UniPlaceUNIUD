//
//  UPListaLuoghiNelleVicinanzeTableViewCell.h
//  Progetto
//
//  Created by IdrissRio on 07/03/17.
//  Copyright © 2016 Idriss Riouak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface UPListaLuoghiNelleVicinanzeTableViewCell : UITableViewCell{
    
}

@property (strong, nonatomic) IBOutlet UILabel *labelNome;
@property (strong, nonatomic) IBOutlet UILabel *labelIndirizzo;
@property (strong, nonatomic) IBOutlet UILabel *labelTelefono;
@property (strong, nonatomic) IBOutlet UIImageView *immagineLuogo;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorActivity;

@end
