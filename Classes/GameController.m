//
//  GameController.m
//  ZaSlider
//
//  Created by Igor Delovski on 16.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "GameController.h"

#import "TileView.h"
#import "GameState.h"


@implementation GameController

@synthesize  allTiles, theImage, sideElements, emptyTileLocIndex, parentViewSize, gcGamePhase, secondsInGame;

// --------------------------------------
// *** We have TWO init methods here! ***
// --------------------------------------

// anImage may be nil

- (id)initWithNumberOfSideElements:(NSUInteger)sideElems image:(UIImage *)anImage inView:(UIView *)parentView
{
   NSUInteger  totalElems = sideElems * sideElems;
   
   if (self = [super init])  {
      allTiles = [[NSMutableArray alloc] initWithCapacity:totalElems];
      self.theImage = anImage;
      self.parentViewSize = parentView.frame.size;
      
      sideElements = sideElems;
      emptyTileLocIndex = -1;
      
      gcGamePhase = kGameStarting;
      secondsInGame = 0;
      
      for (int i=0; i<totalElems; i++)  {
         TileView  *tmpTileView = [[TileView alloc] initWithDestinationIndex:i
                                                               nowAtLocation:i
                                                                sideElements:sideElems
                                                                    withType:(i==totalElems-1) ? kEmptyTile : kActiveTile
                                                              gameController:self
                                                                    andImage:self.theImage];
         [allTiles addObject:tmpTileView];
         [tmpTileView release];
      }
      
      for (int i=0; i<totalElems; i++)  {  // update index locations
         TileView  *obj = [allTiles objectAtIndex:i];
         if (obj.tileType == kEmptyTile)  {
            emptyTileLocIndex = i;
#ifdef  _TILE_MOVES_LOG_
            NSLog (@"Empty tile: %d", i);
#endif
         }
         [parentView addSubview:obj];
      }
   }
   
   return (self);
}

- (id)initWithGameState:(GameState *)gState sliderImage:(UIImage *)img inView:(UIView *)parentView
{
   NSUInteger  totalElems = gState.sideElements * gState.sideElements;
   
   if ([gState.tileLocations count] != totalElems)
      return ([self initWithNumberOfSideElements:gState.sideElements image:nil inView:parentView]);
   
   if (self = [super init])  {
      allTiles = [[NSMutableArray alloc] initWithCapacity:totalElems];

      self.theImage = img;
      
      sideElements = gState.sideElements;
      emptyTileLocIndex = gState.emptyTileLocIndex;
      
      gcGamePhase = kGameStarting;
      secondsInGame = gState.secondsInGame;
      
      for (int i=0; i<totalElems; i++)  {
         NSInteger  initialLocation = [gState tileLocationAtIndex:i];
         
         TileView   *tmpTileView = [[TileView alloc] initWithDestinationIndex:initialLocation
                                                                nowAtLocation:i
                                                                 sideElements:gState.sideElements
                                                                     withType:(i==emptyTileLocIndex) ? kEmptyTile : kActiveTile
                                                               gameController:self
                                                                     andImage:self.theImage];
         [allTiles addObject:tmpTileView];
         [tmpTileView release];
      }
            
      for (int i=0; i<totalElems; i++)  {  // update index locations
         TileView  *obj = [allTiles objectAtIndex:i];
         if (obj.tileType == kEmptyTile)  {
            emptyTileLocIndex = i;
#ifdef  _TILE_MOVES_LOG_
            NSLog (@"Empty tile: %d", i);
#endif
         }
         [parentView addSubview:obj];
      }
      
      self.gcGamePhase = kGameInProgress;   // We're ready to go!
   }
   
   return (self);
}

- (void)dealloc
{
   [allTiles release];
   [theImage release];
   
   [super dealloc];
}

#pragma mark -

