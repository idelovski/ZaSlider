//
//  ButtonGradientView.m
//  Custom Alert View
//
//  Created by jeff on 5/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GradientButton.h"

// Category / Private Methods

@interface GradientButton()

@property (nonatomic, readonly)  CGGradientRef  normalGradient;
@property (nonatomic, readonly)  CGGradientRef  highlightGradient;

- (void)useNewStyleWithNormalQuads:(RGBLocQuad *)normalQuads
                      andHighQuads:(RGBLocQuad *)highQuads
                         blackText:(BOOL)blackTextFlag
            whiteTextIfHighlighted:(BOOL)whiteHiTextFlag;
- (CGPathRef)createRoundRectPathInRect:(CGRect)buttonRect withStroke:(CGFloat)stroke andResolution:(CGFloat)resolution;
- (void)hesitateUpdate; // Used to catch and fix problem where quick taps don't get updated back to normal state

@end

#pragma mark -

@implementation  GradientButton

@synthesize  normalGradientColors;
@synthesize  normalGradientLocations;
@synthesize  highlightGradientColors;
@synthesize  highlightGradientLocations;
@synthesize  cornerRadius;
@synthesize  strokeWeight, strokeColor;
@synthesize  normalGradient, highlightGradient;

#pragma mark -

+ (CGGradientRef)createGradientWithColors:(NSArray *)gradientColors andLocations:(NSArray *)gradientLocations
{
   int      locCount = [gradientLocations count];
   CGFloat  locations[locCount];
      
   for (int i = 0; i < locCount; i++)  {
      NSNumber  *location = [gradientLocations objectAtIndex:i];
      locations[i] = [location floatValue];
   }
      
   CGColorSpaceRef  space = CGColorSpaceCreateDeviceRGB ();
   CGGradientRef    retGradientRef = CGGradientCreateWithColors (space, (CFArrayRef)gradientColors, locations);
   
   CGColorSpaceRelease (space);
   
   return (retGradientRef);
}

- (CGGradientRef)normalGradient
{
   if (!normalGradient)  {
      normalGradient = [GradientButton createGradientWithColors:normalGradientColors
                                                   andLocations:normalGradientLocations];
   }
   
   return (normalGradient);
}

- (CGGradientRef)highlightGradient
{
   
   if (!highlightGradient)  {
      highlightGradient = [GradientButton createGradientWithColors:highlightGradientColors
                                                      andLocations:highlightGradientLocations];
   }

   return (highlightGradient);
}

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])  {
		[self setOpaque:NO];
      self.backgroundColor = [UIColor clearColor];
	}
   
	return (self);
}

