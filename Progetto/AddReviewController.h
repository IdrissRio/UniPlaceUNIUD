/*
 * NOME: AddReviewController.h
 * DESCRIZIONE: AddReviewController è il gestore della view relativa all'inserimento della recensione. Essa sfrutta 5 delegate:
 *  - StarRatingViewDelegate: contenente i metodi necessari per potere visualizzare correttamente le stelle della
 *  recensione.
 *  - UITextFieldDelegate: necessario per poter gestire i due metodi relativi all'inserimento dei dati.
 *  - UINavigationControllerDelegate: utilizzato nella navigazione tra view.
 *  - UIImagePickerControllerDelegate: utilizzato dal momento che nella view sarà possibile scegliere un'immagine dalla
 *  galleria.
 *
 * PROPERTIES UTILIZZATE: 
 * - (UIImageView *) immagineRecensione, riferita all'imageView in cui l'utente potrà selezionare un'immagine dalla galleria
 * per poi caricarla insieme alla descrizione stessa delle recensione.
 * - (StarRatingView *) rateView, riferita alla view che rappresenterà le stelle della recensione.
 * - (UITextField *) recensioneTextField, riferita alla TextField contenente il testo della recensione.
 */

#import <UIKit/UIKit.h>
#import "StarRatingView.h"
#import "UIViewController+TextFieldDelegate.h" // Necessaria per sfruttare gli URDA grazie ai metodi lì inseriti.

@interface AddReviewController : UIViewController <StarRatingViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *immagineRecensione;

@property (weak, nonatomic) IBOutlet StarRatingView *rateView;

@property (weak, nonatomic) IBOutlet UITextField *recensioneTexfField;

- (void) setReviewResult:(int)Esito;


@end

