//
//  GameHistory.h
//  ZaSlider
//
//  Created by Igor Delovski on 10.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  kMaxGamesInHistory  50

extern PreferenceRecord  gGPrefsRec;

@interface GameHistory : NSObject <NSCoding>  {
   // Won/Lost, if there was oponent
   NSString        *opponentName;      // used only in net version
   NSString        *imageKey;
   NSDate          *playingDate;
   
   NSUInteger       builtInAlbumIndex;  // used when there's no key
   NSUInteger       sideElements;
   NSUInteger       weFinishedInSeconds;
   NSUInteger       theyDidItInSeconds;    // used if net play
   
   BOOL             usingNumbers;
   BOOL             usingArrow;
   BOOL             coopMode;
}

@property (nonatomic, retain)  NSString        *opponentName;
@property (nonatomic, retain)  NSString        *imageKey;
@property (nonatomic, retain)  NSDate          *playingDate;

@property                      NSUInteger       builtInAlbumIndex;
@property                      NSUInteger       sideElements;
@property                      NSUInteger       weFinishedInSeconds;
@property                      NSUInteger       theyDidItInSeconds;
@property                      BOOL             usingNumbers;
@property                      BOOL             usingArrow;
@property                      BOOL             coopMode;

- (id)initWithImageKey:(NSString *)imgKey
     builtInAlbumIndex:(NSUInteger)idx
          sideElements:(NSUInteger)sideElems
          opponentName:(NSString *)theOpponent
              coopMode:(BOOL)coop
   asFinishedInSeconds:(NSUInteger)ourSecs
      opponentsSeconds:(NSUInteger)theirSecs;

+ (BOOL)saveGameHistoryArray:(NSArray *)ghArray toPath:(NSString *)basePath;
+ (NSMutableArray *)loadGameHistoryArrayFromPath:(NSString *)basePath;
+ (NSString *)secondsToString:(NSUInteger)secs withDescription:(BOOL)descFlag;

@end
