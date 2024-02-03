//
//  GameController.h
//  ZaSlider
//
//  Created by Igor Delovski on 16.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "ImageCache.h"
#import "MediaItem.h"


#pragma mark -

@class  GameState;

@interface GameController : NSObject  {
   NSMutableArray  *allTiles;               // of type TileView;
   
   UIImage         *theImage;
   
   NSUInteger       sideElements;
   NSInteger        emptyTileLocIndex;
   CGSize           parentViewSize;
   
   GamePhase        gcGamePhase;            // enum - start, shuffle, inProgress, over
   NSUInteger       secondsInGame;
}

@property (nonatomic, retain)  NSMutableArray  *allTiles;
@property (nonatomic, retain)  UIImage         *theImage;

@property (nonatomic)          NSUInteger       sideElements;
@property (nonatomic)          NSInteger        emptyTileLocIndex;
@property (nonatomic)          CGSize           parentViewSize;
@property (nonatomic)          GamePhase        gcGamePhase;
@property (nonatomic)          NSUInteger       secondsInGame;


// *** We have TWO init methods here! ***

- (id)initWithNumberOfSideElements:(NSUInteger)sideElems image:(UIImage *)anImage inView:(UIView *)parentView;
- (id)initWithGameState:(GameState *)gState sliderImage:(UIImage *)img inView:(UIView *)parentView;

- (CGSize)pixelSizeForTileWithSideElements:(NSUInteger)aDimension;
+ (CGRect)rectForLocationIndex:(int)aLocation withSideElements:(int)aDimension withTileSize:(CGSize)sizeInPixels;
+ (CGRect)subRectInSize:(CGSize)origSize forLocationIndex:(int)aLocation withSideElements:(int)aDimension;
+ (int)getXForLocIndex:(int)aLocation withSideElements:(int)aDimension;
+ (int)getYForLocIndex:(int)aLocation withSideElements:(int)aDimension;

// Used in same class, uncomment if needed outside...
// + (NSUInteger)locationIndexForTileView:(TileView *)tv
//              rotatedByImageOrientation:(UIImageOrientation)imageOrientation
//                     andLandscapeFlag:(BOOL)landscapeFlag;

+ (bool)tileCanMoveToEmptyLocIndex:(int)emptyTileIndex fromIndex:(int)index withSideElements:(int)aDimension;





- (GameState *)currentGameStateWithImageKey:(NSString *)imgKey  // Cooperation mode is by default NO
                        orBuiltInAlbumIndex:(NSInteger)idx;     // If it is actually a networked game, view controller
                                                                // should know about it and set it on its own!

- (BOOL)tileCanMoveToEmptyTileFromIndex:(int)index;
- (BOOL)tileCanMoveByXToEmptyTileFromIndex:(int)index inDirection:(int)positiveDirection;
- (BOOL)tileCanMoveByYToEmptyTileFromIndex:(int)index inDirection:(int)positiveDirection;

- (NSOperation *)prepareTileImagesWithImage:(UIImage *)bigImage
                                  mediaItem:(MediaItem *)theMediaItem
                                   delegate:(id<NSObject, TileImageCreationDelegate>)tiDelegate;
@end
