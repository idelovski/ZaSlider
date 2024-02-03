//
//  GameState.m
//  ZaSlider
//
//  Created by Igor Delovski on 30.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "GameState.h"


@implementation  GameState

@synthesize  opponentName, imageKey, tileLocations, playingDate, sideElements;
@synthesize  emptyTileLocIndex, builtInAlbumIndex, secondsInGame, coopMode;

- (id)initWithImageKey:(NSString *)imgKey
     builtInAlbumIndex:(NSUInteger)idx
          sideElements:(NSUInteger)sideElems
              coopMode:(BOOL)coop
      andSecondsInGame:(NSUInteger)secs
{
   if (self = [super init])  {
      self.opponentName =  nil;
      self.imageKey =  imgKey;
      self.builtInAlbumIndex = idx;
      self.tileLocations = [[NSMutableArray alloc] init];  // initial locations
      
      self.playingDate = [NSDate date];
      self.sideElements = sideElems;
      
      self.emptyTileLocIndex = 0;
      self.secondsInGame = secs;
      
      self.coopMode = coop;
   }
   
   return (self);
}

- (id)init  // shouldn't be used ever!
{
   return ([self initWithImageKey:@"Untitled" builtInAlbumIndex:0 sideElements:3 coopMode:NO andSecondsInGame:0]);
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
   if (self = [super init])  {
      self.opponentName = [decoder decodeObjectForKey:kGSOpponentNameKey];
      self.imageKey    = [decoder decodeObjectForKey:kGSImageKeyKey];
      
      tileLocations = [[decoder decodeObjectForKey:kGSTileLocationsKey] mutableCopy];  // direct assignment!
      self.playingDate = [decoder decodeObjectForKey:kGSPlayingDateKey];
      
      self.builtInAlbumIndex = [decoder decodeIntegerForKey:kGSAlbumIndexKey];
      self.sideElements = [decoder decodeIntegerForKey:kGSSideElementsKey];
      self.emptyTileLocIndex = [decoder decodeIntegerForKey:kGSEmptyTileLocKey];
      self.secondsInGame = [decoder decodeIntegerForKey:kGSSecondsInGameKey];
      self.coopMode = [decoder decodeBoolForKey:kGSCoopModeGameKey];
   }
   
   return (self);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   [coder encodeObject:self.opponentName forKey:kGSOpponentNameKey];
   [coder encodeObject:self.imageKey forKey:kGSImageKeyKey];

   [coder encodeObject:self.tileLocations forKey:kGSTileLocationsKey];
   [coder encodeObject:self.playingDate forKey:kGSPlayingDateKey];
   
   [coder encodeInteger:self.builtInAlbumIndex forKey:kGSAlbumIndexKey];
   [coder encodeInteger:self.sideElements forKey:kGSSideElementsKey];
   [coder encodeInteger:self.emptyTileLocIndex forKey:kGSEmptyTileLocKey];
   [coder encodeInteger:self.secondsInGame forKey:kGSSecondsInGameKey];
   [coder encodeBool:self.coopMode forKey:kGSCoopModeGameKey];
}

- (void)dealloc
{
   [opponentName release];
   [imageKey release];
   
   [tileLocations release];
   [playingDate release];
   
   [super dealloc];
}

#pragma mark -
#pragma mark Convenience shit

- (NSInteger)tileLocationAtIndex:(NSInteger)idx  // returns its initial location, idx is current location
{
   NSNumber  *tmpNumber = [self.tileLocations objectAtIndex:idx];
   
   if (tmpNumber)
      return ([tmpNumber intValue]);
   
   NSLog (@"tileLocationAtIndex - No index!");
   
   return (-1);
}

#pragma mark -

+ (NSString *)fullFileNameWithName:(NSString *)aName
{
   NSString  *tmpStr = [NSString stringWithFormat:@"%@_%@", aName, kGameFileSuffixAndExtension];
   
   return (tmpStr);
}

- (BOOL)saveToPath:(NSString *)basePath fileName:(NSString *)aName
{
   BOOL  okFlag = NO;
   
   NSString  *fullPath = [basePath stringByAppendingPathComponent:[GameState fullFileNameWithName:aName]];
      
   okFlag = [NSKeyedArchiver archiveRootObject:self toFile:fullPath];
   
   return (okFlag);
}

+ (GameState *)loadFromPath:(NSString *)basePath andFileName:(NSString *)aName
{
   GameState  *loadedAlbum;
   
#ifdef _FILES_LOG_
   NSLog (@"%s - loadFromPath: %@", __FILE__, basePath);
#endif   
   NSString  *fullPath = [basePath stringByAppendingPathComponent:[self fullFileNameWithName:aName]];
   
   loadedAlbum = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
   
   return (loadedAlbum);  // already marked for autorelease
}

// --

+ (void)deleteFileName:(NSString *)aName atPath:(NSString *)basePath
{
   BOOL  okFlag = NO;
   
   NSString  *fullPath = [basePath stringByAppendingPathComponent:[GameState fullFileNameWithName:aName]];
   
   if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
      okFlag = [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
}


@end
