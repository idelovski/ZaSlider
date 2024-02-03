//
//  MenuViewController+Layout.m
//
//  Created by Igor Delovski on 14.01.2024.
//  Copyright (c) 2024. Igor Delovski. All rights reserved.
//

#import  "ZaSliderAppDelegate.h"

#import  "MenuViewController.h"
#import  "MenuViewController+Layout.h"

@implementation  MenuViewController (Layout)

- (void)layoutViewComponents
{
   CGRect   viewRect = self.view.frame;
   CGRect   tmpRect, buttonRect;
   CGFloat  statusHeight = 20.f;
   CGFloat  topOffset = 0.f;
   CGFloat  verticalBtnOffset = 0.f;
   CGFloat  bottomSpace = 0.f;
   // CGFloat  btnHeight = 0.f;
   
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[UIApplication sharedApplication].delegate;
   
   NSLog (@"M layoutViewComponents - window: %@", NSStringFromCGRect(appDelegate.window.frame));
   NSLog (@"M layoutViewComponents - view: %@", NSStringFromCGRect(self.view.frame));
   
   viewRect = appDelegate.window.frame;

   if (appDelegate.edgeInsets.top > statusHeight)
      topOffset = appDelegate.edgeInsets.top - statusHeight;
   
   viewRect.origin.y += topOffset;
   viewRect.size.height -= topOffset + appDelegate.edgeInsets.bottom;
   
   if (![NSStringFromCGRect(self.view.frame) isEqualToString:NSStringFromCGRect(viewRect)])  {
      self.view.frame = appDelegate.window.frame;
   
      self.imageView.frame = appDelegate.window.frame;  // self.view.frame;
      
      tmpRect = viewRect;  // frame minus staus and bottom bar
      
      bottomSpace = tmpRect.size.height - (self.helpButton.frame.origin.y + self.helpButton.frame.size.height);

      verticalBtnOffset = bottomSpace / 3.;

      [self resizeButton:self.startButton verOffset:verticalBtnOffset];
      [self resizeButton:self.historyButton verOffset:verticalBtnOffset];
      [self resizeButton:self.prefsButton verOffset:verticalBtnOffset];
      [self resizeButton:self.addPhotoButton verOffset:verticalBtnOffset];
      [self resizeButton:self.netSearchButton verOffset:verticalBtnOffset];
      [self resizeButton:self.helpButton verOffset:verticalBtnOffset];
   }
}

- (void)resizeButton:(UIButton *)button verOffset:(CGFloat)verticalBtnOffset
{
   CGRect  buttonRect = button.frame;
   
   buttonRect.size.width = self.view.frame.size.width /*- buttonRect.origin.x * 2.*/;
   
   buttonRect.origin.y += verticalBtnOffset;
   
   button.frame = buttonRect;
   
   [button setTitle:nil forState:UIControlStateNormal];
   [button setTitle:nil forState:UIControlStateHighlighted];
}

@end
