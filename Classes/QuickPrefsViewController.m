//
//  QuickPrefsViewController.m
//  ZaSlider
//
//  Created by Igor Delovski on 31.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "QuickPrefsViewController.h"

#import "PrefsViewController.h"
#import "ZaSliderAppDelegate.h"
#import "ZaSliderViewController.h"
#import "CustomUISwitch.h"


@implementation QuickPrefsViewController

@synthesize  backgroundImageView, centerImageView, prevImageView, nextImageView;
@synthesize  accelLabelImageView, numbersLabelImageView;
@synthesize  accelSwitch, numbersSwitch/*, arrowSwitch,*/ /*elemsSegmetCtrl, coopLabel, coopSegmetCtrl*/;
@synthesize  elemsBtn01, elemsBtn02, elemsBtn03, elemsBtn04, elemsButtonIndex;
@synthesize  coopLabelImageView, coopBtn01,  coopBtn02, coopButtonIndex, playButton, cancelButton;
@synthesize  mainViewController, usedImage, imageKey, builtInAlbumIndex;
@synthesize  touchView, gestureStartPoint;

- (id)initWithMainViewController:(UIViewController *)vc
                        imageKey:(NSString *)imgKey
               builtInAlbumIndex:(NSUInteger)idx
                   inNetworkMode:(BOOL)inNetworkFlag
                         nibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])  {
      // Custom initialization
      self.mainViewController = (ZaSliderViewController *)vc;
      self.imageKey = imgKey;
      self.builtInAlbumIndex = idx;
      self.usedImage = [self.mainViewController imageForImageKey:imgKey orBuiltInIndex:idx];
      
      inNetworkModeFlag = inNetworkFlag;
      elemsButtonIndex = -1;
      coopButtonIndex = -1;
   }
   
   return (self);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   return ([self initWithMainViewController:nil
                                   imageKey:nil
                          builtInAlbumIndex:0
                              inNetworkMode:NO
                                    nibName:nibNameOrNil
                                     bundle:nibBundleOrNil]);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   elemsBtn01.exclusiveTouch = YES;
   elemsBtn02.exclusiveTouch = YES;
   elemsBtn03.exclusiveTouch = YES;
   elemsBtn04.exclusiveTouch = YES;
   
   coopBtn01.exclusiveTouch = YES;
   coopBtn02.exclusiveTouch = YES;

   if (!inNetworkModeFlag)  {     // Single play
      // coopLabel.hidden = YES;
      // coopSegmetCtrl.hidden = YES;
      coopLabelImageView.hidden = YES;
      coopBtn01.hidden = YES;
      coopBtn02.hidden = YES;
   }
   else  {
      backgroundImageView.image = [UIImage imageNamed:@"WF_iP3preplay3Wibackground.png"];
      
      
      
      CGRect  buttonFrame = cancelButton.frame;
      playButton.frame = buttonFrame;
      [playButton setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_19.png"]
                  forState:UIControlStateNormal];
      [playButton setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_19klik.png"]
                  forState:UIControlStateHighlighted];
      cancelButton.hidden = YES;
      
      [self offsetView:accelLabelImageView horizontally:0.f vertically:-8.f];
      [self offsetView:accelSwitch horizontally:0.f vertically:-8.f];
      [self offsetView:numbersLabelImageView horizontally:0.f vertically:-16.f];
      [self offsetView:numbersSwitch horizontally:0.f vertically:-16.f];
      
      
      [elemsBtn01 setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_08.png"]  // was 08
                  forState:UIControlStateNormal];
      [elemsBtn01 setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_klik_08.png"]
                  forState:UIControlStateHighlighted];
      
      [elemsBtn02 setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_09.png"]
                  forState:UIControlStateNormal];
      [elemsBtn02 setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_klik_09.png"]
                  forState:UIControlStateHighlighted];
      [elemsBtn03 setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_10.png"]
                  forState:UIControlStateNormal];
      [elemsBtn03 setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_klik_10.png"]
                  forState:UIControlStateHighlighted];
      [elemsBtn04 setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_11.png"]
                  forState:UIControlStateNormal];
      [elemsBtn04 setImage:[UIImage imageNamed:@"WF_iP4preplay3Wi_klik_11.png"]
                  forState:UIControlStateHighlighted];
      
   }

   self.centerImageView.image = self.usedImage;

   self.accelSwitch.on = gGPrefsRec.pfUseAcceleration;
   self.numbersSwitch.on = gGPrefsRec.pfShowNumbers;
   // self.arrowSwitch.on = gGPrefsRec.pfShowArrow;
   
   // self.elemsSegmetCtrl.selectedSegmentIndex = gGPrefsRec.pfSideElems - 3;
   [self registerElemButtonPressed:[self buttonForElemIndex:gGPrefsRec.pfSideElems - 3]];

   // self.coopSegmetCtrl.selectedSegmentIndex  = gGPrefsRec.pfCooperationMode ? 1 : 0;
   [self registerCoopButtonPressed:[self buttonForCoopIndex:gGPrefsRec.pfCooperationMode ? 1 : 0]];
   
   [self loadSideImages];
   
   aniCenterImageView = aniPrevImageView = aniNextImageView = nil;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   
