//
//  PlayingCard.m
//  Matchismo
//
//  Created by Frédéric ADDA on 30/01/13.
//  Copyright (c) 2013 Frédéric ADDA. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

@synthesize suit = _suit; // because we provide both the getter and the setter

#pragma mark - Class methods
+ (NSArray *)validSuit
{
    static NSArray *validSuits = nil;
    if (!validSuits) validSuits =  @[@"♥", @"♦", @"♣", @"♠"];
    return validSuits;
}

+ (NSArray *)rankStrings
{
    static NSArray *rankStrings = nil;
    if (!rankStrings) rankStrings =  @[@"?", @"A", @"2", @"3",@"4", @"5", @"6", @"7", @"8",@"9", @"10", @"J", @"Q", @"K"];
    return rankStrings;
}

+ (NSUInteger)maxRank
{
    return [self rankStrings].count - 1;
}

#pragma mark - Override setters and getters

- (NSString *)contents
{
    NSArray *rankStrings = [PlayingCard rankStrings];
    return [rankStrings[self.rank] stringByAppendingString:self.suit];
}


- (NSString *)suit
{
    return _suit ? _suit : @"?";
}

- (void)setSuit:(NSString *)suit
{
    if ([[PlayingCard validSuit] containsObject:suit]) {
        _suit = suit;
    }
}

- (void)setRank:(NSUInteger)rank
{
    if (rank <= [PlayingCard maxRank]) {
        _rank = rank;
    }
}

#pragma mark - Override Card match: method
- (int)match:(NSArray *)otherCards
{
    int score = 0;
    
    if (otherCards.count == 1) {
        Card *otherCard = [otherCards lastObject];
        if ([otherCard isKindOfClass:[PlayingCard class]]) {
            PlayingCard *otherPlayingCard = (PlayingCard *)otherCard;
            if ([otherPlayingCard.suit isEqualToString:self.suit]) { // 2 cards out of 2 with the same suit (medium)
                score = 2;
            } else if (otherPlayingCard.rank == self.rank){ // 2 cards out of 2 with the same rank (medium)
                score = 8;
            }
        }
    } else if (otherCards.count == 2) {
        Card *otherFirstCard = otherCards[0];
        Card *otherSecondCard = otherCards[1];
        
        if ([otherFirstCard isKindOfClass:[PlayingCard class]] && [otherSecondCard isKindOfClass:[PlayingCard class]]) {
            PlayingCard *otherFirstPlayingCard = (PlayingCard *)otherFirstCard;
            PlayingCard *otherSecondPlayingCard = (PlayingCard *)otherSecondCard;
            
            if (otherFirstPlayingCard.rank == self.rank &&
                otherSecondPlayingCard.rank == self.rank) { // 3 cards out of 3 with the same rank (super hard)
                score = 200;
            } else if ([otherFirstPlayingCard.suit isEqualToString:self.suit] &&
                [otherSecondPlayingCard.suit isEqualToString:self.suit]) { // 3 cards out of 3 with the same suit (hard)
                score = 10;
              
            } else if (otherFirstPlayingCard.rank == self.rank ||
                       otherSecondPlayingCard.rank == self.rank ||
                       otherFirstPlayingCard.rank == otherSecondPlayingCard.rank) { // 2 cards out of 3 with the same rank (easy)
                score = 4;
            } else if ([otherFirstPlayingCard.suit isEqualToString:self.suit] ||
                [otherSecondPlayingCard.suit isEqualToString:self.suit] ||
                [otherFirstPlayingCard.suit isEqualToString:otherSecondPlayingCard.suit]) { // 2 cards out of 3 with the same suit (easy)
                score = 1;
            }
        }
    }
    
    return score;
}


@end