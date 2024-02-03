//
//  CustomUISwitch.h
//
//  Created by Duane Homick
//  Homick Enterprises - www.homick.com
//
//  The CustomUISwitch can be used the same way a UISwitch can, but using the PSD attached, you can create your own color scheme.

#import <UIKit/UIKit.h>


#define SWITCH_DISPLAY_WIDTH     94.0
#define SWITCH_WIDTH            149.0
#define SWITCH_HEIGHT            27.0

#define RECT_FOR_OFF         CGRectMake(-55.0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)
#define RECT_FOR_ON          CGRectMake(0.0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)
#define RECT_FOR_HALFWAY     CGRectMake(-27.5, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)



@protocol CustomUISwitchDelegate;

@interface CustomUISwitch : UISwitch <NSCoding>  {
   NSInteger     _hitCount;
   UIImageView  *_backgroundImage;
   UIImageView  *_switchImage;

   id            <CustomUISwitchDelegate> _delegate;
   BOOL          _on;
   
   CGPoint       _startPt;
}

@property (nonatomic, assign)  id  delegate;

- (id)initWithFrame:(CGRect)frame;              // This class enforces a size appropriate for the control. The frame size is ignored.

// overrides
- (void)setOn:(BOOL)on animated:(BOOL)animated; // does not send action
- (BOOL)isOn;

@end


@protocol CustomUISwitchDelegate

@optional
- (void)valueChangedInView:(CustomUISwitch*)view;

@end

