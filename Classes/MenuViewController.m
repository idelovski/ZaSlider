//
//  MenuViewController.m
//  ZaSlider
//
//  Created by Igor Mini on 27.12.2010..
//  Copyright 2010 Delovski d.o.o. All rights reserved.
//

#import  "MenuViewController.h"
#import  "MenuViewController+Layout.h"

#import  "ZaSliderViewController.h"

@implementation MenuViewController

@synthesize  mainViewController, imageView;
@synthesize  startButton, historyButton, prefsButton, addPhotoButton, netSearchButton, helpButton;

- (id)initWithMainViewController:(UIViewController *)vc
{
   if (self = [super initWithNibName:@"MenuViewController" bundle:nil])  {
      self.mainViewController = (ZaSliderViewController *)vc;
   }
	
   return (self);
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   [self layoutViewComponents];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

/*
- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
*/

- (void)dealloc
{
	[mainViewController release];
	[imageView release];
	[startButton release];
	[historyButton release];
	[prefsButton release];
	[addPhotoButton release];
	[netSearchButton release];
	[helpButton release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Actions
#pragma mark -

// mainViewControler is in fact a ZaSliderViewController

- (IBAction)startButtonAction:(id)sender
{
	[self.mainViewController startButtonAction:sender];
}

- (IBAction)addNewPhoto:(id)sender
{
	[self.mainViewController addNewPhoto:sender];
}

- (IBAction)historyButtonAction:(id)sender
{
	[self.mainViewController historyButtonAction:sender];
}

- (IBAction)startNetworkedPlayAction:(id)sender
{
	[self.mainViewController startNetworkedPlayAction:sender];
}

- (IBAction)prefsButtonAction:(id)sender
{
	[self.mainViewController prefsButtonAction:sender];
}

- (IBAction)helpButtonAction:(id)sender
{
	[self.mainViewController helpButtonAction:self];    // must be VC as param
}

@end
