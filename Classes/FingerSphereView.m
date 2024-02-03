//
//  FingerSphereView.m
//  ZaSlider
//
//  Created by Igor Delovski on 28.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "FingerSphereView.h"


@implementation  FingerSphereView


- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame])  {
      // Initialization code
      self.userInteractionEnabled = NO;
      self.backgroundColor = [UIColor clearColor];
   }
   
   return (self);
}


- (void)drawRect:(CGRect)rect
{
   CGFloat          locations[2]  = { 0., 1. };
   CGFloat          components[8] = { .89, .49, .79, .7, .99, .49, .89, .3 };  // was ... 1. ... .7
   
   CGFloat          sphereHorSize = self.bounds.size.width * 2.f / 3.f;
   CGFloat          horOffset = (self.bounds.size.width - sphereHorSize) / 2.f;
   CGFloat          sphereVerSize = self.bounds.size.height * 2.f / 3.f;
   CGFloat          verOffset = (self.bounds.size.height - sphereVerSize) / 2.f;
   
   CGContextRef     ctx = UIGraphicsGetCurrentContext ();
   
   CGColorSpaceRef  colorSpace = CGColorSpaceCreateDeviceRGB ();
   CGGradientRef    gradient   = CGGradientCreateWithColorComponents (colorSpace, components, locations, 2);

   CGPoint          offsetCenter = CGPointMake (horOffset + sphereHorSize/2 - kSphereCenterOffset,
                                                verOffset + sphereVerSize/2 - kSphereCenterOffset);
   CGPoint          center       = CGPointMake (horOffset + sphereHorSize/2, verOffset + sphereVerSize/2);
   
   CGContextDrawRadialGradient (ctx, gradient, offsetCenter, 0, center, sphereHorSize/2, 0);

   /*
   CGPoint          offsetCenter = CGPointMake (kSphereSize/2 - kSphereCenterOffset,
                                                kSphereSize/2 - kSphereCenterOffset);
   CGPoint          center       = CGPointMake (kSphereSize/2, kSphereSize/2);
   
   CGContextDrawRadialGradient (ctx, gradient, offsetCenter, 0, center, kSphereSize/2, 0);
   */
   CFRelease (gradient);
   CFRelease (colorSpace);
}


- (void)dealloc
{
   [super dealloc];
}


@end
