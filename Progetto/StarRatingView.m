#import "StarRatingView.h"

@implementation StarRatingView

// Sintetizzo le properties (non necessario in quanto, con questi parametri, ci penserebbe XCode di suo)
@synthesize notSelectedImage = _notSelectedImage;
@synthesize halfSelectedImage = _halfSelectedImage;
@synthesize fullSelectedImage = _fullSelectedImage;
@synthesize rating = _rating;
@synthesize editable = _editable;
@synthesize imageViews = _imageViews;
@synthesize maxRating = _maxRating;
@synthesize midMargin = _midMargin;
@synthesize leftMargin = _leftMargin;
@synthesize minImageSize = _minImageSize;
@synthesize delegate = _delegate;

// Inizializzatore base, in cui non imposto nessuna immagine, imposto punteggio minimo e massimo, la distanza tra le stelle
// e altri assegnamenti di ruotine.
- (void)baseInit {
    _notSelectedImage = nil;
    _halfSelectedImage = nil;
    _fullSelectedImage = nil;
    _rating = 0;
    _editable = NO;
    _imageViews = [[NSMutableArray alloc] init];
    _maxRating = 5;
    _midMargin = 5;
    _leftMargin = 0;
    _minImageSize = CGSizeMake(5, 5);
    _delegate = nil;
}

// Per inizializzare il rater da Interface Builder.
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}


// Per ogni immagine nella lista assegno il valore adatto in base al rating.
- (void)refresh {
    for(int i = 0; i < self.imageViews.count; ++i) {
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        if (self.rating >= i+1) {
            imageView.image = self.fullSelectedImage;
        } else if (self.rating > i) {
            imageView.image = self.halfSelectedImage;
        } else {
            imageView.image = self.notSelectedImage;
        }
    }
}

/* Funzione richiamata ogni qualvolta il rettangolo della nostra View cambia, e pertanto si dovranno reimpostare tutti i rettangoli delle subviews contenenti le stelle in modo appropriato in base alle nuove dimensioni.
 
*/
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //Se l'immagine non è selezionata, non c'è nulla da sistemare.
    if (self.notSelectedImage == nil) return;
    
    /*
        Le stelle, subiviews, avranno tutte un margine sinistro (leftMargin) e uno in mezzo (midMargin), fino ad arrivare
        all'ultima con un solo midMargin. In caso di resize del rettangolo dovremo quindi ricreare il nuovo sotto rettangolo
        prendendo la lunghezza del vecchio rettangolo, eliminare gli estremi assoluti (i due left margin) e i margini che di
        vidono un'app dall'altra (mid margin). Ottenuta la lunghezza temporanea, la dividerò per il numero di immagini
        ottendo la nuova dimensione del sottorettangolo per ciascuna immagine. Per evitare che le dimensioni dell'immagini
        possano uscire fuori dal nuovo reticolo, prenderò altezza e larghezza scegliendo il massimo valore tra le dimensioni
        minimi necessarie per contenere le view e quelle ottenute.
     */
    float desiredImageWidth = (self.frame.size.width - (self.leftMargin*2) - (self.midMargin*self.imageViews.count)) / self.imageViews.count;
    float imageWidth = MAX(self.minImageSize.width, desiredImageWidth);
    float imageHeight = MAX(self.minImageSize.height, self.frame.size.height);
    
    //Applicherò i calcoli ottenuti ad ogni immagine.
    for (int i = 0; i < self.imageViews.count; ++i) {
        
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        CGRect imageFrame = CGRectMake(self.leftMargin + i*(self.midMargin+imageWidth), 0, imageWidth, imageHeight);
        imageView.frame = imageFrame;
        
    }
    
  
}

// Imposto il voto massimo dell'immagine. Una volta impostato, rimuovo tutte le stelle e ne aggiungo per una punteggio
// di rating, facendo un refresh di tutti gli elementi aggiunti in modo tale da impostare le proporzioni corrette.
- (void)setMaxRating:(int)maxRating {
    _maxRating = maxRating;
    
    // Rimozione
    for(int i = 0; i < self.imageViews.count; ++i) {
        UIImageView *imageView = (UIImageView *) [self.imageViews objectAtIndex:i];
        [imageView removeFromSuperview];
    }
    [self.imageViews removeAllObjects];
    
    // Aggiunta
    for(int i = 0; i < maxRating; ++i) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageViews addObject:imageView];
        [self addSubview:imageView];
    }
    
    // Resizing
    [self setNeedsLayout];
    [self refresh];
}

- (void)setNotSelectedImage:(UIImage *)image {
    _notSelectedImage = image;
    [self refresh];
}

- (void)setHalfSelectedImage:(UIImage *)image {
    _halfSelectedImage = image;
    [self refresh];
}

- (void)setFullSelectedImage:(UIImage *)image {
    _fullSelectedImage = image;
    [self refresh];
}

- (void)setRating:(float)rating {
    _rating = rating;
    [self refresh];
}


- (void)handleTouchAtLocation:(CGPoint)touchLocation {
    if (!self.editable) return;
    
    int newRating = 0;
    for(int i = (int)self.imageViews.count - 1; i >= 0; i--) {
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        if (touchLocation.x > imageView.frame.origin.x) {
            newRating = i+1;
            break;
        }
    }
    
    self.rating = newRating;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate StarRatingView:self ratingDidChange:self.rating];
}
@end
