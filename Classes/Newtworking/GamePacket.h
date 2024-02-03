//
//  GamePacket.h
//  ZaSlider
//
//  Created by Igor Delovski on 16.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark GamePacket
#pragma mark -

@interface GamePacket : NSObject <NSCoding>  {
   PacketType  packType;
   NSUInteger  theDieRoll;
   NSUInteger  fromLocIndex;
   NSUInteger  toLocIndex;
}

@property  PacketType  packType;
@property  NSUInteger  theDieRoll;
@property  NSUInteger  fromLocIndex;
@property  NSUInteger  toLocIndex;

- (id)initWithType:(PacketType)inType
           dieRoll:(NSUInteger)inDieRoll
              from:(NSUInteger)frmLocIdx
                to:(NSUInteger)toLocIdx;

- (id)initDieRollPacket;
- (id)initDieRollPacketWithRoll:(NSUInteger)inDieRoll;
- (id)initAckPacketWithDieRoll:(NSUInteger)inDieRoll;

// - (id)initPlayerAckPacket;

- (id)initImgInfoRequestPacket;
- (id)initImgDataRequestPacket;
// - (id)initImgAckPacket;

// - (id)initMovePacketWithFromLocIndex:(NSUInteger)frmLocIdx andToLocIndex:(NSUInteger)toLocIdx;
// - (id)initMoveAckPacket;

// - (id)initTouchPacketWithLocIndex:(NSUInteger)locIdx;
// - (id)initTouchAckPacket;

- (id)initBitteWartenPacket;
// - (id)initBitteWartenAckPacket;

- (id)initResetPacket;
// - (id)initGameOverWithSecondsInGame:(NSUInteger)secondsInGame;
// - (id)initQuitPacket;

@end

#pragma mark -
#pragma mark PlayerInfoPacket
#pragma mark -

@interface PlayerInfoPacket : NSObject <NSCoding>  {
   NSString   *playerName;
}

@property (nonatomic, retain)  NSString   *playerName;

- (id)initWithPlayerName:(NSString *)plrName;

@end


// One day change its name so it tells there's more than just image info

#pragma mark -
#pragma mark ImageInfoPacket
#pragma mark -

@interface ImageInfoPacket : NSObject <NSCoding>  {
   NSUInteger  giVersionNumber;          // starting with ver 1

   NSString   *imageKey;
   NSUInteger  builtInAlbumIndex;
   NSInteger   giSideElems;
   
   BOOL        giShowNumbers;
   BOOL        giShowArrow;
   BOOL        giCooperationMode;
}

@property                      NSUInteger  giVersionNumber;

@property (nonatomic, retain)  NSString   *imageKey;
@property                      NSUInteger  builtInAlbumIndex;
@property                      NSInteger   giSideElems;

@property                      BOOL        giShowNumbers;
@property                      BOOL        giShowArrow;
@property                      BOOL        giCooperationMode;

- (id)initWithImageKey:(NSString *)imgKey
   orBuiltInAlbumIndex:(NSUInteger)idx
   andPreferenceRecord:(PreferenceRecord *)prefPtr;

@end

#pragma mark -
#pragma mark ImageDataPacket
#pragma mark -

@interface ImageDataPacket : NSObject <NSCoding>  {
   UIImage    *theImage;
   NSString   *imageKey;
   NSUInteger  builtInAlbumIndex;
}

@property (nonatomic, retain)  UIImage    *theImage;
@property (nonatomic, retain)  NSString   *imageKey;
@property                      NSUInteger  builtInAlbumIndex;

- (id)initWithImage:(UIImage *)aImage
           ImageKey:(NSString *)imgKey
   orBuiltInAlbumIndex:(NSUInteger)idx;

@end

