//
//  UPRegistrazioneLuogo.h
//  Progetto
//
//  Created by IdrissRio on 18/12/15.
//  Copyright © 2015 Idriss e Gabriele. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UPLuogo.h"
@interface UPRegistrazioneLuogo : UIViewController< UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet MKMapView *mappaLuogo;
@property (weak, nonatomic) IBOutlet UITextField *nomeLuogoTextField;
@property (weak, nonatomic) IBOutlet UITextField *indirizzoLuogoTextField;
@property (weak, nonatomic) IBOutlet UITextField *telefonoLuogoTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerTipologia;
@property (strong,nonatomic) UPLuogo* luogo;
@end