- (void)useNewStyleWithNormalQuads:(RGBLocQuad *)normalQuads
                      andHighQuads:(RGBLocQuad *)highQuads
                         blackText:(BOOL)blackTextFlag
            whiteTextIfHighlighted:(BOOL)whiteHiTextFlag
{
   NSMutableArray  *normColors = [NSMutableArray array];
   NSMutableArray  *highColors = [NSMutableArray array];
   UIColor         *color;
   
   for (int i = 0; normalQuads[i].r >= 0.; i++)  {
      color = [UIColor colorWithRed:normalQuads[i].r
                              green:normalQuads[i].g
                               blue:normalQuads[i].b
                              alpha:1.0];
      [normColors addObject:(id)[color CGColor]];
   }
   
   for (int i = 0; highQuads[i].r >= 0.; i++)  {
      color = [UIColor colorWithRed:highQuads[i].r
                              green:highQuads[i].g
                               blue:highQuads[i].b
                              alpha:1.0];
      [highColors addObject:(id)[color CGColor]];
   }
   
   self.normalGradientColors = normColors;
   self.highlightGradientColors = highColors;
   
   NSMutableArray  *normLocations = [NSMutableArray array];
   NSMutableArray  *highLocations = [NSMutableArray array];
   
   for (int i = 0; highQuads[i].r >= 0.; i++)
      [normLocations addObject:[NSNumber numberWithFloat:normalQuads[i].loc]];
   for (int i = 0; highQuads[i].r >= 0.; i++)
      [highLocations addObject:[NSNumber numberWithFloat:highQuads[i].loc]];
   
   
   self.normalGradientLocations    = normLocations;
   self.highlightGradientLocations = highLocations;
   
   self.cornerRadius = 9.f;
   
   if (blackTextFlag)
      [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   else
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   if (whiteHiTextFlag)
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

#pragma mark -
#pragma mark Appearances

static  RGBLocQuad  normAlertRGBLocQuads[] = {
{ 0.28, 0.32, 0.41, 0.00 },
{ 0.82, 0.83, 0.87, 1.00 },
{ 0.17, 0.22, 0.33, 0.48 },
{ -1. },
};

static  RGBLocQuad  highAlertRGBLocQuads[] = {
{ 0.00, 0.00, 0.00, 0.00 },
{ 0.65, 0.68, 0.71, 1.00 },
{ 0.14, 0.16, 0.21, 0.51 },
{ 0.24, 0.26, 0.31, 0.65 },
{ -1. },
};

- (void)useNewAlertStyle
{
   [self useNewStyleWithNormalQuads:&normAlertRGBLocQuads[0]
                       andHighQuads:&highAlertRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:YES];
}

static  RGBLocQuad  normRedDeleteRGBLocQuads[] = {
{ 0.67, 0.15, 0.15, 0.00 },
{ 0.84, 0.57, 0.57, 1.00 },
{ 0.75, 0.34, 0.35, 0.58 },
{ 0.59,  0.00, 0.0,  0.42 },
{ 0.59,  0.00, 0.0,  0.35 },
{ -1. },
};

static  RGBLocQuad  highRedDeleteRGBLocQuads[] = {
{ 0.47, 0.01, 0.01, 0.00 },
{ 0.75, 0.56, 0.56, 1.00 },
{ 0.54, 0.21, 0.21, 0.72 },
{ 0.50, 0.15, 0.15, 0.51 },
{ 0.39, 0.01, 0.00, 0.45 },
{ -1. },
};

- (void)useNewRedDeleteStyle
{
   [self useNewStyleWithNormalQuads:&normRedDeleteRGBLocQuads[0]
                       andHighQuads:&highRedDeleteRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

static  RGBLocQuad  normWhiteRGBLocQuads[] = {
{ 0.86, 0.86, 0.86, 0.00 },
{ 0.99, 0.99, 0.99, 1.00 },
{ 0.96, 0.96, 0.96, 0.60 },
{ -1. },
};

static  RGBLocQuad  highWhiteRGBLocQuads[] = {
{ 0.69, 0.69, 0.69, 0.00 },
{ 0.99, 0.99, 0.99, 1.00 },
{ 0.83, 0.83, 0.83, 0.60 },
{ -1. },
};

- (void)useNewWhiteStyle
{
   [self useNewStyleWithNormalQuads:&normWhiteRGBLocQuads[0]
                       andHighQuads:&highWhiteRGBLocQuads[0]
                          blackText:YES
             whiteTextIfHighlighted:NO];  // needs [UIColor darkGrayColor] for hi color, but can't see any difference
}

static  RGBLocQuad  normBlackRGBLocQuads[] = {
{ 0.15, 0.15, 0.15, 0.00 },
{ 0.31, 0.31, 0.31, 1.00 },
{ 0.17, 0.17, 0.17, 0.55 },
{ 0.12, 0.12, 0.12, 0.46 },
{ -1. },
};

static  RGBLocQuad  highBlackRGBLocQuads[] = {
{ 0.20, 0.20, 0.20, 0.20 },
{ 0.04, 0.04, 0.04, 1.00 },
{ 0.08, 0.08, 0.08, 0.08 },
{ 0.12, 0.12, 0.12, 0.46 },
{ -1. },
};

- (void)useNewBlackStyle
{
   [self useNewStyleWithNormalQuads:&normBlackRGBLocQuads[0]
                       andHighQuads:&highBlackRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

static  RGBLocQuad  normWhiteActionSheetRGBLocQuads[] = {
{ 0.86, 0.86, 0.86, 0.00 },
{ 0.99, 0.99, 0.99, 1.00 },
{ 0.96, 0.96, 0.96, 0.60 },
{ -1. },
};

static  RGBLocQuad  highWhiteActionSheetRGBLocQuads[] = {
{ 0.03, 0.25, 0.68, 0.00 },
{ 0.66, 0.70, 0.88, 1.00 },
{ 0.22, 0.31, 0.71, 0.96 },
{ 0.15, 0.22, 0.68, 0.57 },
{ 0.00, 0.12, 0.62, 0.54 },
{ 0.01, 0.18, 0.65, 0.19 },
{ 0.31, 0.38, 0.75, 0.81 },
{ -1. },
};

- (void)useNewWhiteActionSheetStyle
{
   [self useNewStyleWithNormalQuads:&normWhiteActionSheetRGBLocQuads[0]
                       andHighQuads:&highWhiteActionSheetRGBLocQuads[0]
                          blackText:YES
             whiteTextIfHighlighted:YES];
}


static  RGBLocQuad  normBlackActionSheetRGBLocQuads[] = {
{ 0.15, 0.15, 0.15, 0.00 },
{ 0.31, 0.31, 0.31, 1.00 },
{ 0.17, 0.17, 0.17, 0.55 },
{ 0.12, 0.12, 0.12, 0.46 },
{ -1. },
};

static  RGBLocQuad  highBlackActionSheetRGBLocQuads[] = {
{ 0.03, 0.25, 0.67, 0.00 },
{ 0.66, 0.70, 0.88, 1.00 },
{ 0.22, 0.31, 0.71, 0.96 },
{ 0.15, 0.23, 0.68, 0.58 },
{ 0.00, 0.12, 0.62, 0.54 },
{ 0.01, 0.18, 0.65, 0.19 },
{ 0.31, 0.38, 0.75, 0.81 },
{ -1. },
};

- (void)useNewBlackActionSheetStyle
{
   [self useNewStyleWithNormalQuads:&normBlackActionSheetRGBLocQuads[0]
                       andHighQuads:&highBlackActionSheetRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:YES];
}


static  RGBLocQuad  normOrangeRGBLocQuads[] = {
{ 0.94, 0.40, 0.02, 0.00 },
{ 0.97, 0.58, 0.00, 1.00 },
{ -1. },
};

static  RGBLocQuad  highOrangeRGBLocQuads[] = {
{ 0.91, 0.31, 0.00, 0.00 },
{ 0.94, 0.40, 0.00, 1.00 },
{ 0.95, 0.44, 0.01, 0.50 },
{ -1. },
};

- (void)useNewOrangeStyle
{
   [self useNewStyleWithNormalQuads:&normOrangeRGBLocQuads[0]
                       andHighQuads:&highOrangeRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

static  RGBLocQuad  normGreenRGBLocQuads[] = {
{ 0.15, 0.67, 0.15, 0.00 },
{ 0.57, 0.84, 0.57, 1.00 },
{ 0.34, 0.75, 0.35, 0.58 },
{ 0.0,  0.59, 0.0,  0.42 },
{ 0.0,  0.59, 0.0,  0.35 },
{ -1. },
};

static  RGBLocQuad  highGreenRGBLocQuads[] = {
{ 0.01, 0.47, 0.01, 0.00 },
{ 0.56, 0.75, 0.56, 1.00 },
{ 0.21, 0.54, 0.21, 0.72 },
{ 0.15, 0.50, 0.15, 0.51 },
{ 0.01, 0.39, 0.00, 0.45 },
{ -1. },
};

- (void)useNewGreenConfirmStyle
{
   [self useNewStyleWithNormalQuads:&normGreenRGBLocQuads[0]
                       andHighQuads:&highGreenRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

#pragma mark -
#pragma mark MyCreations
#pragma mark -

// #define  kLighterX  1.3

static  RGBLocQuad  normRedLightRGBLocQuads[] = {
{ 0.67, 0.25, 0.25, 0.00 },
{ 0.84, 0.67, 0.67, 1.00 },
{ 0.75, 0.54, 0.55, 0.58 },
{ 0.59, 0.21, 0.21, 0.42 },
{ 0.59, 0.15, 0.15, 0.35 },
{ -1. },
};

static  RGBLocQuad  highRedLightRGBLocQuads[] = {
{ 0.47, 0.01, 0.01, 0.00 },
{ 0.75, 0.56, 0.56, 1.00 },
{ 0.54, 0.21, 0.21, 0.72 },
{ 0.50, 0.15, 0.15, 0.51 },
{ 0.39, 0.01, 0.00, 0.45 },
{ -1. },
};

- (void)useNewRedLightStyle
{
   [self useNewStyleWithNormalQuads:&normRedLightRGBLocQuads[0]
                       andHighQuads:&highRedLightRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

// ---------------------------------------------------------------------------------------------------------------

static  RGBLocQuad  normVelvetRGBLocQuads[] = {
{ 0.67, 0.25, 0.67, 0.00 },
{ 0.84, 0.67, 0.84, 1.00 },
{ 0.75, 0.54, 0.75, 0.58 },
{ 0.59, 0.21, 0.59, 0.42 },
{ 0.59, 0.15, 0.59, 0.35 },
{ -1. },
};

static  RGBLocQuad  highVelvetRGBLocQuads[] = {
{ 0.47, 0.01, 0.47, 0.00 },
{ 0.75, 0.56, 0.75, 1.00 },
{ 0.54, 0.21, 0.54, 0.72 },
{ 0.50, 0.15, 0.50, 0.51 },
{ 0.39, 0.01, 0.39, 0.45 },
{ -1. },
};

- (void)useNewVelvetStyle
{
   [self useNewStyleWithNormalQuads:&normVelvetRGBLocQuads[0]
                       andHighQuads:&highVelvetRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

// ---------------------------------------------------------------------------------------------------------------

static  RGBLocQuad  normGoldenRGBLocQuads[] = {
{ 0.89, 0.55, 0.07, 0.00 },
{ 0.99, 0.87, 0.04, 1.00 },
{ 0.85, 0.74, 0.05, 0.58 },
{ 0.78, 0.61, 0.09, 0.42 },
{ 0.76, 0.51, 0.09, 0.35 },
{ -1. },
};

static  RGBLocQuad  highGoldenRGBLocQuads[] = {
{ 0.47, 0.37, 0.07, 0.00 },
{ 0.75, 0.65, 0.05, 1.00 },
{ 0.54, 0.44, 0.04, 0.72 },
{ 0.50, 0.40, 0.01, 0.51 },
{ 0.39, 0.29, 0.02, 0.45 },
{ -1. },
};

- (void)useNewGoldenStyle
{
   [self useNewStyleWithNormalQuads:&normGoldenRGBLocQuads[0]
                       andHighQuads:&highGoldenRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

// ---------------------------------------------------------------------------------------------------------------

static  RGBLocQuad  normBlueLightRGBLocQuads[] = {
{ 0.58, 0.61, 0.88, 0.00 },
{ 0.72, 0.79, 0.99, 1.00 },
{ 0.56, 0.48, 0.88, 0.58 },
{ 0.41, 0.36, 0.63, 0.42 },
{ 0.21, 0.25, 0.49, 0.35 },
{ -1. },
};

static  RGBLocQuad  highBlueLightRGBLocQuads[] = {
{ 0.01, 0.21, 0.47, 0.00 },
{ 0.56, 0.76, 0.75, 1.00 },
{ 0.21, 0.41, 0.54, 0.72 },
{ 0.15, 0.35, 0.50, 0.51 },
{ 0.01, 0.10, 0.39, 0.45 },
{ -1. },
};

- (void)useNewBlueLightStyle
{
   [self useNewStyleWithNormalQuads:&normBlueLightRGBLocQuads[0]
                       andHighQuads:&highBlueLightRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

// ---------------------------------------------------------------------------------------------------------------

static  RGBLocQuad  normBlueAzureRGBLocQuads[] = {
{ 0.28, 0.65, 0.87, 0.00 },
{ 0.52, 0.87, 0.94, 1.00 },
{ 0.46, 0.75, 0.85, 0.58 },
{ 0.25, 0.51, 0.63, 0.42 },
{ 0.10, 0.35, 0.59, 0.35 },
{ -1. },
};

static  RGBLocQuad  highBlueAzureRGBLocQuads[] = {
{ 0.01, 0.21, 0.47, 0.00 },
{ 0.56, 0.76, 0.75, 1.00 },
{ 0.21, 0.41, 0.54, 0.72 },
{ 0.15, 0.35, 0.50, 0.51 },
{ 0.01, 0.10, 0.39, 0.45 },
{ -1. },
};

- (void)useNewBlueAzureStyle
{
   [self useNewStyleWithNormalQuads:&normBlueAzureRGBLocQuads[0]
                       andHighQuads:&highBlueAzureRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

// ---------------------------------------------------------------------------------------------------------------

static  RGBLocQuad  normBlueRGBLocQuads[] = {
{ 0.15, 0.15, 0.67, 0.00 },
{ 0.57, 0.57, 0.84, 1.00 },
{ 0.34, 0.35, 0.75, 0.58 },
{ 0.00, 0.00, 0.59, 0.42 },
{ 0.00, 0.00, 0.59, 0.35 },
{ -1. },
};

static  RGBLocQuad  highBlueRGBLocQuads[] = {
{ 0.01, 0.01, 0.47, 0.00 },
{ 0.56, 0.56, 0.75, 1.00 },
{ 0.21, 0.21, 0.54, 0.72 },
{ 0.15, 0.15, 0.50, 0.51 },
{ 0.01, 0.00, 0.39, 0.45 },
{ -1. },
};

- (void)useNewBlueStyle
{
   [self useNewStyleWithNormalQuads:&normBlueRGBLocQuads[0]
                       andHighQuads:&highBlueRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

// ---------------------------------------------------------------------------------------------------------------

static  RGBLocQuad  normBlueCoolRGBLocQuads[] = {
{ 0.28, 0.35, 0.57, 0.00 },
{ 0.70, 0.78, 0.98, 1.00 },
{ 0.68, 0.68, 0.95, 0.58 },
{ 0.62, 0.62, 0.82, 0.42 },
{ 0.58, 0.58, 0.76, 0.35 },
{ -1. },
};

static  RGBLocQuad  highBlueCoolRGBLocQuads[] = {
{ 0.01, 0.01, 0.47, 0.00 },
{ 0.56, 0.56, 0.75, 1.00 },
{ 0.21, 0.21, 0.54, 0.72 },
{ 0.15, 0.15, 0.50, 0.51 },
{ 0.01, 0.00, 0.39, 0.45 },
{ -1. },
};

- (void)useNewBlueCoolStyle
{
   [self useNewStyleWithNormalQuads:&normBlueCoolRGBLocQuads[0]
                       andHighQuads:&highBlueCoolRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}

// ---------------------------------------------------------------------------------------------------------------

static  RGBLocQuad  normBlueIndigoRGBLocQuads[] = {
{ 0.18, 0.15, 0.57, 0.00 },
{ 0.42, 0.47, 0.64, 1.00 },
{ 0.36, 0.35, 0.55, 0.58 },
{ 0.15, 0.14, 0.39, 0.42 },
{ 0.10, 0.10, 0.39, 0.35 },
{ -1. },
};

static  RGBLocQuad  highBlueIndigoRGBLocQuads[] = {
{ 0.01, 0.01, 0.47, 0.00 },
{ 0.56, 0.56, 0.75, 1.00 },
{ 0.21, 0.21, 0.54, 0.72 },
{ 0.15, 0.15, 0.50, 0.51 },
{ 0.01, 0.00, 0.39, 0.45 },
{ -1. },
};

- (void)useNewBlueIndigoStyle
{
   [self useNewStyleWithNormalQuads:&normBlueIndigoRGBLocQuads[0]
                       andHighQuads:&highBlueIndigoRGBLocQuads[0]
                          blackText:NO
             whiteTextIfHighlighted:NO];
}


static  RGBLocQuad  normPinkishRGBLocQuads[] = {
{ 0.92, 0.62, 0.72, 0.00 },
{ 0.99, 0.78, 0.90, 1.00 },
{ 0.90, 0.76, 0.87, 0.60 },
{ -1. },
};

static  RGBLocQuad  highPinkishRGBLocQuads[] = {
{ 0.69, 0.59, 0.59, 0.00 },
{ 0.89, 0.80, 0.80, 1.00 },
{ 0.73, 0.63, 0.63, 0.60 },
{ -1. },
};

- (void)useNewPinkishStyle
{
   [self useNewStyleWithNormalQuads:&normPinkishRGBLocQuads[0]
                       andHighQuads:&highPinkishRGBLocQuads[0]
                          blackText:YES
             whiteTextIfHighlighted:NO];  // needs [UIColor darkGrayColor] for hi color, but can't see any difference
}

#pragma mark -

+ (CGPathRef)createRoundRectShimInRect:(CGRect)buttonRect ofHeight:(CGFloat)shimHeight withCornerRadius:(CGFloat)radius
{
	radius = MIN (radius, 0.5f * MIN(CGRectGetWidth(buttonRect), CGRectGetHeight(buttonRect)));
   
	CGRect            insetRect = CGRectInset (buttonRect, radius-.5f, radius-.5f);
	CGMutablePathRef  pathRef   = CGPathCreateMutable ();
   
   CGPoint           leftPoint  = CGPointMake (CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect) + shimHeight);
   CGPoint           rightPoint = CGPointMake (CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect) + shimHeight);

   CGPoint           leftCtrlPoint  = CGPointMake (leftPoint.x  + shimHeight/1.5f, leftPoint.y  + shimHeight/2.f+4.f);
   CGPoint           rightCtrlPoint = CGPointMake (rightPoint.x - shimHeight/1.5f, rightPoint.y + shimHeight/2.f+4.f);

	// top-left corner
	CGPathAddArc (pathRef, NULL, CGRectGetMinX(insetRect), CGRectGetMinY(insetRect), radius, DegreesToRadians(180.0), DegreesToRadians(270.0), FALSE);
   
	// top-right corner	
	CGPathAddArc (pathRef, NULL, CGRectGetMaxX(insetRect), CGRectGetMinY(insetRect), radius, DegreesToRadians(270.0), DegreesToRadians(360.0), FALSE);

   // right side
   CGPathAddLineToPoint (pathRef, NULL, rightPoint.x, rightPoint.y);

   // the bottom curve
   CGPathAddCurveToPoint (pathRef, NULL, rightCtrlPoint.x, rightCtrlPoint.y, leftCtrlPoint.x, leftCtrlPoint.y, leftPoint.x, leftPoint.y);
	
   // left side
   CGPathAddLineToPoint (pathRef, NULL, CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
	
	CGPathCloseSubpath (pathRef);
   
	return (pathRef);
}

+ (CGPathRef)createRoundRectShimInRect:(CGRect)buttonRect
                              ofHeight:(CGFloat)shimHeight
                       withUpperRadius:(CGFloat)upRadius
                        andLowerRadius:(CGFloat)loRadius;
{
	buttonRect.size.height = MIN (buttonRect.size.height, shimHeight + loRadius);
   
	upRadius = MIN (upRadius, 0.5f * MIN(CGRectGetWidth(buttonRect), CGRectGetHeight(buttonRect)));
	loRadius = MIN (loRadius, 0.5f * MIN(CGRectGetWidth(buttonRect), CGRectGetHeight(buttonRect)));
   
	CGRect            insetRect = CGRectInset (buttonRect, upRadius-.5f, upRadius-.5f);
	CGMutablePathRef  pathRef   = CGPathCreateMutable ();
   CGAffineTransform transform = CGAffineTransformMakeScale (1., 0.5);
	
	// top-left corner
	CGPathAddArc (pathRef, NULL, CGRectGetMinX(insetRect), CGRectGetMinY(insetRect), upRadius, DegreesToRadians(180.0), DegreesToRadians(270.0), FALSE);
   
	// top-right corner	
	CGPathAddArc (pathRef, NULL, CGRectGetMaxX(insetRect), CGRectGetMinY(insetRect), upRadius, DegreesToRadians(270.0), DegreesToRadians(360.0), FALSE);
   
   insetRect = CGRectInset (buttonRect, loRadius-.5f, loRadius-.5f);
   
	// bottom-right corner
	CGPathAddArc (pathRef, &transform, CGRectGetMaxX(insetRect), CGRectGetMaxY(insetRect), loRadius, DegreesToRadians(0.0), DegreesToRadians(90.0), FALSE);
   
	// bottom-left corner	
	CGPathAddArc (pathRef, &transform, CGRectGetMinX(insetRect), CGRectGetMaxY(insetRect), loRadius, DegreesToRadians(90.0), DegreesToRadians(180.0), FALSE);
	
	CGPathCloseSubpath (pathRef);
   
	return (pathRef);
}

+ (CGPathRef)createRoundRectPathInRect:(CGRect)buttonRect withCornerRadius:(CGFloat)radius
{
	radius = MIN (radius, 0.5f * MIN(CGRectGetWidth(buttonRect), CGRectGetHeight(buttonRect)));
   
	CGRect            insetRect = CGRectInset (buttonRect, radius-.5f, radius-.5f);
	CGMutablePathRef  pathRef   = CGPathCreateMutable ();
	
	// top-left corner
	CGPathAddArc (pathRef, NULL, CGRectGetMinX(insetRect), CGRectGetMinY(insetRect), radius, DegreesToRadians(180.0), DegreesToRadians(270.0), FALSE);
   
	// top-right corner	
	CGPathAddArc (pathRef, NULL, CGRectGetMaxX(insetRect), CGRectGetMinY(insetRect), radius, DegreesToRadians(270.0), DegreesToRadians(360.0), FALSE);
   
	// bottom-right corner
	CGPathAddArc (pathRef, NULL, CGRectGetMaxX(insetRect), CGRectGetMaxY(insetRect), radius, DegreesToRadians(0.0), DegreesToRadians(90.0), FALSE);
   
	// bottom-left corner	
	CGPathAddArc (pathRef, NULL, CGRectGetMinX(insetRect), CGRectGetMaxY(insetRect), radius, DegreesToRadians(90.0), DegreesToRadians(180.0), FALSE);
	
	CGPathCloseSubpath (pathRef);
   
	return (pathRef);
}

- (CGPathRef)createRoundRectPathInRect:(CGRect)buttonRect withStroke:(CGFloat)stroke andResolution:(CGFloat)resolution
{
	return ([[self class] createRoundRectPathInRect:buttonRect withCornerRadius:[self cornerRadius]]);
}

#ifdef _NIJE_
- (CGPathRef)createRoundRectPathInRect:(CGRect)buttonRect withStroke:(CGFloat)stroke andResolution:(CGFloat)resolution
{
   CGMutablePathRef  path = CGPathCreateMutable ();
   
   CGFloat           alignStroke = fmod (0.5f * stroke * resolution, 1.0f);   
   CGPoint           point = CGPointMake ((buttonRect.size.width - [self cornerRadius]), buttonRect.size.height - 0.5f);
   
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   
   CGPathMoveToPoint (path, NULL, point.x, point.y);
   
   point = CGPointMake (buttonRect.size.width - 0.5f, (buttonRect.size.height - [self cornerRadius]));
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   CGPoint  controlPoint1 = CGPointMake ((buttonRect.size.width - ([self cornerRadius] / 2.f)), buttonRect.size.height - 0.5f);
   controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
   controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
   CGPoint controlPoint2 = CGPointMake(buttonRect.size.width - 0.5f, (buttonRect.size.height - ([self cornerRadius] / 2.f)));
   controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
   controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
   CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
   
   point = CGPointMake(buttonRect.size.width - 0.5f, [self cornerRadius]);
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   CGPathAddLineToPoint(path, NULL, point.x, point.y);
   
   point = CGPointMake((buttonRect.size.width - [self cornerRadius]), 0.0);
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   controlPoint1 = CGPointMake(buttonRect.size.width - 0.5f, ([self cornerRadius] / 2.f));
   controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
   controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
   controlPoint2 = CGPointMake((buttonRect.size.width - ([self cornerRadius] / 2.f)), 0.0);
   controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
   controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
   CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
   
   point = CGPointMake ([self cornerRadius], 0.0);
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   CGPathAddLineToPoint(path, NULL, point.x, point.y);
   
   point = CGPointMake (0.0, [self cornerRadius]);
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   controlPoint1 = CGPointMake (([self cornerRadius] / 2.f), 0.0);
   controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
   controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
   controlPoint2 = CGPointMake (0.0, ([self cornerRadius] / 2.f));
   controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
   controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
   CGPathAddCurveToPoint (path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
   
   point = CGPointMake (0.0, (buttonRect.size.height - [self cornerRadius]));
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   CGPathAddLineToPoint(path, NULL, point.x, point.y);
   
   point = CGPointMake ([self cornerRadius], buttonRect.size.height - 0.5f);
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   controlPoint1 = CGPointMake (0.0, (buttonRect.size.height - ([self cornerRadius] / 2.f)));
   controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
   controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
   controlPoint2 = CGPointMake (([self cornerRadius] / 2.f), buttonRect.size.height - 0.5f);
   controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
   controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
   CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
   
   point = CGPointMake ((buttonRect.size.width - [self cornerRadius]), buttonRect.size.height - 0.5f);
   point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
   point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
   CGPathAddLineToPoint (path, NULL, point.x, point.y);
   
   CGPathCloseSubpath (path);
   
   return (path);
}
#endif

- (void)drawRect:(CGRect)rect
{
   self.backgroundColor = [UIColor clearColor];
   
   CGFloat        insetVal = strokeWeight / 2.f + .5f;
   
   CGRect         buttonRect = CGRectInset (self.bounds, insetVal, insetVal);
   
   CGGradientRef  gradient;
   CGContextRef   context = UIGraphicsGetCurrentContext ();
   CGPoint        point2;
   
   CGRect   imageBounds = CGRectMake (buttonRect.origin.x, buttonRect.origin.y, buttonRect.size.width - 0.5f, buttonRect.size.height);
   CGFloat  resolution = 0.5f * (buttonRect.size.width / imageBounds.size.width + buttonRect.size.height / imageBounds.size.height);
   
   CGFloat  stroke = strokeWeight * resolution;
   if (stroke < 1.0f)
      stroke = ceil (stroke);
   else
      stroke = round (stroke);
   
   stroke /= resolution;
   
   CGPathRef  path = [self createRoundRectPathInRect:buttonRect withStroke:stroke andResolution:resolution];
   
   CGPoint    point;
   
   if (self.state == UIControlStateHighlighted)
      gradient = self.highlightGradient;
   else
      gradient = self.normalGradient;
   
   CGContextSaveGState (context);   // till the end
   
   // CGContextTranslateCTM (context, insetVal, insetVal);
   CGContextAddPath (context, path);
   CGContextSaveGState (context);   // only for the fill gradient
   CGContextEOClip (context);
   
   point = CGPointMake ((buttonRect.size.width / 2.f), buttonRect.size.height - 0.5f);
   point2 = CGPointMake ((buttonRect.size.width / 2.f), 0.f);
   CGContextDrawLinearGradient (context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
   CGContextRestoreGState(context);
   
   [strokeColor setStroke];
   
   CGContextSetLineWidth (context, strokeWeight);
      
   CGContextAddPath (context, path);
   CGContextStrokePath (context);
   CGPathRelease (path);
   
   CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Touch Handling

- (void)hesitateUpdate
{
   [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   [super touchesBegan:touches withEvent:event];
   [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   [super touchesCancelled:touches withEvent:event];
   [self setNeedsDisplay];
   [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   [super touchesMoved:touches withEvent:event];
   [self setNeedsDisplay];
   
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   [super touchesEnded:touches withEvent:event];
   [self setNeedsDisplay];
   [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
   [super encodeWithCoder:encoder];
   
   [encoder encodeObject:[self normalGradientColors] forKey:@"normalGradientColors"];
   [encoder encodeObject:[self normalGradientLocations] forKey:@"normalGradientLocations"];
   [encoder encodeObject:[self highlightGradientColors] forKey:@"highlightGradientColors"];
   [encoder encodeObject:[self highlightGradientLocations] forKey:@"highlightGradientLocations"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
   if (self = [super initWithCoder:decoder])  {
      [self setNormalGradientColors:[decoder decodeObjectForKey:@"normalGradientColors"]];
      [self setNormalGradientLocations:[decoder decodeObjectForKey:@"normalGradientLocations"]];
      [self setHighlightGradientColors:[decoder decodeObjectForKey:@"highlightGradientColors"]];
      [self setHighlightGradientLocations:[decoder decodeObjectForKey:@"highlightGradientLocations"]];
      
      self.strokeColor = [UIColor colorWithRed:0.176 green:0.103 blue:0.195 alpha:1.0];
      self.strokeWeight = 3.0;
      
      if (!self.normalGradientColors)
         [self useNewWhiteStyle];
      
      [self setOpaque:NO];
      self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
   }
   
   return (self);
}

#pragma mark -

- (void)dealloc 
{
   [normalGradientColors release];
   [normalGradientLocations release];
   [highlightGradientColors release];
   [highlightGradientLocations release];
   [strokeColor release];
   
   if (normalGradient)
      CGGradientRelease (normalGradient);
   
   if (highlightGradient)
      CGGradientRelease (highlightGradient);
   
   [super dealloc];
}

@end
