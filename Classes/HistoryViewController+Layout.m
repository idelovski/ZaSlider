//
//  HistoryViewController+Layout.m
//
//  Created by Igor Delovski on 14.01.2024.
//  Copyright (c) 2024. Igor Delovski. All rights reserved.
//

#import  "ZaSliderAppDelegate.h"

#import  "HistoryViewController.h"
#import  "HistoryViewController+Layout.h"

@implementation  HistoryViewController (Layout)

- (void)layoutViewComponents
{
   CGRect   viewRect = self.view.frame;
   CGFloat  statusHeight = 20.f;
   CGFloat  topOffset = 0.f;
   
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[UIApplication sharedApplication].delegate;
      
   viewRect = appDelegate.window.frame;
   
   if (appDelegate.edgeInsets.top > statusHeight)
      topOffset = appDelegate.edgeInsets.top - statusHeight;
   
   viewRect.origin.y += topOffset;
   viewRect.size.height -= topOffset + appDelegate.edgeInsets.bottom;
   
   self.view.frame = viewRect;
   
   // self.imageView.frame = self.view.frame;
   NSLog (@"H layoutViewComponents - view: %@", NSStringFromCGRect(self.view.frame));
}

@end