#ifdef _FREEMEM_
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate handleCheckMemoryWithDescription:@"QuickPrefsViewController-viewDidAppear:" showAlert:NO];
#endif
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
   
   self.centerImageView = nil;
   self.prevImageView = nil;
   self.nextImageView = nil;
   
   self.accelSwitch = nil;
   self.numbersSwitch = nil;
   // self.arrowSwitch = nil;
   // self.elemsSegmetCtrl = nil;
   self.elemsBtn01 = nil;
   self.elemsBtn02 = nil;
   self.elemsBtn03 = nil;
   self.elemsBtn04 = nil;
   
   // self.coopLabel = nil;
   // self.coopSegmetCtrl = nil;
   
   self.playButton = nil;
   self.cancelButton = nil;
}


- (void)dealloc
{
   [backgroundImageView release];
   
   [centerImageView release];
   [prevImageView release];
   [nextImageView release];
   
   [accelLabelImageView release];
   [numbersLabelImageView release];
   [accelSwitch release];
   [numbersSwitch release];

   [elemsBtn01 release];
   [elemsBtn02 release];
   [elemsBtn03 release];
   [elemsBtn04 release];
   // [elemsSegmetCtrl release];
   // [coopLabel release];
   // [coopSegmetCtrl release];
   
   [coopLabelImageView release];
   [coopBtn01 release];
   [coopBtn02 release];
   
   [playButton release];
   [cancelButton release];
   
   [mainViewController release];
   [usedImage release];
   [imageKey release];
   [touchView release];

   [super dealloc];
}

#pragma mark -

- (void)offsetView:(UIView *)theView horizontally:(CGFloat)hor vertically:(CGFloat)ver
{
   CGRect  tmpRect = theView.frame;
   
   tmpRect.origin.x += hor;
   tmpRect.origin.y += ver;
   
   theView.frame = tmpRect;
}

- (UIButton *)buttonForElemIndex:(NSInteger)idx
{
   UIButton  *btn = nil;
   
   if (idx == 0)
      btn = self.elemsBtn01;
   else  if (idx == 1)
      btn = self.elemsBtn02;
   else  if (idx == 2)
      btn = self.elemsBtn03;
   else  if (idx == 3)
      btn = self.elemsBtn04;
   
   return (btn);
}

- (NSInteger)elemIndexForButton:(UIButton *)btn
{
   NSInteger  idx = -1;
   
   if (btn == self.elemsBtn01)
      idx = 0;
   else  if (btn == self.elemsBtn02)
      idx = 1;
   else  if (btn == self.elemsBtn03)
      idx = 2;
   else  if (btn == self.elemsBtn04)
      idx = 3;
   
   return (idx);
}

- (UIButton *)buttonForCoopIndex:(NSInteger)idx
{
   UIButton  *btn = nil;
   
   if (idx == 0)
      btn = self.coopBtn01;
   else  if (idx == 1)
      btn = self.coopBtn02;
   
   return (btn);
}

- (NSInteger)coopIndexForButton:(UIButton *)btn
{
   NSInteger  idx = -1;
   
   if (btn == self.coopBtn01)
      idx = 0;
   else  if (btn == self.coopBtn02)
      idx = 1;
   
   return (idx);
}

