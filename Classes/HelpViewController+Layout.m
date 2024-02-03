//
//  HelpViewController+Layout.m
//  BCCamera
//
//  Created by Igor Delovski on 24.08.2018.
//  Copyright (c) 2018. Igor Delovski. All rights reserved.
//

#import  "ZaSliderAppDelegate.h"

#import  "HelpViewController.h"
#import  "HelpViewController+Layout.h"

@implementation  HelpViewController (Layout)

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
   NSLog (@"Prf layoutViewComponents - scroll: %@", NSStringFromCGRect(self.scrollView.frame));
   NSLog (@"Prf layoutViewComponents - scrlCont: %@", NSStringFromCGSize(self.scrollView.contentSize));
   NSLog (@"Prf layoutViewComponents - img: %@", NSStringFromCGRect(self.imgView.frame));
   
   viewRect.origin.y += topOffset;
   viewRect.size.height -= topOffset + appDelegate.edgeInsets.bottom;
   
   self.view.frame = viewRect;
   // self.imgView.frame = self.view.frame;
   self.scrollView.frame = self.view.frame;

   tmpRect = viewRect;
   tmpRect.origin.y = viewRect.size.height - bottomBarHeight;
   tmpRect.size.height = bottomBarHeight;
   
   self.bottomToolBar.frame = tmpRect;
   
   NSLog (@"Prf layoutViewComponents - tool: %@", NSStringFromCGRect(self.bottomToolBar.frame));
   NSLog (@"Prf layoutViewComponents - scroll: %@", NSStringFromCGRect(self.scrollView.frame));
}

@end
