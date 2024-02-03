//
//  DTCameraViewController+Layout.m
//  BCCamera
//
//  Created by Igor Delovski on 24.08.2018.
//  Copyright (c) 2018. Igor Delovski. All rights reserved.
//

#import  "ZaSliderAppDelegate.h"

#import  "ZaSliderViewController.h"
#import  "ZaSliderViewController+Layout.h"

@implementation  ZaSliderViewController (Layout)

- (void)layoutViewComponents
{
   CGRect   viewRect = self.view.frame;
   // CGRect   tmpRect = viewRect;
   CGFloat  statusHeight = 20.f;
   CGFloat  topOffset = 0.f;
   
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[UIApplication sharedApplication].delegate;
   
   NSLog (@"Z layoutViewComponents - window: %@", NSStringFromCGRect(appDelegate.window.frame));
   NSLog (@"Z layoutViewComponents - view: %@", NSStringFromCGRect(self.view.frame));
   
   if (appDelegate.edgeInsets.top > statusHeight)
      topOffset = appDelegate.edgeInsets.top - statusHeight;
   
   viewRect.origin.y += topOffset;
   viewRect.size.height -= topOffset + appDelegate.edgeInsets.bottom;
   
   if (appDelegate.edgeInsets.top < statusHeight)  // Only on older phones
      if (![NSStringFromCGRect(self.view.frame) isEqualToString:NSStringFromCGRect(viewRect)])
         self.view.frame = viewRect;
}

@end
