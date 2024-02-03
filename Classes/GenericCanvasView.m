//
//  GenericCanvasView.m
//  ZaSlider
//
//  Created by Igor Delovski on 06.12.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "GenericCanvasView.h"


@implementation GenericCanvasView

@synthesize  canvasDelegate;


- (id)initWithFrame:(CGRect)frame
           userInfo:(void *)info
             target:(id)tarObject
       targetMethod:(SEL)tarMethod
        andDelegate:(id<NSObject, GenericCanvasViewDelegate>)delegate;
{
   if (self = [super initWithFrame:frame])  {
      userInfo = info;
      canvasDelegate = delegate;
      targetObject = tarObject;
      targetMethod = tarMethod;
            
      /*
      NSMethodSignature *theSignature = [tarObject methodSignatureForSelector:tarMethod];
      NSInvocation      *tmpInvocation = [NSInvocation invocationWithMethodSignature:theSignature];
      
      [tmpInvocation setTarget:tarObject];
      [tmpInvocation setSelector:tarMethod];
      
      [tmpInvocation setArgument:&userInfo atIndex:2];
      
      self.theInvocation = tmpInvocation;
      
      [tmpInvocation release];
       */
      self.userInteractionEnabled = NO;
      self.backgroundColor = [UIColor clearColor];
   }
   
   return (self);
}


- (void)drawRect:(CGRect)rect
{
   // Drawing code
   if ([canvasDelegate respondsToSelector:@selector(drawRect:withInfo:)])
      [canvasDelegate drawRect:rect withInfo:userInfo];
   else  if (targetObject && targetMethod)
      [targetObject performSelector:targetMethod
                         withObject:[NSValue valueWithCGRect:rect]  // rect = [someNSValue CGRectValue];
                         withObject:[NSValue valueWithPointer:userInfo]];  // ptr = [someNSValue pointerValue];
}


- (void)dealloc
{
   // [theInvocation release];
   
   [super dealloc];
}


@end