- (GameState *)currentGameStateWithImageKey:(NSString *)imgKey orBuiltInAlbumIndex:(NSInteger)idx
{
   // Cooperation mode is by default NO
   // If it is actually a networked game, view controller should know about it and set it on its own!
   
   GameState  *newGState = [[GameState alloc] initWithImageKey:imgKey
                                             builtInAlbumIndex:idx
                                                  sideElements:self.sideElements
                                                      coopMode:NO
                                              andSecondsInGame:self.secondsInGame];
   
   newGState.emptyTileLocIndex = self.emptyTileLocIndex;
   
#ifdef  _TILE_MOVES_LOG_
   NSLog (@"GameState - Empty:%d, Tiles: %d", self.emptyTileLocIndex, [self.allTiles count]);
#endif
   
   for (int i=0; i<[self.allTiles count]; i++)  {
      TileView  *tv = [self.allTiles objectAtIndex:i];
      [newGState.tileLocations addObject:[NSNumber numberWithInt:tv.locIndex]];
      
   }
   
   return ([newGState autorelease]);
}

#pragma mark -

- (BOOL)tileCanMoveToEmptyTileFromIndex:(int)index
{
   return ([GameController tileCanMoveToEmptyLocIndex:emptyTileLocIndex fromIndex:index withSideElements:sideElements]);
}

- (BOOL)tileCanMoveByXToEmptyTileFromIndex:(int)index inDirection:(int)positiveDirection
{
   int  tx = [GameController getXForLocIndex:index withSideElements:sideElements];
   int  ex = [GameController getXForLocIndex:emptyTileLocIndex withSideElements:sideElements];
   
   int  ty = [GameController getYForLocIndex:index withSideElements:sideElements];
   int  ey = [GameController getYForLocIndex:emptyTileLocIndex withSideElements:sideElements];
   
   if (ty != ey)
      return (NO);
   if (((positiveDirection > 0) && (ex < tx)) || ((positiveDirection < 0) && (ex > tx)))
      return (NO);
   
   return ([GameController tileCanMoveToEmptyLocIndex:emptyTileLocIndex fromIndex:index withSideElements:sideElements]);
}

- (BOOL)tileCanMoveByYToEmptyTileFromIndex:(int)index inDirection:(int)positiveDirection
{
   int  tx = [GameController getXForLocIndex:index withSideElements:sideElements];
   int  ex = [GameController getXForLocIndex:emptyTileLocIndex withSideElements:sideElements];
   
   int  ty = [GameController getYForLocIndex:index withSideElements:sideElements];
   int  ey = [GameController getYForLocIndex:emptyTileLocIndex withSideElements:sideElements];
   
   if (tx != ex)
      return (NO);
   if (((positiveDirection > 0) && (ey > ty)) || ((positiveDirection < 0) && (ey < ty)))
      return (NO);
   
   return ([GameController tileCanMoveToEmptyLocIndex:emptyTileLocIndex fromIndex:index withSideElements:sideElements]);
}


#pragma mark -
#pragma mark Class methods
#pragma mark -

- (CGSize)pixelSizeForTileWithSideElements:(NSUInteger)aDimension
{
   // CGRect      screenRect   = [[UIScreen mainScreen] applicationFrame];
   // CGRect      statusRect   = [[UIApplication sharedApplication] statusBarFrame];
   CGFloat     screenWidth  = self.parentViewSize.width;  // screenRect.size.width;
   CGFloat     screenHeight = self.parentViewSize.height;  // screenRect.size.height;
   
   // if (![[UIApplication sharedApplication] isStatusBarHidden])
   //    screenHeight -= statusRect.size.height;
   
   CGSize  tileSize = CGSizeMake ((screenWidth - kLeftOffset*2) / aDimension, (screenHeight - kLeftOffset*2 - kBotOffset) / aDimension);
   
   return  (tileSize);
}

// Calculate rect inside view

+ (CGRect)rectForLocationIndex:(int)aLocation withSideElements:(int)aDimension withTileSize:(CGSize)sizeInPixels
{
   int  x = [self getXForLocIndex:aLocation withSideElements:aDimension];
   int  y = [self getYForLocIndex:aLocation withSideElements:aDimension];
   
   return (CGRectMake(x*sizeInPixels.width + x + kLeftOffset, y * sizeInPixels.height + y + kTopOffset, sizeInPixels.width, sizeInPixels.height));
}

