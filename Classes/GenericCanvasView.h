//
//  GenericCanvasView.h
//  ZaSlider
//
//  Created by Igor Delovski on 06.12.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark GenericCanvasViewDelegate
#pragma mark -
// ---------------------------------------------------------------------

@protocol  GenericCanvasViewDelegate
- (void)drawRect:(CGRect)rect withInfo:(id)info;
// @optional
@end

@interface GenericCanvasView : UIView {
   // NSInvocation  *theInvocation;
   
   void           *userInfo;
   id              targetObject;
   SEL             targetMethod;

   id <NSObject, GenericCanvasViewDelegate> canvasDelegate;
}

@property (nonatomic, assign) id <NSObject, GenericCanvasViewDelegate> canvasDelegate;

// @property (nonatomic, retain)  NSInvocation  *theInvocation;

- (id)initWithFrame:(CGRect)frame
           userInfo:(void *)info
             target:(id)tarObject
       targetMethod:(SEL)tarMethod
        andDelegate:(id<NSObject, GenericCanvasViewDelegate>)delegate;

@end
