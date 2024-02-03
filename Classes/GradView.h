//
//  DrawView.h
//  Gradient
//
//  Created by Richard Wentk on 21/10/2009.
//  Copyright 2009 Skydancer Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GradView : UIView {
   CGGradientRef   usedGradient;
   CGColorSpaceRef myRGB;
}

@end

#pragma mark -

#define  kTABLE_CELL_BACKGROUND    { 1, 1, 1, 1, 0.866, 0.866, 0.866, 1}			// #FFFFFF and #DDDDDD
#define  kDefaultCellMargin        10

typedef enum  {
   UACellBackgroundViewPositionSingle = 0,
   UACellBackgroundViewPositionTop, 
   UACellBackgroundViewPositionBottom,
   UACellBackgroundViewPositionMiddle
} UACellBackgroundViewPosition;

@interface UACellBackgroundView : UIView {
   UACellBackgroundViewPosition position;
}

@property(nonatomic) UACellBackgroundViewPosition position;

@end

#pragma mark -

@interface OvalBadgeView : UIView {
   CGFloat  cornerRadius;
   UIColor *badgeColor;
}

- (id)initWithFrame:(CGRect)frame cornerRadius:(CGFloat)radius andColor:(UIColor *)color;

@end

#pragma mark -

@interface OvalLabelView : UIView  {
   CGRect     initialFrame;
   CGFloat    cornerRadius;
   UIColor   *textColor;     // used for frame too
   UIColor   *badgeColor;    // background
   // NSString  *labText;
   
   UILabel   *contentLabel;
}

@property (nonatomic, retain)  NSString  *text;  // labels text

- (id)initWithFrame:(CGRect)lFrame
          labelText:(NSString *)lText
       cornerRadius:(CGFloat)cRadius
          textColor:(UIColor *)txColor
       andBackColor:(UIColor *)bkColor;

@end

