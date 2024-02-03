//
//  GradView.m
//  Gradient
//
//  Created by Richard Wentk on 21/10/2009.
//  Copyright 2009 Skydancer Media. All rights reserved.
//

#import "GradView.h"

#import "GradientButton.h"


@implementation GradView


- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame])  {
   }
   
   return (self);
}

// Blueprint 212

- (void)drawRect:(CGRect)rect
{
	CGPoint       startFill, endFill;
	CGContextRef  aContext = UIGraphicsGetCurrentContext ();
   
	CGContextSetShouldAntialias (aContext, YES);
	CGContextClearRect (aContext, rect);

   if (!myRGB)
      myRGB = CGColorSpaceCreateDeviceRGB ();
	size_t          num_locations = 3;
	CGFloat         locations [3] = { 0.1, 0.75, 1. };
	CGFloat         components [12] = {
      0.69, 0.56, 0.62, 1.0,
		0.85, 0.7, 0.80, 1.0,
		0.75, 0.6, 0.99, 1.0

      // 0.5, 0.7, 0.85, 1.0,
		// 0.65, 0.4, 0.9, 1.0,
		// 0.75, 0.3, 0.95, 1.0
   };
   
   if (!usedGradient)
	   usedGradient = CGGradientCreateWithColorComponents (myRGB, 
                                                          components, 
                                                          locations, 
                                                          num_locations);
	
	CGContextSaveGState (aContext);
	// CGContextAddRect(aContext, CGRectMake (50, 50, 100, 100));
	// CGContextClip (aContext);
	startFill = CGPointMake (0, 50);
	endFill = CGPointMake (0, 380);    // was 150, 150
   
	CGContextDrawLinearGradient (aContext, 
                                usedGradient, 
                                startFill, 
                                endFill, 
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState (aContext); 
   
	CGContextDrawRadialGradient (aContext, usedGradient, CGPointMake(180,250), 10, CGPointMake(180,300), 50, 0);
   
	// CGGradientRelease (usedGradient);
	// CGColorSpaceRelease (myRGB);
}


- (void)dealloc
{
	CGGradientRelease (usedGradient);
   CGColorSpaceRelease (myRGB);
   
   [super dealloc];
}


@end

#pragma mark UACellBackgroundView

static void addRoundedRectToPath (CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight);

@implementation UACellBackgroundView

@synthesize position;

- (BOOL)isOpaque
{
   return (NO);
}

-(void)drawRect:(CGRect)aRect
{
   // Drawing code
   
   CGContextRef c = UIGraphicsGetCurrentContext ();	
   
   int      lineWidth = 1;
	
   CGRect   rect = [self bounds];
	
   CGFloat  minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
   CGFloat  miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);

   miny -= 1;
	
   CGColorSpaceRef   myColorspace = CGColorSpaceCreateDeviceRGB ();
   CGMutablePathRef  path = CGPathCreateMutable ();
   CGGradientRef     myGradient = nil;

   CGFloat  components[8] = kTABLE_CELL_BACKGROUND;
   CGFloat  locations[2] = { 0.0, 1.0 };
   
   CGContextSetStrokeColorWithColor (c, [[UIColor grayColor] CGColor]);
   CGContextSetLineWidth (c, lineWidth);
   CGContextSetAllowsAntialiasing (c, YES);
   CGContextSetShouldAntialias (c, YES);
   
   if (position == UACellBackgroundViewPositionTop)  {
		
      miny += 1;
		
      CGPathMoveToPoint (path, NULL, minx, maxy);
      CGPathAddArcToPoint (path, NULL, minx, miny, midx, miny, kDefaultCellMargin);
      CGPathAddArcToPoint (path, NULL, maxx, miny, maxx, maxy, kDefaultCellMargin);
      CGPathAddLineToPoint (path, NULL, maxx, maxy);
      CGPathAddLineToPoint (path, NULL, minx, maxy);
      CGPathCloseSubpath (path);
   }
   else if (position == UACellBackgroundViewPositionBottom)  {
      
      CGPathMoveToPoint (path, NULL, minx, miny);
      CGPathAddArcToPoint (path, NULL, minx, maxy, midx, maxy, kDefaultCellMargin);
      CGPathAddArcToPoint (path, NULL, maxx, maxy, maxx, miny, kDefaultCellMargin);
      CGPathAddLineToPoint (path, NULL, maxx, miny);
      CGPathAddLineToPoint (path, NULL, minx, miny);
      CGPathCloseSubpath (path);
   }
   else if (position == UACellBackgroundViewPositionMiddle)  {
		
      CGPathMoveToPoint (path, NULL, minx, miny);
      CGPathAddLineToPoint (path, NULL, maxx, miny);
      CGPathAddLineToPoint (path, NULL, maxx, maxy);
      CGPathAddLineToPoint (path, NULL, minx, maxy);
      CGPathAddLineToPoint (path, NULL, minx, miny);
      CGPathCloseSubpath (path);
   }
   else if (position == UACellBackgroundViewPositionSingle)  {
      miny += 1;
		
      CGPathMoveToPoint (path, NULL, minx, midy);
      CGPathAddArcToPoint (path, NULL, minx, miny, midx, miny, kDefaultCellMargin);
      CGPathAddArcToPoint (path, NULL, maxx, miny, maxx, midy, kDefaultCellMargin);
      CGPathAddArcToPoint (path, NULL, maxx, maxy, midx, maxy, kDefaultCellMargin);
      CGPathAddArcToPoint (path, NULL, minx, maxy, minx, midy, kDefaultCellMargin);
      CGPathCloseSubpath (path);
   }
	
   // Fill and stroke the path
   CGContextSaveGState (c);
   CGContextAddPath (c, path);
   CGContextClip (c);
   
   myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, 2);
   CGContextDrawLinearGradient (c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
   
   CGContextAddPath (c, path);
   CGPathRelease (path);
   CGContextStrokePath (c);
   CGContextRestoreGState (c);
   
   CGColorSpaceRelease(myColorspace);
   CGGradientRelease(myGradient);
}

