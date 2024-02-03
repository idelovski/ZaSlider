//
//  CustomUISwitch.m
//
//  Created by Duane Homick
//  Homick Enterprises - www.homick.com
//

#import "CustomUISwitch.h"

@interface CustomUISwitch ()
@property (nonatomic, retain)  UIImageView  *backgroundImage;
@property (nonatomic, retain)  UIImageView  *switchImage;
- (void)setupUserInterface;
- (void)toggle;
- (void)animateSwitch:(BOOL)toOn;
@end


@implementation CustomUISwitch

@synthesize  backgroundImage = _backgroundImage;
@synthesize  switchImage = _switchImage;
@synthesize  delegate = _delegate;

/** 
 * Constructor
 */
- (id)initWithFrame:(CGRect)frame 
{
	if (self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, SWITCH_DISPLAY_WIDTH, SWITCH_HEIGHT)])  {
      
      [self setupUserInterface];
	}
	
	return (self);
}

/**
 * Setup the user interface
 */
- (void)setupUserInterface
{
   _on = [super isOn];
   _hitCount = 0;
   
   self.backgroundColor = [UIColor clearColor];
   self.clipsToBounds = YES;
   self.autoresizesSubviews = NO;
   self.autoresizingMask = 0;
   self.opaque = YES;
   
   self.userInteractionEnabled = YES;

	/*
   for (UIView  *tmpView in self.subviews)  {
      // if ([view isKindOfClass:[UISwitch class]])
      for (UIView  *subView in tmpView.subviews)  {
         if ([subView isKindOfClass:[UIImageView class]])  {
            NSLog (@"Removing instance of %@", [subView class]);
            [subView removeFromSuperview];
         }
      }
		if ([tmpView isKindOfClass:[UIImageView class]])  {
			NSLog (@"Removing instance of %@", [tmpView class]);
			[tmpView removeFromSuperview];
		}
   }
   */
	
   // Background image
   UIImageView  *bg = [[UIImageView alloc] initWithFrame:RECT_FOR_ON];
   
   bg.image = [UIImage imageNamed:@"switch_on.png"];
   bg.backgroundColor = [UIColor clearColor];
   bg.contentMode = UIViewContentModeLeft;
   bg.userInteractionEnabled = NO;
   self.backgroundImage = bg;
   [bg release];
   
   // Switch image
   UIImageView  *foreground = [[UIImageView alloc] initWithFrame:RECT_FOR_ON];
   foreground.image = [UIImage imageNamed:@"switch.png"];
   foreground.contentMode = UIViewContentModeLeft;
   foreground.userInteractionEnabled = NO;
   self.switchImage = foreground;
   [foreground release];
	
   // Check for user input
/*   
   [self    addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
*/
   [self    addTarget:self
               action:@selector(hadTouchDown:forEvent:)
     forControlEvents:UIControlEventTouchDown];
   [self    addTarget:self
               action:@selector(hadTouchDragInside:forEvent:)
     forControlEvents:UIControlEventTouchDragInside];
   [self    addTarget:self
               action:@selector(hadTouchDragExit:forEvent:)
     forControlEvents:UIControlEventTouchDragExit];
   [self    addTarget:self
               action:@selector(hadTouchUpInside:forEvent:)
     forControlEvents:UIControlEventTouchUpInside];
   [self    addTarget:self
               action:@selector(hadTouchUpOutside:forEvent:)
     forControlEvents:UIControlEventTouchUpOutside];
   
   [self addSubview:self.backgroundImage];
   [self.backgroundImage addSubview:self.switchImage];
   
   _startPt = CGPointZero;
}

/**
 * Destructor
 */
- (void)dealloc
{
   [_backgroundImage release];
   [_switchImage release];
   
   [super dealloc];
}

#pragma mark -

/**
 * Drawing Code
 */
- (void)drawRect:(CGRect)rect 
{
   // nothing
}

/**
 * Configure it into a certain state   BUG?
 */

- (void)setFramesForOn:(BOOL)on
{
   if ((_on = on))  {
      self.switchImage.frame = RECT_FOR_ON;
      self.backgroundImage.image = [UIImage imageNamed:@"switch_on.png"];
   }
   else  {
      self.switchImage.frame = RECT_FOR_OFF;
      self.backgroundImage.image = [UIImage imageNamed:@"switch_off.png"];
   }
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
	[super setOn:on animated:animated];
	
#ifdef  _SYS_APIS_LOG_
   NSLog (@"setOn:[%d] animated:", on);
#endif
	[self setFramesForOn:on];
   _startPt = CGPointZero;
}

