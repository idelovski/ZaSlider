//
//  GamePacket.m
//  ZaSlider
//
//  Created by Igor Delovski on 16.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "GamePacket.h"


@implementation  GamePacket

@synthesize  packType, theDieRoll, fromLocIndex, toLocIndex;

- (id)initWithType:(PacketType)inType
           dieRoll:(NSUInteger)inDieRoll
              from:(NSUInteger)frmLocIdx
                to:(NSUInteger)toLocIdx;
{
   if (self = [super init])  {
      packType = inType;
      theDieRoll = inDieRoll;
      fromLocIndex = frmLocIdx;
      toLocIndex   = toLocIdx;
   }
   
   return (self);
}

// extra initializers

- (id)initDieRollPacket
{
   NSUInteger  roll = rollTheDie ();
   
   /*char       *testPtr = (char *)&roll;
   
   if (*testPtr)  // intel but not really
      roll = 10000;*/
   
   return ([self initWithType:kPacketTypeDieRoll dieRoll:roll from:0 to:0]);
}

- (id)initDieRollPacketWithRoll:(NSUInteger)inDieRoll
{
   return ([self initWithType:kPacketTypeDieRoll dieRoll:inDieRoll from:0 to:0]);
}

- (id)initAckPacketWithDieRoll:(NSUInteger)inDieRoll
{
   return ([self initWithType:kPacketTypeAck dieRoll:inDieRoll from:0 to:0]);
}

#pragma mark -
/*
- (id)initPlayerAckPacket
{
   return ([self initWithType:kPacketTypePlayerAck dieRoll:0 from:0 to:0]);
}
*/
#pragma mark -

- (id)initImgInfoRequestPacket
{
   return ([self initWithType:kPacketTypeImgInfoRequest dieRoll:0 from:0 to:0]);
}
- (id)initImgDataRequestPacket
{
   return ([self initWithType:kPacketTypeImgDataRequest dieRoll:0 from:0 to:0]);
}
/*
- (id)initImgAckPacket
{
   return ([self initWithType:kPacketTypeImgAck dieRoll:0 from:0 to:0]);
}*/
/*
- (id)initGameInfoAckPacket
{
   return ([self initWithType:kPacketTypeGameInfoAck dieRoll:0 from:0 to:0]);
}*/
#pragma mark -

/*
- (id)initMovePacketWithFromLocIndex:(NSUInteger)frmLocIdx andToLocIndex:(NSUInteger)toLocIdx
{
   return ([self initWithType:kPacketTypeMove dieRoll:0 from:frmLocIdx to:toLocIdx]);
}*/
/*
- (id)initMoveAckPacket
{
   return ([self initWithType:kPacketTypeMoveAck dieRoll:0 from:0 to:0]);
}*/

#pragma mark -

/*- (id)initTouchPacketWithLocIndex:(NSUInteger)locIdx
{
   return ([self initWithType:kPacketTypeTouch dieRoll:0 from:locIdx to:0]);
}*/
/*- (id)initTouchAckPacket
{
   return ([self initWithType:kPacketTypeTouchAck dieRoll:0 from:0 to:0]);
}*/

#pragma mark -

- (id)initBitteWartenPacket
{
   return ([self initWithType:kPacketTypeBitteWarten dieRoll:0 from:0 to:0]);
}
/*- (id)initBitteWartenAckPacket
{
   return ([self initWithType:kPacketTypeBitteWartenAck dieRoll:0 from:0 to:0]);
}*/
#pragma mark -

- (id)initResetPacket
{
   return ([self initWithType:kPacketTypeReset dieRoll:0 from:0 to:0]);
}

/*
- (id)initGameOverWithSecondsInGame:(NSUInteger)secondsInGame
{
   return ([self initWithType:kPacketTypeTime dieRoll:secondsInGame from:0 to:0]);
}
*/
/*- (id)initQuitPacket
{
   return ([self initWithType:kPacketTypeQuit dieRoll:0 from:0 to:0]);
}*/

#pragma mark -

- (void)dealloc
{
   [super dealloc];
}

- (NSString *)description
{
   NSString *typeString = nil;
   
   switch (packType) {
      case kPacketTypeDieRoll:
         typeString = @"Die Roll";
         break;
      case kPacketTypeMove:
         typeString = @"Move";
         break;
      case kPacketTypeAck:
         typeString = @"Ack";
         break;
      case kPacketTypeReset:
         typeString = @"Reset";
         break;
      default:
         break;
   }
   
   return ([NSString stringWithFormat:@"%@ (info: %d from: %d to: %d)",
            typeString, theDieRoll, fromLocIndex, toLocIndex]);
}

#pragma mark -
#pragma mark NSCoder (Archiving)

