//
//  PacketCategories.h
//  TicTacToe
//
//  Created by Igor Delovski on 12.08.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  kInvalidObjectException  @"Invalid Object Exception"


@interface NSArray (PacketSend)
- (NSData *)contentsForTransfer;
@end

@interface NSData (PacketSplit)
- (NSArray *)splitTransferredPackets:(NSData **)leftover;
@end
