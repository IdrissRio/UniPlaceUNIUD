//
//  UPNelleVicinanzeCell.h
//  Progetto
//
//  Created by Idriss Riouak on 22/02/17.
//  Copyright © 2017 Idriss Riouak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface UPNelleVicinanzeCell : UITableViewCell
@property (strong, nonatomic) IBOutlet MKMapView *mappaLuogo;
@property (weak, nonatomic) IBOutlet UIButton *immagineScroll;

@end
