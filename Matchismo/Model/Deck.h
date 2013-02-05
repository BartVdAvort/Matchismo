//
//  Deck.h
//  Matchismo
//
//  Created by Frédéric ADDA on 30/01/13.
//  Copyright (c) 2013 Frédéric ADDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;
@interface Deck : NSObject

- (void)addCard:(Card*)card atTop:(BOOL)atTop;
- (Card *)drawRandomCard;

@end