- (void)registerElemButtonPressed:(UIButton *)btn
{
   NSInteger  oldButtonIndex = elemsButtonIndex;
   NSInteger  newButtonIndex;
   UIButton  *oldButtonPressed = [self buttonForElemIndex:oldButtonIndex];
   
   newButtonIndex = [self elemIndexForButton:btn];
   
   if (oldButtonIndex != newButtonIndex)  {
      if (oldButtonIndex >= 0)
         [PrefsViewController swapImageForButton:oldButtonPressed];
      elemsButtonIndex = newButtonIndex;
      [PrefsViewController swapImageForButton:btn];
   }
}

- (void)registerCoopButtonPressed:(UIButton *)btn
{
   NSInteger  oldButtonIndex = coopButtonIndex;
   NSInteger  newButtonIndex;
   UIButton  *oldButtonPressed = [self buttonForCoopIndex:oldButtonIndex];
   
   newButtonIndex = [self coopIndexForButton:btn];
   
   if (oldButtonIndex != newButtonIndex)  {
      if (oldButtonIndex >= 0)
         [PrefsViewController swapImageForButton:oldButtonPressed];
      coopButtonIndex = newButtonIndex;
      [PrefsViewController swapImageForButton:btn];
   }
}

#pragma mark -

- (IBAction)pressElemButtonAction:(id)sender
{
   UIButton  *pressedButton = sender;
   
   [self registerElemButtonPressed:pressedButton];
}

- (IBAction)pressCoopButtonAction:(id)sender
{
   UIButton  *pressedButton = sender;
   
   [self registerCoopButtonPressed:pressedButton];
}

- (IBAction)playButtonAction:(id)sender
{
   gGCurPrefsRec.pfUseAcceleration    = [accelSwitch isOn];
   gGCurPrefsRec.pfShowNumbers     = [numbersSwitch isOn];
   // gGCurPrefsRec.pfShowArrow       = [arrowSwitch isOn];
   // gGCurPrefsRec.pfSideElems       = elemsSegmetCtrl.selectedSegmentIndex + 3;
   gGCurPrefsRec.pfSideElems       = elemsButtonIndex + 3;

   // gGCurPrefsRec.pfCooperationMode = self.coopSegmetCtrl.selectedSegmentIndex ? YES : NO;
   gGCurPrefsRec.pfCooperationMode = coopButtonIndex ? YES : NO;

   [self.mainViewController dismissModalPreferencesViewControllerWithImageKey:self.imageKey builtInIndex:self.builtInAlbumIndex];
}

- (IBAction)cancelButtonAction:(id)sender
{
   [self.mainViewController dismissModalPreferencesViewControllerWithImageKey:nil builtInIndex:-1];
}

#pragma mark -
#pragma mark Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch    *touch = [touches anyObject];
   NSUInteger  tapCount = [touch tapCount];
   
   if ([touch view] == self.prevImageView)
      self.touchView = self.prevImageView;
   else  if ([touch view] == self.nextImageView)
      self.touchView = self.nextImageView;
   else  if ([touch view] == self.centerImageView)  {
      self.gestureStartPoint = [[touches anyObject] locationInView:self.view];
      self.touchView = self.centerImageView;
   }
   
   if (tapCount == 2)
      self.touchView = nil;
}

/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}
*/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch *touch = [touches anyObject];

   if (([touch view] == self.prevImageView) && (self.touchView = self.prevImageView))
      [self slideToPrevImage];
   else  if (([touch view] == self.nextImageView) && (self.touchView == self.nextImageView))
      [self slideToNextImage];
   else  if (([touch view] == self.centerImageView) && (self.touchView == self.centerImageView))  {
      CGPoint  endPoint = [[touches anyObject] locationInView:self.view];
      
      if (endPoint.x > self.gestureStartPoint.x + 12.f)
         [self slideToPrevImage];
      else  if (endPoint.x < self.gestureStartPoint.x - 12.f)
         [self slideToNextImage];
   }
   
   self.touchView = nil;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   self.touchView = nil;
   self.gestureStartPoint = CGPointMake (0, 0);
}
      
#pragma mark -
      
- (void)loadSideImages
{
   NSString  *unusedImageKey;
   NSInteger  unusedIdx;
   
   self.prevImageView.image = [mainViewController prevImageForKey:self.imageKey
                                                builtInAlbumIndex:self.builtInAlbumIndex
                                                returningImageKey:&unusedImageKey
                                                 orReturningIndex:&unusedIdx];
   self.nextImageView.image = [mainViewController nextImageForKey:self.imageKey
                                                builtInAlbumIndex:self.builtInAlbumIndex
                                                returningImageKey:&unusedImageKey
                                                 orReturningIndex:&unusedIdx];
}

