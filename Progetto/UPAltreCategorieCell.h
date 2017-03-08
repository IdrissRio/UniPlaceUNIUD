//
//  UPAltreCategorieCell.h
//  Progetto
//
//  Created by Idriss Riouak on 07/03/17.
//  Copyright © 2017 Idriss Riouak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface UPAltreCategorieCell : UITableViewCell
@property (strong, nonatomic) IBOutlet MKMapView *mappaLuogo;
@property (weak, nonatomic) IBOutlet UILabel *indirizzoLuogo;

@end
