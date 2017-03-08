//
//  UPViewCommento.h
//  Progetto
//
//  Created by IdrissRio on 05/03/17.
//  Copyright © 2016 Idriss Riouak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarRatingView.h"
@interface UPViewCommento : UIView
@property (strong, nonatomic) IBOutlet UITextView *textViewRecensione;
@property (strong, nonatomic) IBOutlet UILabel *labelAutore;
@property (strong, nonatomic) IBOutlet UILabel *dataRecensione;
@property (strong, nonatomic) IBOutlet StarRatingView *ratingView;
@property (strong, nonatomic) IBOutlet UIImageView *immagineRecension;

@end
