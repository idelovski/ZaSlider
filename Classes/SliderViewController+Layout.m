//
//  SliderViewController+Layout.m
//
//  Created by Igor Delovski on 14.01.2024.
//  Copyright (c) 2024. Igor Delovski. All rights reserved.
//

#import  "ZaSliderAppDelegate.h"

#import  "SliderViewController.h"
#import  "SliderViewController+Layout.h"

#import  "GradView.h"

@implementation  SliderViewController (Layout)

- (void)layoutViewComponents
{
   CGRect   viewRect = self.view.frame;
   CGRect   tmpRect;
   CGFloat  bottomBarHeight = 44.f;
   CGFloat  statusHeight = 20.f;
   CGFloat  topOffset = statusHeight;
   CGFloat  verDifference = 0.;
   
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[UIApplication sharedApplication].delegate;
   
   NSLog (@"S layoutViewComponents - window: %@", NSStringFromCGRect(appDelegate.window.frame));
   NSLog (@"S layoutViewComponents - view b: %@", NSStringFromCGRect(self.view.frame));
   
   viewRect = appDelegate.window.frame;
   
   if (appDelegate.edgeInsets.top > statusHeight)  {
      bottomBarHeight = 64.;
      topOffset = appDelegate.edgeInsets.top - statusHeight;
   }
   
   viewRect.origin.y += topOffset;
   viewRect.size.height -= topOffset + appDelegate.edgeInsets.bottom;
   
   verDifference = viewRect.size.height - viewRect.size.width;
   
   self.view.frame = viewRect;
   
   NSLog (@"S layoutViewComponents - view a: %@", NSStringFromCGRect(self.view.frame));

   // Game view
   
   tmpRect = CGRectInset (viewRect, 0., verDifference / 6.);

   CGFloat  heightDifference = CGRectGetMaxY(viewRect) - CGRectGetMaxY(tmpRect);
   
   // tmpRect.origin.y -= (tmpRect.origin.y - viewRect.origin.y);
   tmpRect.origin.y = topOffset + heightDifference / 2.;
   tmpRect.size.height -= topOffset;
   
   self.gameView.frame = tmpRect;
   
   NSLog (@"S layoutViewComponents - game: %@", NSStringFromCGRect(self.gameView.frame));

   // Back image
   
   self.backImageView.frame = appDelegate.window.frame;

   tmpRect = viewRect;
   tmpRect.origin.y = viewRect.size.height - bottomBarHeight;
   tmpRect.size.height = bottomBarHeight;
   
   self.bottomToolBar.frame = tmpRect;
   self.bottomToolBar.backgroundColor = [UIColor whiteColor];
   
   tmpRect = self.middleBarLabel.frame;
   tmpRect.origin.y = self.bottomToolBar.frame.origin.y + 5;
   self.middleBarLabel.frame = tmpRect;

   tmpRect = self.tileIdBarLabel.frame;
   tmpRect.origin.y = self.bottomToolBar.frame.origin.y + 5;
   self.tileIdBarLabel.frame = tmpRect;

   tmpRect = self.tileIdBarBadge.frame;
   tmpRect.origin.y = self.bottomToolBar.frame.origin.y + 6;
   self.tileIdBarBadge.frame = tmpRect;
   
   /*[self.bottomToolBar setBackgroundImage:[UIImage new]
                       forToolbarPosition:UIToolbarPositionAny
                               barMetrics:UIBarMetricsDefault];*/
   
   NSLog (@"S layoutViewComponents - tool: %@", NSStringFromCGRect(self.bottomToolBar.frame));
}

@end
