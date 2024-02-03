//
//  dTOOLiOS_Basic
//
//  Created by Igor Delovski on 14.01.2024
//  Copyright (c) 2024 Delovski d.o.o. All rights reserved.
//

// #import  <QuartzCore/QuartzCore.h>
// #import  <CommonCrypto/CommonDigest.h>

#import  "dTOOLiOS_Basic.h"

// --------------------------
@implementation DToolBasic
// --------------------------

+ (UIEdgeInsets)edgeInsetsForView:(UIView *)theView
{
   // We're doing this:
   // if ([self.view respondsToSelector:@selector(safeAreaInsets)])
   //    safeInsets = [self.view safeAreaInsets];
   
   UIEdgeInsets  safeInsets = UIEdgeInsetsZero;
   
   SEL  selSafeAreaInsets = NSSelectorFromString (@"safeAreaInsets");
   
   if ([theView respondsToSelector:selSafeAreaInsets])  {
      
      NSInvocation  *invocation = [NSInvocation invocationWithMethodSignature:[[theView class] instanceMethodSignatureForSelector:selSafeAreaInsets]];
      
      [invocation setSelector:selSafeAreaInsets];
      [invocation setTarget:theView];
      [invocation invoke];
      
      [invocation getReturnValue:&safeInsets];
   }
   
   NSLog (@"Insets: %@", NSStringFromUIEdgeInsets(safeInsets));
   
   return (safeInsets);
}

@end

#pragma mark -
#pragma mark C Interface
#pragma mark -

#pragma mark -

CGRect  CGRectOfSize (CGSize recSize)
{
   CGRect  rect;
   
   rect.origin.x = 0.f; rect.origin.y = 0.f;
   
   rect.size.width  = recSize.width;
   rect.size.height = recSize.height;
   
   return (rect);
}

