//
//  PrefsViewController+Layout.m
//  BCCamera
//
//  Created by Igor Delovski on 24.08.2018.
//  Copyright (c) 2018. Igor Delovski. All rights reserved.
//

#import  "ZaSliderAppDelegate.h"

#import  "PrefsViewController.h"
#import  "PrefsViewController+Layout.h"

@implementation  PrefsViewController (Layout)

- (void)layoutViewComponents
{
   CGRect   viewRect = self.view.frame;
   CGRect   tmpRect = viewRect;
   CGFloat  bottomBarHeight = 44.f;
   CGFloat  statusHeight = 20.f;
   CGFloat  topOffset = 0.f;
   
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[UIApplication sharedApplication].delegate;
   
   NSLog (@"Prf layoutViewComponents - window: %@", NSStringFromCGRect(appDelegate.window.frame));
   NSLog (@"Prf layoutViewComponents - view: %@", NSStringFromCGRect(self.view.frame));
   
   viewRect = appDelegate.window.frame;
   
   if (appDelegate.edgeInsets.top > statusHeight)  {
      bottomBarHeight = 64.;
      topOffset = appDelegate.edgeInsets.top - statusHeight;
   }
   
   viewRect.origin.y += topOffset;
   viewRect.size.height -= topOffset + appDelegate.edgeInsets.bottom;
   
   self.view.frame = viewRect;
   self.imageView.frame = self.view.frame;

   tmpRect = viewRect;
   tmpRect.origin.y = viewRect.size.height - bottomBarHeight;
   tmpRect.size.height = bottomBarHeight;
   
   self.bottomToolBar.frame = tmpRect;
   
   NSLog (@"Prf layoutViewComponents - tool: %@", NSStringFromCGRect(self.bottomToolBar.frame));
}

@end
