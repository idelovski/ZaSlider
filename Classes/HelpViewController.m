//
//  HelpViewController.m
//  ZaSlider
//
//  Created by Igor Delovski on 08.04.2011.
//  Copyright 2011 Igor Delovski, Delovski d.o.o. All rights reserved.
//

#import  "HelpViewController.h"
#import  "HelpViewController+Layout.h"


@implementation HelpViewController

@synthesize  scrollView, imgView, bottomToolBar;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

#define  kExtraHeight  24.f

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   NSString  *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
   
   CGSize  imgSize = imgView.frame.size;
   CGRect  bottomRect = CGRectMake (0.f, imgSize.height-(2.f*kExtraHeight)-6.f, 320.f, kExtraHeight);
   
   imgSize.height += kExtraHeight;
   
   self.scrollView.contentSize = imgSize;

   UILabel  *nameLabel = [[UILabel alloc] initWithFrame:bottomRect];
   
   // nameLabel.font = [UIFont systemFontOfSize:13.f];
   nameLabel.font = [UIFont fontWithName:@"helvetica" size:12.5f];
   nameLabel.backgroundColor = [UIColor clearColor];
   nameLabel.textColor = [UIColor colorWithRed:(0x7B / 255.) green:.0f blue:.0f alpha:1.f];
   nameLabel.textAlignment = NSTextAlignmentCenter;
   
   nameLabel.text = [NSString stringWithFormat:@"Version %@", versionStr];
   
   [self.scrollView addSubview:nameLabel];
   
   [nameLabel release];
}

- (void)viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   [self layoutViewComponents];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
   [scrollView release];
   [imgView release];
   [bottomToolBar release];

   [super dealloc];
}

#pragma mark -

- (IBAction)closeHelpView
{
   [self /*.parentViewController*/ dismissModalViewControllerAnimated:YES];
}

@end