- (void)dealloc
{
   [super dealloc];
}

- (void)setPosition:(UACellBackgroundViewPosition)newPosition
{
   if (position != newPosition)  {
      position = newPosition;
      [self setNeedsDisplay];
   }
}

@end

// see id_addRoundedRectToPath() in ImageAlbum.m

#ifdef _NOT_NEEDED_
static void addRoundedRectToPath (CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
   float fw, fh;
	
   if (!ovalWidth || !ovalHeight)  {   // 1
      CGContextAddRect (context, rect);
      return;
   }
	
   CGContextSaveGState (context);      // 2
	
   CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));   // 3
   CGContextScaleCTM (context, ovalWidth, ovalHeight);  // 4
   
   fw = CGRectGetWidth (rect) / ovalWidth;// 5
   fh = CGRectGetHeight (rect) / ovalHeight;// 6
	
   CGContextMoveToPoint (context, fw, fh/2); // 7
   CGContextAddArcToPoint (context, fw, fh, fw/2, fh, 1);// 8
   CGContextAddArcToPoint (context, 0, fh, 0, fh/2, 1);// 9
   CGContextAddArcToPoint (context, 0, 0, fw/2, 0, 1);// 10
   CGContextAddArcToPoint (context, fw, 0, fw, fh/2, 1); // 11
   CGContextClosePath (context);   // 12
	
   CGContextRestoreGState (context);   // 13
}
#endif

#pragma mark -

@implementation OvalBadgeView

- (id)initWithFrame:(CGRect)frame cornerRadius:(CGFloat)radius andColor:(UIColor *)color
{
   if (self = [super initWithFrame:frame])  {
      cornerRadius = radius;
      badgeColor = [color retain];
      self.backgroundColor = [UIColor clearColor];
   }
   
   return (self);
}

- (void)drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext ();
	
   CGRect  theRect = CGRectInset (self.bounds, 2.f, 2.f);

   [badgeColor set];

   CGPathRef  path = [GradientButton createRoundRectPathInRect:theRect withCornerRadius:cornerRadius];
   
   CGContextSaveGState (context);   // only for the fill gradient, almost transparent
   CGContextSetAlpha (context, 0.1f);
   CGContextAddPath (context, path);
   CGContextFillPath (context);

   CGContextSetAlpha (context, 1.f);
   CGContextAddPath(context, path);
   CGContextSetLineWidth (context, 2.f);
   CGContextStrokePath (context);

   CGPathRelease (path);
   CGContextRestoreGState (context);
}


- (void)dealloc
{
	[badgeColor release];
   
   [super dealloc];
}


@end

#pragma mark -

@implementation OvalLabelView

- (id)initWithFrame:(CGRect)lFrame
          labelText:(NSString *)lText
       cornerRadius:(CGFloat)cRadius
          textColor:(UIColor *)txColor
       andBackColor:(UIColor *)bkColor;
{
   if (self = [super initWithFrame:lFrame])  {
      initialFrame = lFrame;
      cornerRadius = cRadius;
      textColor = [txColor retain];
      badgeColor = [bkColor retain];
      
      UILabel  *aLabel = [[UILabel alloc] initWithFrame:CGRectInset (self.bounds, 1, 1)];
      
      aLabel.text = lText;
      aLabel.font = [UIFont systemFontOfSize:16];
      aLabel.textAlignment = NSTextAlignmentCenter;
      aLabel.textColor = textColor;
      aLabel.shadowColor = [UIColor darkGrayColor];
      aLabel.shadowOffset = CGSizeMake (1, 1);
      aLabel.backgroundColor = [UIColor clearColor];

      aLabel.adjustsFontSizeToFitWidth = YES;
      aLabel.minimumFontSize = 13.f;

      if (!lText || ![lText length])
         aLabel.hidden = YES;
      [self addSubview:aLabel];
      
      contentLabel = aLabel;
      
      self.backgroundColor = [UIColor clearColor];
   }
   
   return (self);
}

- (void)setText:(NSString *)lText
{
   contentLabel.text = lText;
}

- (NSString *)text
{
   return (contentLabel.text);
}

- (void)drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext ();
	
   CGRect  theRect = CGRectInset (self.bounds, 2.f, 2.f);
      
   CGPathRef  path = [GradientButton createRoundRectPathInRect:theRect withCornerRadius:cornerRadius];
   
   CGContextSaveGState (context);   // only for the fill gradient, almost transparent

   [badgeColor set];

   CGContextSetAlpha (context, 0.9f);
   CGContextAddPath (context, path);
   CGContextFillPath (context);
   
   [textColor set];

   CGContextSetAlpha (context, 1.f);
   CGContextAddPath(context, path);
   CGContextSetLineWidth (context, 2.f);
   CGContextStrokePath (context);
   
   CGPathRelease (path);
   CGContextRestoreGState (context);
}


- (void)dealloc
{
	[textColor release];
	[badgeColor release];
	[contentLabel release];
   
   [super dealloc];
}


@end