// Calculate rect inside other rect

+ (CGRect)subRectInSize:(CGSize)origSize forLocationIndex:(int)aLocation withSideElements:(int)aDimension
{
   int  x = [self getXForLocIndex:aLocation withSideElements:aDimension];
   int  y = [self getYForLocIndex:aLocation withSideElements:aDimension];
   
   CGSize  subSize = CGSizeMake (origSize.width / aDimension, origSize.height / aDimension);
   
   return (CGRectMake(x * subSize.width, y * subSize.height, subSize.width, subSize.height));
}

+ (int)getXForLocIndex:(int)aLocation withSideElements:(int)aDimension
{
   return (aLocation % aDimension);
}

+ (int)getYForLocIndex:(int)aLocation withSideElements:(int)aDimension
{
   return (aLocation / aDimension);
}

+ (NSInteger)locationIndexForTileView:(TileView *)tv
            rotatedByImageOrientation:(UIImageOrientation)imageOrientation
                     andLandscapeFlag:(BOOL)landscapeFlag
{
   NSInteger   locIndex = tv.locIndex;
   NSUInteger  sideElems = tv.sideElements;
   NSUInteger  eMax = sideElems - 1;
   NSInteger   ox, oy, rx, ry;
   NSInteger   result;
   
   ox = [self getXForLocIndex:locIndex withSideElements:sideElems];
   oy = [self getYForLocIndex:locIndex withSideElements:sideElems];

   if ((imageOrientation == UIImageOrientationRight) ||
      (imageOrientation == UIImageOrientationUp && landscapeFlag))  {
      rx = oy;
      ry = eMax - ox;
      result = rx + ry * sideElems;
      
#ifdef  _TILE_MOVES_LOG_
      NSLog (@"In: %d[%d,%d]  Out: %d[%d,%d]", locIndex, ox, oy, result, rx, ry);
#endif      
      return (result);
   }
   else if ((imageOrientation == UIImageOrientationLeft) ||
            (imageOrientation == UIImageOrientationDown && landscapeFlag))  {
      rx = eMax - oy;
      ry = ox;
      result = rx + ry * sideElems;
      
#ifdef  _TILE_MOVES_LOG_
      NSLog (@"In: %d[%d,%d]  Out: %d[%d,%d]", locIndex, ox, oy, result, rx, ry);
#endif
      
      return (result);
   }
   else  if (imageOrientation == UIImageOrientationDown)  {
      rx = eMax - ox;
      ry = eMax - oy;
      result = rx + ry * sideElems;

#ifdef  _TILE_MOVES_LOG_
      NSLog (@"In: %d[%d,%d]  Out: %d[%d,%d]", locIndex, ox, oy, result, rx, ry);
#endif
      
      return (result);
   }
   else if (imageOrientation == UIImageOrientationUp)  {
      return (locIndex);
   }

   return (locIndex);
}

// returns true this tile can move to the enpty location

+ (bool)tileCanMoveToEmptyLocIndex:(int)emptyTileIndex fromIndex:(int)index withSideElements:(int)aDimension
{
   int fromX = [self getXForLocIndex:index withSideElements:aDimension];
   int fromY = [self getYForLocIndex:index withSideElements:aDimension];
   int toX   = [self getXForLocIndex:emptyTileIndex withSideElements:aDimension];
   int toY   = [self getYForLocIndex:emptyTileIndex withSideElements:aDimension];
   
   if (fromX == toX && (fromY+1 == toY || fromY-1 == toY))
      return (YES);
   if (fromY == toY && (fromX+1 == toX || fromX-1 == toX))
      return (YES);
   
   return (NO);
}

#pragma mark -

