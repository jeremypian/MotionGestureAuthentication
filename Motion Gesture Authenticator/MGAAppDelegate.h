//
//  MGAAppDelegate.h
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 2/16/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface MGAAppDelegate : UIResponder <UIApplicationDelegate> {
    CMMotionManager *motionManager;
}
@property (readonly) CMMotionManager *motionManager;
@property (strong, nonatomic) UIWindow *window;

@end
