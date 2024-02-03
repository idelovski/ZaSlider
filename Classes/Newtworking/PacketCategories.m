//
//  PacketCategories.m
//  TicTacToe
//
//  Created by Igor Delovski on 12.08.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "PacketCategories.h"

@implementation NSArray (PacketSend)

- (NSData *)contentsForTransfer
{
   NSMutableData  *ret = [NSMutableData data];
   
   for (NSData *oneData in self)  {
      if (![oneData isKindOfClass:[NSData class]])
         [NSException raise:kInvalidObjectException format:@"array contentsForTransfer only supports instances of NSData"];
      
      uint32_t  dataSize = htonl([oneData length]);
      [ret appendBytes:&dataSize length:sizeof(uint32_t)];
      [ret appendBytes:[oneData bytes] length:[oneData length]];
   }
   
   return (ret);
}

@end

#pragma mark -

@implementation NSData (PacketSplit)

- (NSArray *)splitTransferredPackets:(NSData **)leftover
{
   NSMutableArray       *ret = [NSMutableArray array];
   const unsigned char  *buffPtr = [self bytes];
   const unsigned char  *curRecPtr = buffPtr;
   const unsigned char  *bytesEnd = buffPtr + [self length];
   
   // NSLog (@"splitTransferredPackets: - bytes: %d", [self length]);
   
   while (curRecPtr < bytesEnd)  {
      uint32_t   dataSize;
      NSInteger  dataSizeInfoOffset    = curRecPtr - buffPtr;
      NSInteger  dataPayloadOffset = dataSizeInfoOffset + sizeof(uint32_t);
      
      if ((curRecPtr + sizeof(uint32_t)) <= bytesEnd)  {
         NSRange    headerRange = NSMakeRange (dataSizeInfoOffset, sizeof(uint32_t));
         [self getBytes:&dataSize range:headerRange];
         dataSize = ntohl (dataSize);
      }
      
      // NSLog (@"splitTransferredPackets: - dataSize: %d", dataSize);

      if (((curRecPtr + sizeof(uint32_t)) > bytesEnd) ||                        // not even 4 bytes
          (buffPtr + dataPayloadOffset + dataSize > bytesEnd))  {   // or not for complete record
         NSInteger  lengthOfRemainingData = [self length] - dataSizeInfoOffset;
         NSRange    dataRange = NSMakeRange (dataSizeInfoOffset, lengthOfRemainingData);
         
         *leftover = [self subdataWithRange:dataRange];
         
         NSLog (@"splitTransferredPackets: - leftover: %d", lengthOfRemainingData);

         return (ret);
      }
      
      NSRange  dataRange = NSMakeRange (dataPayloadOffset, dataSize);
      NSData  *parsedData = [self subdataWithRange:dataRange];
      
      [ret addObject:parsedData];
      
      curRecPtr += dataSize + sizeof (uint32_t);
   }
   
   return (ret);
}

@end