- (NSOperation *)prepareTileImagesWithImage:(UIImage *)bigImage
                                  mediaItem:(MediaItem *)theMediaItem
                                   delegate:(id<NSObject, TileImageCreationDelegate>)tiDelegate
{
   NSUInteger         totalElems = self.sideElements * self.sideElements;
   BOOL               landscapeFlag = NO;
   TileView          *tmpTileView = nil;
   NSOperation       *depOperation = nil;
   CGSize             imgSize = bigImage.size;
   UIImageOrientation imgOrientation = bigImage.imageOrientation;
   //-CGFloat       shorterImgLength = imgSize.width < imgSize.height ? imgSize.width : imgSize.height;
   
   if (imgOrientation == UIImageOrientationRight || imgOrientation == UIImageOrientationLeft)
      imgSize = CGSizeMake (imgSize.height, imgSize.width);
   else  if (imgOrientation == UIImageOrientationDown || imgOrientation == UIImageOrientationUp)  {
      if (imgSize.width > imgSize.height)  {
         // imgSize = CGSizeMake (imgSize.height, imgSize.width);
         landscapeFlag = YES;
      }
   }

   for (int i=0; i<totalElems; i++)  {
      tmpTileView = [self.allTiles objectAtIndex:i];
      
      // if (tmpTileView.tileType != kEmptyTile)  {
         
         /*
         CATransform3D  rotationTransform = CATransform3DIdentity;

         if (landscapeFlag)
            rotationTransform = CATransform3DRotate (rotationTransform, M_PI/2.f, 0.0, 0.0, 1.0);

         tmpTileView.picView.layer.transform = rotationTransform;
         */
         NSInteger  locIndex = [GameController locationIndexForTileView:tmpTileView
                                              rotatedByImageOrientation:imgOrientation
                                                       andLandscapeFlag:landscapeFlag];

         // CGRect  tmpRect = [GameController rectForLocationIndex:locIndex // tmpTileView.locIndex
         //                                       withSideElements:self.sideElements
         //                                           withTileSize:tmpTileView.sizeInPixels];
         
         CGRect  tmpRect = [GameController subRectInSize:imgSize forLocationIndex:locIndex withSideElements:self.sideElements];
                            
         // CGSize  tmpSize = tmpRect.size;
         // sizeRatio = (shorterImgLength / (tmpSize.width < tmpSize.height ? tmpSize.width : tmpSize.height)) * self.sideElements;
#ifdef _NIJE_
         CGFloat            sizeRatio;

         if (tmpTileView.sizeInPixels.height < tmpTileView.sizeInPixels.width)
            sizeRatio = shorterImgLength / (tmpTileView.sizeInPixels.height * self.sideElements);
         else
            sizeRatio = shorterImgLength / (tmpTileView.sizeInPixels.width * self.sideElements);
         
         // CGRect    partRect = self.bounds;
         // CGRect  frameRect = CGRectMake (tmpRect.origin.x, tmpRect.origin.y, partRect.size.width, partRect.size.height);

         tmpRect.origin.x *= sizeRatio;
         tmpRect.origin.y *= sizeRatio;
         
         tmpRect.size.height *= sizeRatio;
         tmpRect.size.width  *= sizeRatio;
#endif
         
#ifdef _IMGSIZE_LOG_
         NSLog (@"ImageSize: [%.0f,%.0f] O: [%d] R: [%.23f]", imgSize.width, imgSize.height, bigImage.imageOrientation, sizeRatio);
         NSLog (@"Part Rect: [%.0f,%.0f][%.0f,%.0f]", tmpRect.origin.x, tmpRect.origin.y, tmpRect.size.width, tmpRect.size.height);
#endif
         depOperation = [[ImageCache sharedImageCache] makeTileImageForKey:theMediaItem.imgKey
                                                                     image:bigImage
                                                                  partRect:tmpRect
                                                                  locIndex:tmpTileView.locIndex
                                                            withDependancy:depOperation
                                                         tileImageDelegate:tiDelegate];
      // }
   }
   
   return (depOperation);
}

@end
