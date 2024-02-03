//
//  GameState.h
//  ZaSlider
//
//  Created by Igor Delovski on 30.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GameState : NSObject <NSCoding>  {
   NSString        *opponentName;      // used only in net version
   NSString        *imageKey;
   NSMutableArray  *tileLocations;    // of NSNumber
   NSDate          *playingDate;
   
   NSUInteger       builtInAlbumIndex;  // used when there's no key
   NSUInteger       sideElements;
   NSUInteger       secondsInGame;
   NSInteger        emptyTileLocIndex;
   BOOL             coopMode;
}

@property (nonatomic, retain)  NSString        *opponentName;
@property (nonatomic, retain)  NSString        *imageKey;
@property (nonatomic, retain)  NSMutableArray  *tileLocations;    // of NSNumber
@property (nonatomic, retain)  NSDate          *playingDate;

@property                      NSUInteger       builtInAlbumIndex;
@property                      NSUInteger       sideElements;
@property                      NSUInteger       secondsInGame;
@property                      NSInteger        emptyTileLocIndex;
@property                      BOOL             coopMode;

- (id)initWithImageKey:(NSString *)imgKey
     builtInAlbumIndex:(NSUInteger)idx
          sideElements:(NSUInteger)sideElems
              coopMode:(BOOL)coop
      andSecondsInGame:(NSUInteger)secs;

- (NSInteger)tileLocationAtIndex:(NSInteger)idx;

- (BOOL)saveToPath:(NSString *)basePath fileName:(NSString *)aName;
+ (GameState *)loadFromPath:(NSString *)basePath andFileName:(NSString *)aName;
+ (void)deleteFileName:(NSString *)aName atPath:(NSString *)basePath;

@end
