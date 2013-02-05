//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Frédéric ADDA on 30/01/13.
//  Copyright (c) 2013 Frédéric ADDA. All rights reserved.
//

#import "CardMatchingGame.h"
#import "Deck.h"
#import "Card.h"

@interface CardMatchingGame ()
@property (strong, nonatomic) NSMutableArray *cards;
@property (nonatomic, readwrite) int score;
@property (nonatomic, readwrite, copy) NSString *flipResult;

@end


@implementation CardMatchingGame

- (NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (id)initWithCardCount:(NSUInteger)cardCount usingDeck:(Deck *)deck
{
    self = [super init];
    if (self) {
        for (int i = 0; i < cardCount; i++) {
            Card *card = [deck drawRandomCard];
            if (!card) {
                self = nil;
            } else {
                self.cards[i] = card;
            }
        }
    }
    return self;
}



#define FLIP_COST 1;
#define MATCH_BONUS 4
#define MISMATCH_PENALTY 2

- (void)flipCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    
    if (!card.isUnplayable) {
        
        if (self.mode == 0) { // 2-card matching game
            
            if (!card.isFaceUp) {
                
                // FlipResult : the CardMatchingGame knows if there is a match : it's up to the game to generate the FlipResult string (and up to the controller to display it when a card is flipped).
                
                self.flipResult = [NSString stringWithFormat:@"Flipped up %@", card.contents];
                
                // see if flipping the card up creates a match
                for (Card *otherCard in self.cards) {
                    if (otherCard.isFaceUp && !otherCard.isUnplayable) {
                        int matchScore = [card match:@[otherCard]];
                        if (matchScore) {
                            otherCard.unplayable = YES;
                            card.unplayable = YES;
                            self.score += matchScore * MATCH_BONUS;
                            
                            NSArray *matchString = @[@"Matched", card.contents, @"&", otherCard.contents, @"for", [NSNumber numberWithInt:matchScore * MATCH_BONUS], @"points" ];
                            self.flipResult = [matchString componentsJoinedByString:@" "];
                            
                        } else {
                            otherCard.faceUp = NO;
                            self.score -= MISMATCH_PENALTY;
                            
                            NSArray *mismatchString = @[card.contents, @"and", otherCard.contents, @"don't match:", [NSNumber numberWithInt:MISMATCH_PENALTY], @"points penalty !" ];
                            self.flipResult = [mismatchString componentsJoinedByString:@" "];
                        }
                        break;
                    }
                }
                self.score -= FLIP_COST;
            }
            card.faceUp = !card.isFaceUp;
            
            
            
        } else if (self.mode == 1) { // 3-card matching game
            
            // Create a mutable array containing all the cards face up
            NSMutableArray *cardsFaceUpArray = [[NSMutableArray alloc] init];
                        
            if (!card.isFaceUp) {

                self.flipResult = [NSString stringWithFormat:@"Flipped up %@", card.contents];
                
                for (Card *otherCard in self.cards) {
                    if (otherCard.isFaceUp && !otherCard.isUnplayable && ![cardsFaceUpArray containsObject:otherCard]) {
                        [cardsFaceUpArray addObject:otherCard];
                        NSLog(@"cardsFaceUp array contains %d cards, added %@", [cardsFaceUpArray count], otherCard.contents);
                    }
                }

                self.score -= FLIP_COST;
                
                
                if ([cardsFaceUpArray count] == 2) {
                    // Two other cards have been turned up
                    Card *firstOtherCard = cardsFaceUpArray[0];
                    Card *secondOtherCard = cardsFaceUpArray[1];
                    
                    int matchScore = [card match:cardsFaceUpArray];
                    if (matchScore) {
                        // There is a match within the 3 cards (the PlayingCard class knows how to handle the score)
                        self.score += matchScore * MATCH_BONUS;
                        // 3-card match !
                        self.flipResult = [NSString stringWithFormat:@"3-cards match for %d points", matchScore * MATCH_BONUS];
                        
                        card.unplayable = YES;
                        firstOtherCard.unplayable = YES;
                        secondOtherCard.unplayable = YES;
                                
                        // Keep face up any other cards which matched
                        firstOtherCard.faceUp = firstOtherCard.isUnplayable;
                        secondOtherCard.faceUp = secondOtherCard.isUnplayable;
                        
                    } else {
                        // Turn back all cards
                        firstOtherCard.faceUp = NO;
                        secondOtherCard.faceUp = NO;
                        
                        self.score -= MISMATCH_PENALTY;
                        
                        self.flipResult = [NSString stringWithFormat:@"No card did match : %d points penalty !", MISMATCH_PENALTY];
                    }
                    cardsFaceUpArray = nil;
                }
            }
            card.faceUp = card.isUnplayable ? YES : !card.isFaceUp;
        }
    }
}


- (Card *)cardAtIndex:(NSUInteger)index
{
    return (index < self.cards.count) ? self.cards[index] : nil;
}


@end
