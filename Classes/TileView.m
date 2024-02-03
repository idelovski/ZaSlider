//
//  TileView.m
//  ZaSlider
//
//  Created by Igor Delovski on 16.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "TileView.h"
#import "GenericCanvasView.h"
#import "GradientButton.h"

@interface TileView ()
- (float)getArrowDirectionToIndex:(int)toIndex fromIndex:(int)fromIndex;
- (void)updateArrowLabel;
@end

#pragma mark -


@implementation TileView


@synthesize  sizeInPixels, locIndex, curLocIndex, prevLocIndex, sideElements, tileType;
@synthesize  fingerView, arrowView, highliteView, picView, indexLabel;


// ------------------------------

- (id)initWithDestinationIndex:(int)aIndex
                 nowAtLocation:(int)aLocation
                  sideElements:(int)sideElems  // or dimension
                      withType:(TileType)aTileType
                gameController:(GameController *)aGameController
                      andImage:(UIImage *)completeImage
{
   CGSize  pixSize = [aGameController pixelSizeForTileWithSideElements:sideElems];
   CGRect  tmpRect = [GameController rectForLocationIndex:aLocation withSideElements:sideElems withTileSize:pixSize];
   
   pixSize.height = round (pixSize.height);
   pixSize.width = round (pixSize.width);
   
   NSLog (@"TV initWithDestinationIndex - size: %@", NSStringFromCGSize(pixSize));
   
   UIImageView  *imageView = nil;

   if (self = [super initWithFrame:tmpRect])  {
      
      finishedInit = NO;
      
      self.locIndex = aIndex;
      self.curLocIndex = aLocation;  // argh! must be this way!
      self.prevLocIndex = -1;
      self.sizeInPixels = pixSize;
      self.sideElements = sideElems;
      self.tileType = aTileType;
      
      self.backgroundColor = [UIColor clearColor];
      
      // create the picView
      CGRect    partRect = self.bounds;
      // need rect again, now for original place in the image
      tmpRect = [GameController rectForLocationIndex:aIndex withSideElements:sideElems withTileSize:pixSize];
      NSLog (@"TV initWithDestinationIndex - tmpRect: %@", NSStringFromCGRect(tmpRect));
      CGRect    frameRect = CGRectMake(tmpRect.origin.x, tmpRect.origin.y, partRect.size.width, partRect.size.height);
      NSLog (@"TV initWithDestinationIndex - frameRect: %@", NSStringFromCGRect(frameRect));
      // partRect = CGRectInset (partRect, 1., 1.);  // No need
      
      if (completeImage)  {
         NSLog (@"Why do I have the image here?");
         UIImage  *partImage = [ImageAlbum image:completeImage
                                     partialRect:frameRect
                                        resizeTo:partRect.size
                                          rotate:YES];
         imageView = [[UIImageView alloc] initWithImage:partImage];
      }
      else
         imageView = [[UIImageView alloc] init];
      imageView.frame = partRect;
      self.picView = imageView;
      [imageView release];      
      [self addSubview:self.picView];
      if (self.tileType == kEmptyTile)  {  // if you give up on this watch -allTilesHaveImages
         // self.picView.hidden = YES;
         self.picView.alpha = .05f;
      }
      
      if (self.tileType != kEmptyTile)  {
         
         partRect = self.bounds;
         
         // load the glass image
         UIImage  *glassImage = [UIImage imageNamed:@"Wi_circle.png"];  // was  Glass.png
         
         imageView = [[UIImageView alloc] initWithImage:glassImage]; 
         imageView.center = CGPointMake (partRect.size.width/2, partRect.size.height/2);
         imageView.alpha = .5;  // was .7
         [self addSubview:imageView];
         self.highliteView = imageView;
         [imageView release];
      
         // create the arrow view, make it hidden
         UIImage  *arrowImage = [UIImage imageNamed:@"Wi_arrow3F_60x60.png"];
         
         imageView = [[UIImageView alloc] initWithImage:arrowImage]; 
         imageView.center = CGPointMake (partRect.size.width/2, partRect.size.height/2);
         self.arrowView = imageView;
         [imageView release];      
         [self addSubview:self.arrowView];
         [self.arrowView setHidden:YES];
         
         // Label
         UILabel  *label = [[UILabel alloc] initWithFrame:CGRectInset (self.bounds, 12, 12)];

         label.text = [NSString stringWithFormat:@"%d ", aIndex+1];
         label.numberOfLines = sideElems > 4 ? 4 : 5;
         label.font = [UIFont systemFontOfSize:12];
         label.textAlignment = NSTextAlignmentCenter;
         label.backgroundColor = [UIColor clearColor];
         label.shadowColor = [UIColor lightGrayColor];
         self.indexLabel = label;
         [label release];
         
         [self addSubview:indexLabel];
         
         // finger circle
         FingerSphereView  *tmpFingerView = [[FingerSphereView alloc] initWithFrame:self.bounds];
         
         [self addSubview:tmpFingerView];
         tmpFingerView.hidden = YES;
         // imageView.alpha = .5;
         self.fingerView = tmpFingerView;
         [tmpFingerView release];
      }

      finishedInit = YES;
}
   
   return (self);
}