- (void)setOn:(BOOL)on
{
   [super setOn:on];
	
	[self setFramesForOn:on];

   _startPt = CGPointZero;
}

/**
 * Check if on
 */
- (BOOL)isOn
{
   return ([super isOn]);
}

/**
 * Capture user input
 */
- (void)buttonPressed:(id)sender
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"buttonPressed:, _hitCount: %d", _hitCount);
#endif
   // We use a hit count to properly queue up multiple hits on the button while we are animating.
   if (!_hitCount)
      [self toggle];

   // else, do not animate, this will happen when other animation finishes
   // _hitCount++;
   _hitCount = 1;
}

- (void)hadTouchDown:(id)sender forEvent:(UIEvent *)event
{
   UITouch  *touch = [[event allTouches] anyObject];
   
   _startPt = [touch locationInView:self.backgroundImage];
   
#ifdef  _SYS_APIS_LOG_
   NSLog (@"hadTouchDown:forEvent: Point:[%.1f,%.1f]", _startPt.x, _startPt.y);
#endif
}

- (void)hadTouchDragInside:(id)sender forEvent:(UIEvent *)event
{
   UITouch  *touch = [[event allTouches] anyObject];
   CGPoint   pt = [touch locationInView:self.backgroundImage];
   CGFloat   delta;
   CGRect    knobRect = _on ? RECT_FOR_ON : RECT_FOR_OFF;
   CGRect    newFrame = knobRect;
   CGRect    oldFrame = self.switchImage.frame;
   
   if (!CGPointEqualToPoint(_startPt, CGPointZero))  {
      if (pt.x < _startPt.x)  {
         if (_on)  {
            // NSLog (@"hadTouchDragInside:forEvent: LEFT");
            delta = pt.x - _startPt.x;
            if (delta > -55. && delta < 0.)  {
               // NSLog (@"hadTouchDragInside:forEvent: LEFT + DELTA");
               newFrame.origin.x = knobRect.origin.x + delta;
               self.switchImage.frame = newFrame;
            }
         }
      }
      else  if (pt.x > _startPt.x)  {
         if (!_on)  {
            // NSLog (@"hadTouchDragInside:forEvent: RIGHT");
            delta = pt.x - _startPt.x;
            if (delta > 0. && delta < 55.)  {
               // NSLog (@"hadTouchDragInside:forEvent: RIGHT + DELTA");
               newFrame.origin.x = knobRect.origin.x + delta;
               self.switchImage.frame = newFrame;
            }
         }
      }
   }
   if (!CGPointEqualToPoint(oldFrame.origin, self.switchImage.frame.origin))  {
      CGRect    halfFrame = RECT_FOR_HALFWAY;

#ifdef  _SYS_APIS_LOG_
      NSLog (@"hadTouchDragInside:forEvent: SWITCH IMAGE");
#endif
      if (self.switchImage.frame.origin.x > halfFrame.origin.x)
         self.backgroundImage.image = [UIImage imageNamed:@"switch_on.png"];
      else
         self.backgroundImage.image = [UIImage imageNamed:@"switch_off.png"];
   }
   // self.switchImage.frame = RECT_FOR_OFF;
}

- (void)hadTouchDragExit:(id)sender forEvent:(UIEvent *)event
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"hadTouchDragExit:forEvent:");
#endif
}

- (void)hadTouchUpInside:(id)sender forEvent:(UIEvent *)event
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"hadTouchUpInside:forEvent:");
#endif
   /*
   UITouch  *touch = [[event allTouches] anyObject];
   CGPoint   pt = [touch locationInView:self.backgroundImage];
   
   if (!CGPointEqualToPoint(_startPt, CGPointZero))  {
      if (pt.x < _startPt.x)
         NSLog (@"hadTouchUpInside:forEvent: LEFT");
      else  if (pt.x > _startPt.x)
         NSLog (@"hadTouchUpInside:forEvent: RIGHT");
   }
*/
   BOOL  newState = [super isOn];
   
   if (newState != _on)  {
      _hitCount++;
      [self toggle];
   }
   else  {
      self.switchImage.frame = _on ? RECT_FOR_ON : RECT_FOR_OFF;
   }

   _startPt = CGPointZero;
}

- (void)hadTouchUpOutside:(id)sender forEvent:(UIEvent *)event
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"hadTouchUpOutside:forEvent:");
#endif
   _startPt = CGPointZero;
}

