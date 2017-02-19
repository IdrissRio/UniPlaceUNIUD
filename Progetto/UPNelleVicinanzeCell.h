//
//  UPNelleVicinanzeCell.h
//  Progetto
//
//  Created by IdrissRio on 16/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface UPNelleVicinanzeCell : UITableViewCell
@property (strong, nonatomic) IBOutlet MKMapView *mappaLuogo;
@property (weak, nonatomic) IBOutlet UIButton *immagineScroll;

@end
