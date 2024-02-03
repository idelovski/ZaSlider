//
//  GameHistory.m
//  ZaSlider
//
//  Created by Igor Delovski on 10.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "GameHistory.h"


@implementation GameHistory

@synthesize  opponentName, imageKey, playingDate, sideElements;
@synthesize  builtInAlbumIndex, weFinishedInSeconds, theyDidItInSeconds, usingNumbers, usingArrow, coopMode;

- (id)initWithImageKey:(NSString *)imgKey
     builtInAlbumIndex:(NSUInteger)idx
          sideElements:(NSUInteger)sideElems
          opponentName:(NSString *)theOpponent
              coopMode:(BOOL)coop
   asFinishedInSeconds:(NSUInteger)ourSecs
      opponentsSeconds:(NSUInteger)theirSecs
{
   if (self = [super init])  {
      self.opponentName =  theOpponent;
      self.imageKey =  imgKey;
      self.builtInAlbumIndex = idx;
      
      self.playingDate = [NSDate date];
      self.sideElements = sideElems;
      self.weFinishedInSeconds = ourSecs;
      self.theyDidItInSeconds = theirSecs;
      
      self.usingNumbers = gGPrefsRec.pfShowNumbers;
      // self.usingArrow   = gGPrefsRec.pfShowArrow;
      self.coopMode     = coop;
   }
   
   return (self);
}

- (id)init  // shouldn't be used ever!
{
   return ([self initWithImageKey:@"Untitled"
                builtInAlbumIndex:0
                     sideElements:3
                     opponentName:nil
                         coopMode:NO
              asFinishedInSeconds:0
                 opponentsSeconds:0]);
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
   if (self = [super init])  {
      self.opponentName = [decoder decodeObjectForKey:kGSOpponentNameKey];
      self.imageKey    = [decoder decodeObjectForKey:kGSImageKeyKey];
      
      self.playingDate = [decoder decodeObjectForKey:kGSPlayingDateKey];
      
      self.builtInAlbumIndex = [decoder decodeIntegerForKey:kGSAlbumIndexKey];
      self.sideElements = [decoder decodeIntegerForKey:kGSSideElementsKey];
      self.weFinishedInSeconds = [decoder decodeIntegerForKey:kGSSecondsInGameKey];
      self.theyDidItInSeconds = [decoder decodeIntegerForKey:kGSOpponentsSecondsKey];

      self.usingNumbers = [decoder decodeBoolForKey:kGSUsingNumbersKey];
      // self.usingArrow   = [decoder decodeBoolForKey:kGSUsingArrowKey];
      self.coopMode = [decoder decodeBoolForKey:kGSCoopModeGameKey];
}
   
   return (self);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   [coder encodeObject:self.opponentName forKey:kGSOpponentNameKey];
   [coder encodeObject:self.imageKey forKey:kGSImageKeyKey];
   
   [coder encodeObject:self.playingDate forKey:kGSPlayingDateKey];
   
   [coder encodeInteger:self.builtInAlbumIndex forKey:kGSAlbumIndexKey];
   [coder encodeInteger:self.sideElements forKey:kGSSideElementsKey];
   [coder encodeInteger:self.weFinishedInSeconds forKey:kGSSecondsInGameKey];
   [coder encodeInteger:self.theyDidItInSeconds forKey:kGSOpponentsSecondsKey];

   [coder encodeBool:self.usingNumbers forKey:kGSUsingNumbersKey];
   // [coder encodeBool:self.usingArrow forKey:kGSUsingArrowKey];
   [coder encodeBool:self.coopMode forKey:kGSCoopModeGameKey];
}

- (void)dealloc
{
   [opponentName release];
   [imageKey release];
   
   [playingDate release];
   
   [super dealloc];
}

#pragma mark -

+ (BOOL)saveGameHistoryArray:(NSArray *)ghArray toPath:(NSString *)basePath
{
   BOOL  okFlag = NO;
   
   NSString  *fullPath = [basePath stringByAppendingPathComponent:kHistoryFileSuffixAndExtension];
   
   okFlag = [NSKeyedArchiver archiveRootObject:ghArray toFile:fullPath];
   
   return (okFlag);
}

+ (NSMutableArray *)loadGameHistoryArrayFromPath:(NSString *)basePath
{
   NSMutableArray  *loadedHistory;

#ifdef _FILES_LOG_
   NSLog (@"%s - loadFromPath: %@", __FILE__, basePath);
#endif
   
   NSString  *fullPath = [basePath stringByAppendingPathComponent:kHistoryFileSuffixAndExtension];
   
   loadedHistory = [[NSKeyedUnarchiver unarchiveObjectWithFile:fullPath] mutableCopy];
   
   return ([loadedHistory autorelease]);
}

#pragma mark -

+ (NSString *)secondsToString:(NSUInteger)secs withDescription:(BOOL)descFlag
{
   NSUInteger  justSeconds = secs % 60;
   NSUInteger  justMinutes = secs / 60;
   
   NSString   *tmpStr;
   
   if (descFlag)  {
      if (justMinutes)
         tmpStr = [NSString stringWithFormat:@"Finished in %2d min %2d sec", justMinutes, justSeconds];
      else
         tmpStr = [NSString stringWithFormat:@"Finished in %2d sec", justSeconds];
   }
   else
      tmpStr = [NSString stringWithFormat:@"%02d:%02d", justMinutes, justSeconds];
   
   return (tmpStr);
}

@end
