//
//  ZaSliderAppDelegate.m
//  ZaSlider
//
//  Created by Igor Delovski on 15.09.2010.
//  Copyright Igor Delovski, Delovski d.o.o. 2010. All rights reserved.
//

#import  "dTOOLiOS_Basic.h"

#import  "ZaSliderAppDelegate.h"
#import  "ZaSliderViewController.h"


PreferenceRecord  gGCurPrefsRec;

PreferenceRecord  gGPrefsRec = {
   .pfUseAcceleration = YES,
   .pfShowNumbers = YES,
   // .pfShowArrow=YES,
   .pfCooperationMode = NO,
   .pfShowSettingsBeforeGame = NO,
   .pfStoreCameraImages = NO,
   .pfSideElems = 3
};


@implementation  ZaSliderAppDelegate

@synthesize  window, viewController, navController, backImageView;
@synthesize  appInForeground, edgeInsets;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
   
   // self.edgeInsets = UIEdgeInsetsZero;  // here, later initialized properly
   self.edgeInsets = [DToolBasic edgeInsetsForView:self.window];  // Maybe earlier?
   
   [self readPreferences];
   
   // Override point for customization after app launch    
   navController = [[UINavigationController alloc] initWithRootViewController:viewController];

   self.navController.navigationBar.barStyle = UIBarStyleBlack;
   self.navController.navigationBar.translucent = YES;
   
   self.navController.delegate = viewController;
   
   [self.navController setNavigationBarHidden:YES animated:NO];
   
   [self.window setRootViewController:self.navController];  // was self.viewController
   
   [self.window addSubview:self.navController.view];
   // [self putBackgroundImage];
   [self.window makeKeyAndVisible];
   
   // [self.window setRootViewController:self.navController];  // TOO LATE
   
   appInForeground = NO;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
   if (self.backImageView && self.backImageView.superview)
      [self.backImageView removeFromSuperview];
   
   self.backImageView = nil;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   UIApplication    *app   = [UIApplication sharedApplication];

   NSLog (@"applicationWillTerminate.");

   if (app.isIdleTimerDisabled)      // Maybe we should do something about this when we go to background
      app.idleTimerDisabled = NO;

   if (appInForeground)
      NSLog (@"Home or memory warning. Save and bail.");
   else
      NSLog (@"Moved to the background at some point. Save and bail.");

   [viewController handleTermination];
   NSLog (@"OK, terminating...");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   NSLog (@"Moving to the foreground.");
   appInForeground = YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
   NSLog (@"Moving to the background.");
   appInForeground = NO;
}

// Plus, there is UIApplicationWillChangeStatusBarFrameNotification

// See Missing-187, changing bounds of a view can scale it!

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
   NSLog (@"application:willChangeStatusBarFrame:");
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
   NSLog (@"application:didChangeStatusBarFrame:");
}

- (void)dealloc
{
   [viewController release];
   [navController release];
   [backImageView release];
   [window release];
   
   [super dealloc];
}

#pragma mark -

- (void)putBackgroundImage
{
   if (!self.backImageView)  {
      CGRect  applicationFrame = [[UIScreen mainScreen] applicationFrame];
   
      UIImage      *backgroundImage = [UIImage imageNamed:@"Default.png"];
      UIImageView  *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
      imageView.frame = applicationFrame;
   
      self.backImageView = imageView;
      [imageView release];
   }
   
   if (!self.backImageView.superview)
      [window insertSubview:self.backImageView belowSubview:self.navController.view];
   
   [window sendSubviewToBack:self.backImageView];  // Somehow needed on newer OSes
}

- (void)removeBackgroundImage
{
   if (self.backImageView && self.backImageView.superview)
      [self.backImageView removeFromSuperview];
}

#pragma mark -
#pragma mark Prefs
#pragma mark -

- (void)readPreferences
{
   gGPrefsRec.pfUseAcceleration = [FileHelper getUserDefaultsBoolForKey:kUDUseAccelerometerKey
                                                            withDefault:YES];
   
   gGPrefsRec.pfShowNumbers = [FileHelper getUserDefaultsBoolForKey:kUDShowNumbersKey
                                                        withDefault:YES];

   // gGPrefsRec.pfShowArrow   = [FileHelper getUserDefaultsBoolForKey:kUDShowArrowKey
   //                                                      withDefault:YES];
   
   gGPrefsRec.pfCooperationMode = [FileHelper getUserDefaultsBoolForKey:kUDCoopModeKey
                                                            withDefault:NO];
   
   gGPrefsRec.pfShowSettingsBeforeGame = [FileHelper getUserDefaultsBoolForKey:kUDShowSettingsKey
                                                                   withDefault:NO];

   gGPrefsRec.pfStoreCameraImages = [FileHelper getUserDefaultsBoolForKey:kUDStoreNewImagesKey
                                                              withDefault:NO];
   
   gGPrefsRec.pfSideElems = [FileHelper getUserDefaultsIntegerForKey:kUDSideElemsKey withDefault:3];
   if (gGPrefsRec.pfSideElems < 3 || gGPrefsRec.pfSideElems > 6)
      gGPrefsRec.pfSideElems = 3;
   
   memmove (&gGCurPrefsRec, &gGPrefsRec, sizeof(PreferenceRecord));
}

