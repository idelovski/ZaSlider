//
//  HistDetailViewController.m
//  ZaSlider
//
//  Created by Igor Delovski on 13.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "HistDetailViewController.h"
#import "ZaSliderViewController.h"

#import "GameHistory.h"


@implementation HistDetailViewController

@synthesize  backImageView, pictImageView;
@synthesize  pictDescription, playDateDescription, playTimeDescription, oponentDescription;
@synthesize  mainViewController, theGameHistory;

- (id)initWithMainViewController:(UIViewController *)vc
                    gameHistory:(GameHistory *)gh
                         nibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])  {
      self.theGameHistory = gh;
      self.mainViewController = (ZaSliderViewController *)vc;
   }
   
   return (self);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    // Custom initialization
   }
   
   return (self);
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   if (!self.navigationItem.rightBarButtonItem)  {
      
      UIBarButtonItem  *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Mail"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(mailImageAction)];
      
      self.navigationItem.rightBarButtonItem = barButton;
      [barButton release];

   }
   MediaItem    *tmpMediaItem = [mainViewController mediaItemForImageKey:self.theGameHistory.imageKey
                                                          orBuiltInIndex:self.theGameHistory.builtInAlbumIndex];
   
   UIImage  *tmpImage = [mainViewController imageForImageKey:self.theGameHistory.imageKey
                                              orBuiltInIndex:theGameHistory.builtInAlbumIndex];
   
   self.pictImageView.image = tmpImage;
   

   if (!self.theGameHistory.imageKey)
      pictDescription.text = @"From the built in album";
   else  if (tmpMediaItem.creationDate)  {
      NSDateFormatter  *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
      [dateFormatter setDateStyle:NSDateFormatterLongStyle];
      NSString  *dateStr = [dateFormatter stringFromDate:tmpMediaItem.creationDate];
      pictDescription.text = [NSString stringWithFormat:@"Source: %@ on %@", tmpMediaItem.imgSource, dateStr];
      [dateFormatter release];
   }
   else
      pictDescription.text = @"Unknown date";

   
   if (self.theGameHistory.playingDate)  {
      NSDateFormatter  *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
      [dateFormatter setDateStyle:NSDateFormatterLongStyle];
      NSString  *dateStr = [dateFormatter stringFromDate:self.theGameHistory.playingDate];
      playDateDescription.text = [NSString stringWithFormat:@"Played on %@", dateStr];
      [dateFormatter release];
   }
   else
      playDateDescription.text = @"Unknown date";
   
   NSString  *timeStr = [GameHistory secondsToString:self.theGameHistory.weFinishedInSeconds withDescription:YES];

   playTimeDescription.text = timeStr;
   
   if (self.theGameHistory.opponentName)  {
      NSString  *tmpStr = self.theGameHistory.coopMode ? @"With" : @"Against";
      oponentDescription.text = [NSString stringWithFormat:@"%@ %@", tmpStr, self.theGameHistory.opponentName];
   }
   else  {
      oponentDescription.text = @"";
      // oponentDescription.text = [NSString stringWithFormat:@"Size: %.0f x %.0f", tmpImage.size.width, tmpImage.size.height];
   }
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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{
   [backImageView release];
   [pictImageView release];
   [pictDescription release];
   [playDateDescription release];
   [playTimeDescription release];
   [oponentDescription release];

   [theGameHistory release];
   [mainViewController release];
   
   [super dealloc];
}

#pragma mark -

- (IBAction)mailImageAction
{
   [self mailImage];
}

- (IBAction)replayAction;
{
   [self.mainViewController navigateBackToMainViewController:self.theGameHistory];
}

#pragma mark -
#pragma mark Mail handling

- (void)mailImage
{
   NSLog (@"mailImage");
   if (![MFMailComposeViewController canSendMail])  {
      NSLog (@"Can't mail image!");
      return;
   }
   
   UIImage  *tmpImage = [mainViewController imageForImageKey:self.theGameHistory.imageKey
                                              orBuiltInIndex:theGameHistory.builtInAlbumIndex];
   NSString *imgTitle = [NSString stringWithFormat:@"%@", pictDescription.text];
   
   MFMailComposeViewController  *mailComposer = [[MFMailComposeViewController alloc] init];
   
   mailComposer.mailComposeDelegate = self;
   [mailComposer setSubject:@"WiSlide game picture"];
   [mailComposer addAttachmentData:UIImageJPEGRepresentation(tmpImage, 0.75)
                          mimeType:@"image/jpg"
                          fileName:[NSString stringWithFormat:@"%@.jpg", imgTitle]];
   
   [mailComposer setMessageBody:@"A picture from the game." isHTML:NO];
   
   [self presentModalViewController:mailComposer animated:NO];
   [mailComposer release];
}

// Mail Compose Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
   NSLog (@"mailComposeController:didFinishWithResult:error:");
   
   UIAlertView  *alert;
   
   switch (result)  {
      case  MFMailComposeResultCancelled:
         NSLog (@"Canceled...");
         break;
      case  MFMailComposeResultSaved:
         NSLog (@"Saved for later...");
         break;
      case  MFMailComposeResultSent:
         NSLog (@"Sent...");
         break;
      case  MFMailComposeResultFailed:
         NSLog (@"Failed...");
         
         alert = [[UIAlertView alloc] initWithTitle:@"Error sending mail..."
                                            message:[error localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
         [alert show];
         [alert release];
         break;
      default:
         break;
   }
   [self dismissModalViewControllerAnimated:YES];
}

@end
