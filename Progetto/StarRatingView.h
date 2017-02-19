#import <UIKit/UIKit.h>

@class StarRatingView;


/* 
Impostiamo un delegate in modo che possa notificare il View Controller in caso di cambiamento del voto.
Avrei potuto utilizzare un target / selector gestendo la pressione delle stelle singolarmente, ma questa scelta è stata
evitata per evitare codice ridondante.
*/
@protocol StarRatingViewDelegate

- (void)StarRatingView:(StarRatingView *)rateView ratingDidChange:(float)rating;

@end

@interface StarRatingView : UIView

//Impostiamo tre property per dare la possibilità di far vedere una stella non selezionata, selezionata a metà o totalmente.
@property (strong, nonatomic) UIImage *notSelectedImage;
@property (strong, nonatomic) UIImage *halfSelectedImage;
@property (strong, nonatomic) UIImage *fullSelectedImage;
// Teniamo traccia della valutazione complessiva (float poichè avendo i mezzi voti si possono è necessario gestire la parte
// decimale.
@property (assign, nonatomic) float rating;
// Utile per far dar la possibilità o meno di  cambiare la votazione. TODO: probabilmente verrà eliminata, da vedere.
@property (assign) BOOL editable;
// Array contenente le immagini che riempiremo in base alla votazione data.
@property (strong) NSMutableArray * imageViews;
// Massimo punteggio assegnabile. Sarà 5 ai fini del'applicazione ma può essere utile tenere una property di questo tipo
// Per eventuali cambiamenti futuri.
@property (assign, nonatomic) int maxRating;
// Minimo e massimo valore assegnabile.
@property (assign) int midMargin;
@property (assign) int  leftMargin;
// Gestione delle misure tra una stella e l'altra.
@property (assign) CGSize minImageSize;
// Oggetto, di qualsiasi tipo ma che implementi il protocollo RateViewDelegate, che sarà il nostro delegate.
@property (assign) id <StarRatingViewDelegate> delegate;

@end