- (void)savePreferences
{
   [FileHelper setUserDefaultsBool:gGPrefsRec.pfUseAcceleration forKey:kUDUseAccelerometerKey];
   [FileHelper setUserDefaultsBool:gGPrefsRec.pfShowNumbers forKey:kUDShowNumbersKey];
   // [FileHelper setUserDefaultsBool:gGPrefsRec.pfShowArrow forKey:kUDShowArrowKey];
   
   [FileHelper setUserDefaultsBool:gGPrefsRec.pfCooperationMode forKey:kUDCoopModeKey];
   [FileHelper setUserDefaultsBool:gGPrefsRec.pfShowSettingsBeforeGame forKey:kUDShowSettingsKey];
   [FileHelper setUserDefaultsBool:gGPrefsRec.pfStoreCameraImages forKey:kUDStoreNewImagesKey];
   
   [FileHelper setUserDefaultsInteger:gGPrefsRec.pfSideElems forKey:kUDSideElemsKey];

   memmove (&gGCurPrefsRec, &gGPrefsRec, sizeof(PreferenceRecord));
}

#pragma mark -
#pragma mark system memory query methods

+ (vm_statistics_data_t)retrieveSystemMemoryStats
{
   mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
   
   vm_statistics_data_t vmstat;
   host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count); 
   
   return (vmstat);
}

+ (int)calcSystemPageSize
{
   size_t length;
   int    mib[6];
   int    pagesize;
   
   mib[0] = CTL_HW;
   mib[1] = HW_PAGESIZE;
   
   length = sizeof (pagesize);
   sysctl (mib, 2, &pagesize, &length, NULL, 0);
   
   return (pagesize);
} 

+ (int)calcSystemAvailableMemoryInMB
{
   int                   pagesize = [self calcSystemPageSize];
   vm_statistics_data_t  vmstat = [self retrieveSystemMemoryStats];
   
   return ((vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count) * pagesize) / 0x100000;
}

+(int)calcSystemRemainingMemoryInMB
{ 
   int                   pagesize = [self calcSystemPageSize]; 
   vm_statistics_data_t  vmstat = [self retrieveSystemMemoryStats]; 
   
   return ((vmstat.free_count * pagesize) / 0x100000);
}

+ (int)calcSystemPercentFreeMemory
{
   vm_statistics_data_t vmstat = [self retrieveSystemMemoryStats]; 
   double               total = vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count; 
   double               free  = vmstat.free_count / total;
   
   return (int)(free * 100.0);
} 

+ (BOOL)doWeHaveEnoughFreeMemory:(int)numOfBytesRequested
{
   int                   pagesize = [self calcSystemPageSize]; 
   vm_statistics_data_t  vmstat = [self retrieveSystemMemoryStats]; 
   
   if ((vmstat.free_count * pagesize) > numOfBytesRequested)  { 
      return (YES);
   }
   else  {
      return (NO);
   }
}

// It then uses these to display in log messages or alerts as follows: 
/** 
 CHAPTER 5:  AccuTerra 
 76 
 * This method handles Check Memory view 
 */ 
- (void)handleCheckMemoryWithDescription:(NSString *)callerDesc showAlert:(BOOL)showAlertFlag
{
   if (showAlertFlag)
      NSLog (@"handleCheckMemoryWithAlert:");
   
   int  availMem = [[self class] calcSystemAvailableMemoryInMB];
   int  remainMem = [[self class] calcSystemRemainingMemoryInMB];
   int  percentFreeMem = [[self class] calcSystemPercentFreeMemory];
   
   NSString  *memStr = [[NSString alloc] initWithFormat:@"(%@) Total Available:%dMB\nAmount Remaining: %dMB\nPercent Free of Total: %d%%",
                        callerDesc, availMem, remainMem, percentFreeMem];
   NSString  *msg;
   
   if (remainMem < 5)
      msg = [[NSString alloc] initWithFormat:@"Low memory!\n%@", memStr];
   else if (remainMem < 15)
      msg = [[NSString alloc] initWithFormat:@"Average memory.\n%@", memStr];
   else
      msg = [[NSString alloc] initWithFormat:@"High memory.\n%@", memStr];
   // NSLog (msg);
   
   // Debug development team detailed low memory message.
   if (showAlertFlag)  {
      UIAlertView *memalert = [[UIAlertView alloc] initWithTitle:@"Current Memory" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
   
      [memalert show];
      [memalert release];
   }
   else
      NSLog (@"handleCheckMemoryWithAlert: %@", msg);
   [memStr release];
   [msg release];
}

@end
