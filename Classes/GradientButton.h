//
//  ButtonGradientView.h
//  Custom Alert View
//
//  Created by jeff on 5/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#define DegreesToRadians(degrees)   (degrees * M_PI / 180)

typedef struct rgblQuads {
   CGFloat  r;
   CGFloat  g;
   CGFloat  b;
   CGFloat  loc;
} RGBLocQuad;
   
@interface GradientButton : UIButton 
{
    // These two arrays define the gradient that will be used
    // when the button is in UIControlStateNormal
    NSArray        *normalGradientColors;     // Colors
    NSArray        *normalGradientLocations;  // Relative locations
    
    // These two arrays define the gradient that will be used
    // when the button is in UIControlStateHighlighted 
    NSArray        *highlightGradientColors;     // Colors
    NSArray        *highlightGradientLocations;  // Relative locations
    
    // This defines the corner radius of the button
    CGFloat         cornerRadius;
    
    // This defines the size and color of the stroke
    CGFloat         strokeWeight;
    UIColor        *strokeColor;
    
@private
    CGGradientRef   normalGradient;
    CGGradientRef   highlightGradient;
}

@property (nonatomic, retain)  NSArray  *normalGradientColors;
@property (nonatomic, retain)  NSArray  *normalGradientLocations;
@property (nonatomic, retain)  NSArray  *highlightGradientColors;
@property (nonatomic, retain)  NSArray  *highlightGradientLocations;

@property (nonatomic)          CGFloat   cornerRadius;
@property (nonatomic)          CGFloat   strokeWeight;
@property (nonatomic, retain)  UIColor  *strokeColor;

+ (CGGradientRef)createGradientWithColors:(NSArray *)gradientColors
                             andLocations:(NSArray *)gradientLocations;
+ (CGPathRef)createRoundRectPathInRect:(CGRect)buttonRect
                      withCornerRadius:(CGFloat)radius;

- (CGPathRef)createRoundRectPathInRect:(CGRect)buttonRect
                            withStroke:(CGFloat)stroke
                         andResolution:(CGFloat)resolution;

+ (CGPathRef)createRoundRectShimInRect:(CGRect)buttonRect
                              ofHeight:(CGFloat)shimHeight
                      withCornerRadius:(CGFloat)radius;
+ (CGPathRef)createRoundRectShimInRect:(CGRect)buttonRect
                              ofHeight:(CGFloat)shimHeight
                       withUpperRadius:(CGFloat)upRadius 
                        andLowerRadius:(CGFloat)loRadius;

/*
- (void)useAlertStyle;
- (void)useRedDeleteStyle;
- (void)useWhiteStyle;
- (void)useBlackStyle;
- (void)useWhiteActionSheetStyle;
- (void)useBlackActionSheetStyle;
- (void)useSimpleOrangeStyle;
- (void)useGreenConfirmStyle;
*/

- (void)useNewAlertStyle;
- (void)useNewRedDeleteStyle;
- (void)useNewWhiteStyle;
- (void)useNewBlackStyle;
- (void)useNewWhiteActionSheetStyle;
- (void)useNewBlackActionSheetStyle;  // needs white text even when highlighted
- (void)useNewOrangeStyle;
- (void)useNewGreenConfirmStyle;

- (void)useNewRedLightStyle;
- (void)useNewVelvetStyle;
- (void)useNewGoldenStyle;
- (void)useNewBlueLightStyle;
- (void)useNewBlueAzureStyle;
- (void)useNewBlueStyle;
- (void)useNewBlueCoolStyle;
- (void)useNewBlueIndigoStyle;
- (void)useNewPinkishStyle;

@end