#pragma mark -

// manual curLocIndex setter

- (void)setCurLocIndex:(int)newLocIndex
{
   prevLocIndex = curLocIndex;
   
   curLocIndex = newLocIndex;
   
   if (finishedInit)
      self.frame = [GameController rectForLocationIndex:newLocIndex withSideElements:sideElements withTileSize:sizeInPixels];
}

#pragma mark -

// --------------------------

- (void)drawRect:(CGRect)rect
{
   // Drawing code
}

// ------------

- (void)dealloc
{
   [indexLabel release];
   [arrowView release];
   [highliteView release];
   [picView release];
   [fingerView release];
   
   [super dealloc];
}

#pragma mark -

- (void)showArrow
{
   [self updateArrowLabel];
}

- (void)hideArrow
{
   if (!self.arrowView.hidden)  {
      self.arrowView.hidden = YES;
      if (self.highliteView.hidden)     // Show hilight
         self.highliteView.hidden = NO;
   }
}

#pragma mark -

// private methods

- (float)getArrowDirectionToIndex:(int)toIndex fromIndex:(int)fromIndex
{
   // NSLog ([NSString stringWithFormat:@"toIndex:%d fromIndex:%d", toIndex, fromIndex]);

   CGRect  toRect   = [GameController rectForLocationIndex:toIndex withSideElements:self.sideElements withTileSize:self.sizeInPixels];
   CGRect  fromRect = [GameController rectForLocationIndex:fromIndex withSideElements:self.sideElements withTileSize:self.sizeInPixels];
   /*
   CGFloat  toX = toIndex % sideElements;
   CGFloat  toY = toIndex / sideElements;
   CGFloat  fromX = fromIndex % sideElements;
   CGFloat  fromY = fromIndex / sideElements;
   */
   CGFloat  rise = toRect.origin.y - fromRect.origin.y;  // toY - fromY;
   CGFloat  run  = toRect.origin.x - fromRect.origin.x;  // toX - fromX;
   
   CGFloat  angle = atan2f (rise, run);
   
   return (angle);
}

- (void)updateArrowLabel
{
   NSUInteger  toIndex   = self.locIndex;
   NSUInteger  fromIndex = self.curLocIndex;
   
   if (toIndex == fromIndex)  {
      self.arrowView.hidden = YES;
      if (self.highliteView.hidden)     // Show hilight
         self.highliteView.hidden = NO;

      return;
   }
   
   self.arrowView.hidden = NO;
   self.highliteView.hidden = YES;
   
   // calculate the angle
   
   CGFloat        angle = [self getArrowDirectionToIndex:toIndex fromIndex:fromIndex] + M_PI;
   CATransform3D  rotationTransform = CATransform3DIdentity;
   
   rotationTransform = CATransform3DRotate (rotationTransform, angle, 0.0, 0.0, 1.0);
   
   self.arrowView.layer.transform = rotationTransform;
}

#pragma mark -

- (void)drawShimInRect:(NSValue *)rectAsValue userInfo:(NSValue *)voidPtrAsValue
{
   CGRect    rect = [rectAsValue CGRectValue];
   CGPoint   startFill, endFill;
   
	CGContextRef     cgContext = UIGraphicsGetCurrentContext ();
   CGGradientRef    usedGradient;
   CGColorSpaceRef  rgbSpace;
   
	CGContextSetShouldAntialias (cgContext, YES);
   
   rgbSpace = CGColorSpaceCreateDeviceRGB ();
   
	size_t   numLocations = 2;
	CGFloat  locations [2] = { 0.1, 1. };
	CGFloat  components [8] = {
      1., 1., 1., 0.1,
      1., 1., 1., 0.01,
   };
   
   usedGradient = CGGradientCreateWithColorComponents (rgbSpace, 
                                                       components, 
                                                       locations, 
                                                       numLocations);
	
	CGContextSaveGState (cgContext);

   CGPathRef  path = [GradientButton createRoundRectShimInRect:rect
                                                      ofHeight:20
                                               withCornerRadius:1];
   
   CGContextAddPath (cgContext, path);
   CGContextEOClip (cgContext);

	startFill = CGPointMake (CGRectGetMidX(rect), CGRectGetMinY(rect));
	endFill = CGPointMake (CGRectGetMidX(rect), CGRectGetMaxY(rect));
   
	CGContextDrawLinearGradient (cgContext, 
                                usedGradient, 
                                startFill, 
                                endFill, 
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState (cgContext); 
      
	CGGradientRelease (usedGradient);
	CGColorSpaceRelease (rgbSpace);
}

@end
