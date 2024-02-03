//
//  PrefsViewController.m
//  ZaSlider
//
//  Created by Igor Delovski on 22.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import  "PrefsViewController.h"
#import  "PrefsViewController+Layout.h"

#import  "ZaSliderAppDelegate.h"
#import  "CustomUISwitch.h"


@implementation PrefsViewController

@synthesize  imageView, bottomToolBar;
@synthesize  accelSwitch, numbersSwitch, /*arrowSwitch,*/ quickSettings, storeNewImagesSwitch;
@synthesize  /*elemsSegmetCtrl, coopSegmetCtrl,*/ mainViewController;
@synthesize  elemsButtonIndex , coopButtonIndex;
@synthesize  elemsBtn01, elemsBtn02, elemsBtn03, elemsBtn04, coopBtn01, coopBtn02;

- (id)initWithMainViewController:(UIViewController *)vc
                         nibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])  {
      self.mainViewController = (PrefsViewController *)vc;
      elemsButtonIndex = -1;
      coopButtonIndex = -1;
   }
   
   return (self);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   return ([self initWithMainViewController:nil nibName:nibNameOrNil bundle:nibBundleOrNil]);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // for (UIView *view in accelSwitch.subviews)
   //   [view removeFromSuperview];
   
   // Setup fields, prefs are already in memory
   
   elemsBtn01.exclusiveTouch = YES;
   elemsBtn02.exclusiveTouch = YES;
   elemsBtn03.exclusiveTouch = YES;
   elemsBtn04.exclusiveTouch = YES;
   
   coopBtn01.exclusiveTouch = YES;
   coopBtn02.exclusiveTouch = YES;
   
   accelSwitch.on   = gGPrefsRec.pfUseAcceleration;
   numbersSwitch.on = gGPrefsRec.pfShowNumbers;
   // arrowSwitch.on = gGPrefsRec.pfShowArrow;
   quickSettings.on = gGPrefsRec.pfShowSettingsBeforeGame;
   storeNewImagesSwitch.on = gGPrefsRec.pfStoreCameraImages;
   
   // elemsSegmetCtrl.selectedSegmentIndex = gGPrefsRec.pfSideElems - 3;
   // coopSegmetCtrl.selectedSegmentIndex  = gGPrefsRec.pfCooperationMode ? 1 : 0;
   
   [self registerElemButtonPressed:[self buttonForElemIndex:gGPrefsRec.pfSideElems - 3]];
   [self registerCoopButtonPressed:[self buttonForCoopIndex:gGPrefsRec.pfCooperationMode ? 1 : 0]];
}

- (void)viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   [self layoutViewComponents];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   
#ifdef _FREEMEM_
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate handleCheckMemoryWithDescription:@"PrefsViewController-viewDidAppear:" showAlert:NO];
#endif
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
   
   self.bottomToolBar = nil;
   self.accelSwitch = nil;
   self.numbersSwitch = nil;
   // self.arrowSwitch = nil;
   self.quickSettings = nil;
   self.storeNewImagesSwitch = nil;

   self.elemsBtn01 = nil;
   self.elemsBtn02 = nil;
   self.elemsBtn03 = nil;
   self.elemsBtn04 = nil;

   self.coopBtn01 = nil;
   self.coopBtn02 = nil;

   // self.elemsSegmetCtrl = nil;
   // self.coopSegmetCtrl = nil;
   
   elemsButtonIndex = -1;
   
}
*/

- (void)dealloc
{
   [imageView release];
   [bottomToolBar release];
   [accelSwitch release];
   [numbersSwitch release];
   // [arrowSwitch release];
   [quickSettings release];
   [storeNewImagesSwitch release];

   [elemsBtn01 release];
   [elemsBtn02 release];
   [elemsBtn03 release];
   [elemsBtn04 release];

   [coopBtn01 release];
   [coopBtn02 release];

   // [elemsSegmetCtrl release];
   // [coopSegmetCtrl release];
   [mainViewController release];
   
   [super dealloc];
}

#pragma mark -

+ (void)swapImageForButton:(UIButton *)btn
{
   UIImage   *dfltImg = [btn imageForState:UIControlStateNormal];
   UIImage   *highImg = [btn imageForState:UIControlStateHighlighted];
   
   [btn setImage:highImg forState:UIControlStateNormal];
   [btn setImage:dfltImg forState:UIControlStateHighlighted];
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

#pragma mark -

- (void)registerElemButtonPressed:(UIButton *)btn
{
   NSInteger  oldButtonIndex = elemsButtonIndex;
   NSInteger  newButtonIndex;
   UIButton  *oldButtonPressed = [self buttonForElemIndex:oldButtonIndex];
   
   newButtonIndex = [self elemIndexForButton:btn];
   
   if (oldButtonIndex != newButtonIndex)  {
      if (oldButtonIndex >= 0)
         [[self class] swapImageForButton:oldButtonPressed];
      elemsButtonIndex = newButtonIndex;
      [[self class] swapImageForButton:btn];
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
         [[self class] swapImageForButton:oldButtonPressed];
      coopButtonIndex = newButtonIndex;
      [[self class] swapImageForButton:btn];
   }
}

- (IBAction)pressButtonAction:(id)sender
{
   UIButton  *pressedButton = sender;
   
   [self registerElemButtonPressed:pressedButton];
}

- (IBAction)pressCoopButtonAction:(id)sender
{
   UIButton  *pressedButton = sender;
   
   [self registerCoopButtonPressed:pressedButton];
}

#pragma mark -

- (IBAction)doneButtonAction:(id)sender
{
   // Store prefs
   
   gGPrefsRec.pfUseAcceleration = [accelSwitch isOn];
   gGPrefsRec.pfShowNumbers     = [numbersSwitch isOn];
   // gGPrefsRec.pfShowArrow       = [arrowSwitch isOn];
   
   gGPrefsRec.pfShowSettingsBeforeGame = [quickSettings isOn];
   gGPrefsRec.pfStoreCameraImages = [storeNewImagesSwitch isOn];
   
   // gGPrefsRec.pfSideElems       = elemsSegmetCtrl.selectedSegmentIndex + 3;
   // gGPrefsRec.pfCooperationMode = coopSegmetCtrl.selectedSegmentIndex ? YES : NO;

   gGPrefsRec.pfSideElems       = elemsButtonIndex + 3;
   gGPrefsRec.pfCooperationMode = coopButtonIndex ? YES : NO;

   
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate savePreferences];
   
   // Animation
   
   [UIView beginAnimations:@"BackViewFlip" context:nil];
   [UIView setAnimationDuration:1.25];
   [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(animationHasFinished:finished:context:)];

   UIViewController          *coming = nil;
   UIViewController          *going = nil;
   UIViewAnimationTransition  trans;
   
   coming = mainViewController;
   going  = self;
   trans = UIViewAnimationTransitionFlipFromRight;
   
   [UIView setAnimationTransition:trans forView:mainViewController.view cache:YES];
   
   [coming viewWillAppear:YES];
   [going  viewWillDisappear:YES];
   
   [going.view removeFromSuperview];
   
   [going  viewDidDisappear:YES];
   [coming viewDidAppear:YES];
   
   [UIView commitAnimations];
}

- (void)animationHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
   NSLog (@"animationHasFinished:finished:_hitCount:context:");
   
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate removeBackgroundImage];
}

@end
