//
//  ZaSliderAppDelegate.h
//  ZaSlider
//
//  Created by Igor Delovski on 15.09.2010.
//  Copyright Igor Delovski, Delovski d.o.o. 2010. All rights reserved.
//

#import <mach/mach_host.h>
#import <sys/sysctl.h>

#import <UIKit/UIKit.h>

@class ZaSliderViewController;

@interface ZaSliderAppDelegate : NSObject <UIApplicationDelegate> {
   UIWindow                *window;
   ZaSliderViewController  *viewController;
   UINavigationController  *navController;
   
   UIImageView             *backImageView;
   
   BOOL                     appInForeground;
}

@property (nonatomic, retain) IBOutlet UIWindow                *window;
@property (nonatomic, retain) IBOutlet ZaSliderViewController  *viewController;
@property (nonatomic, retain)          UINavigationController  *navController;
@property (nonatomic, retain)          UIImageView             *backImageView;

@property (readonly)                   BOOL                     appInForeground;

@property (assign, nonatomic)          UIEdgeInsets             edgeInsets;


- (void)readPreferences;
- (void)savePreferences;

- (void)putBackgroundImage;
- (void)removeBackgroundImage;

#pragma mark -

+ (vm_statistics_data_t)retrieveSystemMemoryStats;
+ (int)calcSystemPageSize;
+ (int)calcSystemAvailableMemoryInMB;
+ (int)calcSystemRemainingMemoryInMB;
+ (int)calcSystemPercentFreeMemory;
+ (BOOL)doWeHaveEnoughFreeMemory:(int)numOfBytesRequested;

- (void)handleCheckMemoryWithDescription:(NSString *)callerDesc showAlert:(BOOL)showAlertFlag;

@end

