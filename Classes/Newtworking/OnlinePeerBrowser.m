//
//  OnlinePeerBrowser.m
//  Slider
//
//  Created by Igor Delovski on 13.08.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "OnlinePeerBrowser.h"

#import "NetworkingController.h"
// #import "ZaSliderViewController.h"


@implementation OnlinePeerBrowser

@synthesize  label01, label02, label03, label04, button01, button02, button03, button04;
@synthesize  netServiceBrowser, discoveredServices, netController, actIndicatorView;

#pragma mark -

- (id)initWithNetworkingController:(NetworkingController *)nc
                           nibName:(NSString *)nibNameOrNil
                            bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])  {
      self.netController = nc;
   }
   
   return (self);
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   return ([self initWithNetworkingController:nil nibName:nibNameOrNil bundle:nibBundleOrNil]);
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   NSLog (@"viewDidLoad - OnlinePeerBrowser");

   [super viewDidLoad];
   
   NSNetServiceBrowser  *theBrowser = [[NSNetServiceBrowser alloc] init];
   theBrowser.delegate = self;
   
   [theBrowser searchForServicesOfType:kBonjourType inDomain:@""];
   self.netServiceBrowser = theBrowser;
   [theBrowser release];
   
   self.discoveredServices = [NSMutableArray array];

   UIActivityIndicatorView  *tmpActIndicator = [[UIActivityIndicatorView alloc]
                                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
   
   self.actIndicatorView = tmpActIndicator;
   
   [tmpActIndicator release];
   
   self.actIndicatorView.hidden = NO;
   
   CGPoint  viewCenter = self.view.center;
   viewCenter.y += 2 * (viewCenter.y / 5);
   self.actIndicatorView.center = viewCenter;
   
   [self.view addSubview:self.actIndicatorView];
   [self.actIndicatorView startAnimating];
   
   [self reloadData];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
   self.label01 = nil;
   self.label02 = nil;
   self.label03 = nil;
   self.label04 = nil;
   
   self.button01 = nil;
   self.button02 = nil;
   self.button03 = nil;
   self.button04 = nil;
}
*/

- (void)dealloc
{
   if (self.netServiceBrowser)  {
      [self.netServiceBrowser stop];
      self.netServiceBrowser.delegate = nil;
      [self.netServiceBrowser release];
   }
   
   [label01 release];
   [label02 release];
   [label03 release];
   [label04 release];

   [button01 release];
   [button02 release];
   [button03 release];
   [button04 release];

   [discoveredServices release];
   [netController release];
   [actIndicatorView release];
   
   [super dealloc];
}

#pragma mark -

- (void)reloadData
{
   NSInteger  rows = [self.discoveredServices count];
   
   self.label01.text = (rows > 0) ? [[self.discoveredServices objectAtIndex:0] name] : @"Searching...";
   self.label02.text = (rows > 1) ? [[self.discoveredServices objectAtIndex:1] name] : @"";
   self.label03.text = (rows > 2) ? [[self.discoveredServices objectAtIndex:2] name] : @"";
   self.label04.text = (rows > 3) ? [[self.discoveredServices objectAtIndex:3] name] : @"";
}

- (void)didSelectRow:(NSInteger)theRow
{
   if (!self.discoveredServices || theRow >= [self.discoveredServices count])
      return;

   NSNetService  *selectedService = [self.discoveredServices objectAtIndex:theRow];
   
   // Create NetworkingController class that will handle this shit!
   
   // ZaSliderViewController  *parentVC = (ZaSliderViewController *)self.parentViewController;
   
   selectedService.delegate = self.netController; // was: parentVC.netController;
   [selectedService resolveWithTimeout:0.];
   
   self.netController.foundNetService = selectedService;

   [self.netServiceBrowser stop];
   
   [self.parentViewController dismissModalViewControllerAnimated:NO];  // was YES
}

#pragma mark -
#pragma mark NSNetServiceBrowserDelegateMethods
#pragma mark -

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
   self.netServiceBrowser.delegate = nil;
   self.netServiceBrowser = nil;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
   NSLog (@"Error browsing for services: %@!", [errorDict objectForKey:NSNetServicesErrorCode]);
   [self.netServiceBrowser stop];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
   NSString  *parentName = [self.netController.publishedNetService name];
   // NSString                 *parentName = [[UIDevice currentDevice] name];
   
   NSLog (@"netServiceBrowser:didFindService:(%@)moreComing: - parentName:%@", [aNetService name], parentName);

   if (![[aNetService name] isEqualToString:parentName])  {
      NSLog (@"Not equal!");
      [discoveredServices addObject:aNetService];
      
      NSSortDescriptor  *sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
      
      [discoveredServices sortUsingDescriptors:[NSArray arrayWithObject:sd]];
      [sd release];

      if (!moreComing)
         [self reloadData];
      if (self.actIndicatorView)  {
         [self.actIndicatorView stopAnimating];
         [self.actIndicatorView removeFromSuperview];
         self.actIndicatorView = nil;
      }
   }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
   [discoveredServices removeObject:aNetService];
   
   if (!moreComing)
      [self reloadData];
}   

#pragma mark -
#pragma mark IBAction
#pragma mark -

- (IBAction)peerNameButtonPressed:(id)sender
{
   UIButton  *theButton = (UIButton *)sender;
   
   if (theButton == self.button01)
      [self didSelectRow:0];
   else  if (theButton == self.button02)
      [self didSelectRow:1];
   else  if (theButton == self.button03)
      [self didSelectRow:2];
   else  if (theButton == self.button04)
      [self didSelectRow:3];
}

- (IBAction)cancel
{
   [self.netServiceBrowser stop];
   self.netServiceBrowser.delegate = nil;
   
   self.netServiceBrowser = nil;
   
   [self.netController browserCancelled];
}

@end