- (void)encodeWithCoder:(NSCoder *)coder
{
   [coder encodeInt:self.packType  forKey:kGPPacketTypeKey];
   [coder encodeInteger:self.theDieRoll  forKey:kGPRollKey];
   [coder encodeInt:self.fromLocIndex  forKey:kGPFromLocIdxKey];
   [coder encodeInt:self.toLocIndex  forKey:kGPToLocIdxKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
   if (self = [super init])  {
      self.packType   = [coder decodeIntForKey:kGPPacketTypeKey];
      self.theDieRoll = [coder decodeIntegerForKey:kGPRollKey];
      self.fromLocIndex = [coder decodeIntForKey:kGPFromLocIdxKey];
      self.toLocIndex   = [coder decodeIntForKey:kGPToLocIdxKey];
   }
   
   return (self);
}

@end


#pragma mark -
#pragma mark PlayerInfoPacket
#pragma mark -

@implementation PlayerInfoPacket

@synthesize  playerName;

- (id)initWithPlayerName:(NSString *)plrName;
{
   if (self = [super init])  {
      self.playerName = plrName;
   }
   
   return (self);
}

- (void)dealloc
{
   [playerName release];
   
   [super dealloc];
}

#pragma mark -
#pragma mark NSCoder (Archiving)

- (void)encodeWithCoder:(NSCoder *)coder
{
   [coder encodeObject:self.playerName  forKey:kGPPlayerNameKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
   if (self = [super init])  {
      self.playerName = [coder decodeObjectForKey:kGPPlayerNameKey];
   }
   
   return (self);
}

@end

#pragma mark -
#pragma mark ImageInfoPacket
#pragma mark -

@implementation ImageInfoPacket

@synthesize  imageKey, builtInAlbumIndex;
@synthesize  giVersionNumber, giSideElems, giShowNumbers, giShowArrow, giCooperationMode;

- (id)initWithImageKey:(NSString *)imgKey
   orBuiltInAlbumIndex:(NSUInteger)idx
   andPreferenceRecord:(PreferenceRecord *)prefPtr;
{
   if (self = [super init])  {
      self.imageKey = imgKey;
      self.builtInAlbumIndex = idx;

      self.giVersionNumber = 1;
      
      self.giSideElems   = prefPtr->pfSideElems;
      self.giShowNumbers = prefPtr->pfShowNumbers;
      // self.giShowArrow   = prefPtr->pfShowArrow;
      
      self.giCooperationMode = prefPtr->pfCooperationMode;
   }
   
   return (self);
}

- (void)dealloc
{
   [imageKey release];
   
   [super dealloc];
}

#pragma mark -
#pragma mark NSCoder (Archiving)

- (void)encodeWithCoder:(NSCoder *)coder
{
   [coder encodeObject:self.imageKey  forKey:kGPImageKeyKey];
   [coder encodeInt:self.builtInAlbumIndex  forKey:kGPAlbumIndexKey];

   [coder encodeInt:self.giSideElems  forKey:kUDSideElemsKey];
   [coder encodeBool:self.giShowNumbers  forKey:kUDShowNumbersKey];
   // [coder encodeBool:self.giShowArrow  forKey:kUDShowArrowKey];
   [coder encodeBool:self.giCooperationMode  forKey:kUDCoopModeKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
   if (self = [super init])  {
      self.imageKey          = [coder decodeObjectForKey:kGPImageKeyKey];
      self.builtInAlbumIndex = [coder decodeIntegerForKey:kGPAlbumIndexKey];

      self.giSideElems   = [coder decodeIntegerForKey:kUDSideElemsKey];
      self.giShowNumbers = [coder decodeBoolForKey:kUDShowNumbersKey];
      // self.giShowArrow   = [coder decodeBoolForKey:kUDShowArrowKey];
      self.giCooperationMode = [coder decodeBoolForKey:kUDCoopModeKey];
   }
   
   return (self);
}

@end


#pragma mark -
#pragma mark ImageDataPacket
#pragma mark -

@implementation ImageDataPacket

@synthesize  theImage, imageKey, builtInAlbumIndex;

- (id)initWithImage:(UIImage *)aImage
           ImageKey:(NSString *)imgKey
orBuiltInAlbumIndex:(NSUInteger)idx;
{
   if (self = [super init])  {
      self.theImage = aImage;
      self.imageKey = imgKey;
      self.builtInAlbumIndex = idx;
   }
   
   return (self);
}

- (void)dealloc
{
   [theImage release];
   [imageKey release];
   
   [super dealloc];
}

#pragma mark -
#pragma mark NSCoder (Archiving)

- (void)encodeWithCoder:(NSCoder *)coder
{
   NSData  *data = UIImageJPEGRepresentation (self.theImage, .5);    // get the JPEG representation of the UIImage
   
   [coder encodeObject:data forKey:kGPImageKey];   // before: [coder encodeObject:self.theImage  forKey:kGPImageKey];
   
   [coder encodeObject:self.imageKey  forKey:kGPImageKeyKey];
   [coder encodeInt:self.builtInAlbumIndex  forKey:kGPAlbumIndexKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
   if (self = [super init])  {
      // was: self.theImage = [coder decodeObjectForKey:kGPImageKey];

      NSData  *data = [coder decodeObjectForKey:kGPImageKey];
      theImage = [[UIImage alloc] initWithData:data];         // initialize the UIImage with data

      self.imageKey          = [coder decodeObjectForKey:kGPImageKeyKey];
      self.builtInAlbumIndex = [coder decodeIntegerForKey:kGPAlbumIndexKey];
   }
   
   return (self);
}

@end
