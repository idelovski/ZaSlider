//
//  dTOOLiOS_Basic
//
//  Created by Igor Delovski on 14.01.2024
//  Copyright (c) 2024 Delovski d.o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

// #import "dTOOLiOS_Core.h"

#define  CGRectWithSize  CGRectOfSize


// -----------------------------------------------------------------------------------------------

@interface DToolBasic : NSObject

+ (UIEdgeInsets)edgeInsetsForView:(UIView *)theView;

@end


CGRect  CGRectOfSize (CGSize recSize);