- (void)slideToPrevImage
{
   NSString  *tmpImageKey;
   NSInteger  tmpIdx;
   
   [self prepareGhostImageViews];
   
   self.centerImageView.image = [mainViewController prevImageForKey:self.imageKey
                                                  builtInAlbumIndex:self.builtInAlbumIndex
                                                  returningImageKey:&tmpImageKey
                                                   orReturningIndex:&tmpIdx];
   
   self.imageKey = tmpImageKey;
   self.builtInAlbumIndex = tmpIdx;
   
   [self loadSideImages];
   
   [UIView beginAnimations:@"Slide" context:nil];
   [UIView setAnimationDuration:.2];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

   [self shiftGhostImageViewsWithDirectionSign:1];

   [UIView commitAnimations];
}

- (void)slideToNextImage
{
   NSString  *tmpImageKey;
   NSInteger  tmpIdx;
   
   [self prepareGhostImageViews];
   
   self.centerImageView.image = [mainViewController nextImageForKey:self.imageKey
                                                  builtInAlbumIndex:self.builtInAlbumIndex
                                                  returningImageKey:&tmpImageKey
                                                   orReturningIndex:&tmpIdx];
   
   self.imageKey = tmpImageKey;
   self.builtInAlbumIndex = tmpIdx;
   
   [self loadSideImages];

   [UIView beginAnimations:@"Slide" context:nil];
   [UIView setAnimationDuration:.2];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
   
   [self shiftGhostImageViewsWithDirectionSign:-1];
   
   [UIView commitAnimations];
}

#pragma mark -
#pragma mark Animations

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
   // CGRect        tmpRect;
   // BOOL          finishedFlag = [finished boolValue];
   // NSUInteger       numberOfTiles = self.ourGameController.sideElements * self.ourGameController.sideElements;
   
   // if (finishedFlag)
   // NSLog (@"animationDidStop with ID: %@!", animationID);
   
   centerImageView.hidden = NO;
   prevImageView.hidden = NO;
   nextImageView.hidden = NO;
   
   [aniCenterImageView removeFromSuperview];
   [aniPrevImageView removeFromSuperview];
   [aniNextImageView removeFromSuperview];
   
   [aniCenterImageView release];  aniCenterImageView = nil;
   [aniPrevImageView release];    aniPrevImageView = nil;
   [aniNextImageView release];    aniNextImageView = nil;
}

- (void)prepareGhostImageViews
{
   aniCenterImageView = [[UIImageView alloc] initWithFrame:centerImageView.frame];
   aniCenterImageView.image = centerImageView.image;
   aniCenterImageView.contentMode = UIViewContentModeScaleAspectFit;
   
   aniPrevImageView = [[UIImageView alloc] initWithFrame:prevImageView.frame];
   aniPrevImageView.image = prevImageView.image;
   aniPrevImageView.contentMode = UIViewContentModeScaleAspectFit;
   
   aniNextImageView = [[UIImageView alloc] initWithFrame:nextImageView.frame];
   aniNextImageView.image = nextImageView.image;
   aniNextImageView.contentMode = UIViewContentModeScaleAspectFit;
   
   [self.view addSubview:aniCenterImageView];
   [self.view addSubview:aniPrevImageView];
   [self.view addSubview:aniNextImageView];
   
   centerImageView.hidden = YES;
   prevImageView.hidden = YES;
   nextImageView.hidden = YES;
}


- (void)shiftGhostImageViewsWithDirectionSign:(NSInteger)dirSign;
{
   CGRect     centerRect = centerImageView.frame;
   CGRect     prevRect   = prevImageView.frame;
   CGRect     tmpRect;

   CGFloat    distance = (centerRect.origin.x - prevRect.origin.x) * dirSign;
   
   tmpRect = CGRectOffset (aniCenterImageView.frame, distance, 0);
   aniCenterImageView.frame = tmpRect;

   tmpRect = CGRectOffset (aniPrevImageView.frame, distance, 0);
   aniPrevImageView.frame = tmpRect;

   tmpRect = CGRectOffset (aniNextImageView.frame, distance, 0);
   aniNextImageView.frame = tmpRect;
}

@end
