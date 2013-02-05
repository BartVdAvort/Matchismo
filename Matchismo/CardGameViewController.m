//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Frédéric ADDA on 30/01/13.
//  Copyright (c) 2013 Frédéric ADDA. All rights reserved.
//

#import "CardGameViewController.h"
#import "Card.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"


@interface CardGameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) int flipCount;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (strong, nonatomic) CardMatchingGame *game;
@property (weak, nonatomic) IBOutlet UILabel *flipResultLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISlider *flipResultsHistorySlider;
@property (strong, nonatomic) NSMutableArray *flipResultsHistory;
@property (weak, nonatomic) IBOutlet UILabel *sliderValue;
@end



@implementation CardGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.flipResultLabel.text = @""; // set the flipResult to blank when view has loaded
    self.gameModeSegmentedControl.selectedSegmentIndex = 0; // default = 2-card game when view has loaded
    
    // UISlider defaults
    self.sliderValue.text = @"";
    self.sliderValue.hidden = YES; // TEST
    self.flipResultsHistorySlider.maximumValue = 0;
}

#pragma mark - override setters and getters

- (CardMatchingGame *)game
{
    if (!_game) _game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                          usingDeck:[[PlayingCardDeck alloc] init]];
    return _game;
}


- (NSMutableArray *)flipResultsHistory
{
    if (!_flipResultsHistory) _flipResultsHistory = [[NSMutableArray alloc] init];
    return _flipResultsHistory;
}

- (void)setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
}


- (void)setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    [self updateUI];
}

#pragma mark - game-specific methods
- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons) {
        Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        [cardButton setTitle:@"" forState:UIControlStateNormal];
        [cardButton setTitle:card.contents forState:UIControlStateSelected];
        [cardButton setTitle:card.contents forState:UIControlStateSelected | UIControlStateDisabled];
        
        cardButton.selected = card.isFaceUp;
        cardButton.enabled = !card.isUnplayable;
        cardButton.alpha = card.isUnplayable ? 0.3 : 1.0;
   
        // Back of the card as an image
        UIImage *cardBackImage = [UIImage imageNamed:@"cardback.png"];
        [cardButton setImage:cardBackImage forState:UIControlStateNormal];

        [cardButton setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        [cardButton setImage:[[UIImage alloc] init] forState:UIControlStateSelected | UIControlStateDisabled];
        cardButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
//    self.flipResultLabel.text = self.game.flipResult;

    if (self.game.flipResult && ![self.flipResultsHistory containsObject:self.game.flipResult])
        [self.flipResultsHistory addObject:self.game.flipResult];
    NSLog(@"%i entries in flipResultsHistory", [self.flipResultsHistory count]);
    
    if ([self.flipResultsHistory count] > 0) {
        self.flipResultsHistorySlider.maximumValue = [self.flipResultsHistory count] - 1; // maximum value of the slider = index in the array
        [self.flipResultsHistorySlider setValue:[self.flipResultsHistory indexOfObject:self.flipResultsHistory.lastObject] animated:NO];
    }
    [self updateFlipResult];
}


- (void)updateFlipResult
{
    // Flip results history & slider
    if ([self.flipResultsHistory count] > 0) {
        // for test purposes
        self.sliderValue.text = [NSString stringWithFormat:@"%0.1f", self.flipResultsHistorySlider.value];

        self.flipResultLabel.text = self.flipResultsHistory[lroundf(self.flipResultsHistorySlider.value)];
        
     if (self.flipResultsHistorySlider.maximumValue >= 1)
         self.flipResultLabel.alpha = MAX(0.30, lroundf(self.flipResultsHistorySlider.value + 1) / (self.flipResultsHistorySlider.maximumValue + 1));
        NSLog(@"Alpha : %0.2f", self.flipResultLabel.alpha);
    }
}

- (IBAction)flipCard:(UIButton *)sender
{
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    self.flipCount ++;
    self.gameModeSegmentedControl.enabled = NO;
    [self updateUI];
}

- (IBAction)deal
{
    self.game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                  usingDeck:[[PlayingCardDeck alloc] init]];
    self.flipResultLabel.text = @"";
    self.flipCount = 0;
    self.gameModeSegmentedControl.enabled = YES;
    self.gameModeSegmentedControl.selectedSegmentIndex = 0; // default = 2-card game when dealt again
    self.flipResultsHistory = nil;
    
    [self updateUI];
}

- (IBAction)changedGameMode:(id)sender
{
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
        self.game.mode = segmentedControl.selectedSegmentIndex;
        NSLog(@"Game mode : %i", self.game.mode);
    }
    
}
- (IBAction)sliderThumbMoved
{ 
    [self updateFlipResult];
}

@end