- (void)buttonPressed:(id)sender forEvent:(UIEvent *)event
{
   if (sender == self)  {        
      UITouch  *touch = [[event allTouches] anyObject];
      // UITouch  *touch = [[event touchesForView:self.backgroundImage] anyObject];
      CGPoint   pt = [touch locationInView:self.backgroundImage];
#ifdef  _SYS_APIS_LOG_
      NSLog (@"Point:[%.1f,%.1f] in frame: [x=%.1f,w=%.1f]", pt.x, pt.y, self.frame.origin.x, self.frame.size.width);
#endif
      if (pt.x < self.frame.size.width / 2.0)  {
         // left side touch
#ifdef  _SYS_APIS_LOG_
         NSLog (@"buttonPressed:forEvent: LEFT");
#endif
      }
#ifdef  _SYS_APIS_LOG_
      else  {
         // right side touch
         NSLog (@"buttonPressed:forEvent: RIGHT");
      }
#endif
   }
#ifdef  _SYS_APIS_LOG_
   else
      NSLog (@"buttonPressed:forEvent: UNK!");
#endif
}

/**
 * Toggle ison
 */
- (void)toggle
{
   _on = !_on;
   
   [self animateSwitch:_on];
}

/**
 * Animate the switch by sliding halfway and then changing the background image and then sliding the rest of the way.
 */
- (void)animateSwitch:(BOOL)toOn
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"animateSwitch:");
#endif
   
   BOOL    forgetAnimations = NO;

   CGRect  oldFrame = self.switchImage.frame;
   CGRect  newFrame = toOn ? RECT_FOR_ON : RECT_FOR_OFF;
   
   if (fabs(oldFrame.origin.x - newFrame.origin.x) < 24.f)
      forgetAnimations = YES;
   
   if (!forgetAnimations)  {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:0.1];
   
      self.switchImage.frame = RECT_FOR_HALFWAY;
 	}
   
   [UIView beginAnimations:nil context:nil];
   [UIView setAnimationDuration:0.1];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(animationHasFinished:finished:context:)];
	
   if (toOn)  {
      self.switchImage.frame = RECT_FOR_ON;
      self.backgroundImage.image = [UIImage imageNamed:@"switch_on.png"];
   }
   else  {
      self.switchImage.frame = RECT_FOR_OFF;
      self.backgroundImage.image = [UIImage imageNamed:@"switch_off.png"];
   }
   
   [UIView commitAnimations];  // There are 2 animations going on
   if (!forgetAnimations)
      [UIView commitAnimations];
}

/**
 * Remove the view no longer visible
 */
- (void)animationHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"animationHasFinished:finished:_hitCount:context: %d", _hitCount);
#endif

   if (_delegate)
      [_delegate valueChangedInView:self];
   
   // We use a hit count to properly queue up multiple hits on the button while we are animating.
   // if (_hitCount > 1)
   //   [self toggle];
   
   _hitCount--;
}

#pragma mark -
#pragma mark Touch Handling

#ifdef _NIJE_

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"beginTrackingWithTouch:withEvent:");
#endif

   return ([super beginTrackingWithTouch:touch withEvent:event]);
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"endTrackingWithTouch:withEvent:");
#endif
   
   [super endTrackingWithTouch:touch withEvent:event];
}

// ---

- (void)hesitateUpdate
{
   [self setNeedsDisplay];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"touchesBegan:withEvent:");
#endif
   // [super touchesBegan:touches withEvent:event];
   // [self setNeedsDisplay];
	
	[self hadTouchDown:self forEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   NSLog (@"touchesCancelled:withEvent:");
   // [super touchesCancelled:touches withEvent:event];
   // [self setNeedsDisplay];
   [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   NSLog (@"touchesMoved:withEvent:");
   // [super touchesMoved:touches withEvent:event];
   // [self setNeedsDisplay];
	
	[self hadTouchDragInside:self forEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   NSLog (@"touchesEnded:withEvent:");
   // [super touchesEnded:touches withEvent:event];
   // [self setNeedsDisplay];
   // [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
	// [self hadTouchUpInside:self forEvent:event];
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
   [super encodeWithCoder:encoder];
   
   [encoder encodeObject:_backgroundImage forKey:@"backgroundImage"];
   [encoder encodeObject:_switchImage forKey:@"switchImage"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
   if (self = [super initWithCoder:decoder])  {
      [self setupUserInterface];
   }
   
   return (self);
}

@end
