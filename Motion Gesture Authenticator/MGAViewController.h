//
//  MGAViewController.h
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 2/16/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGAViewController : UIViewController <UIAccelerometerDelegate>{
    BOOL isAuthenticated;
    float samplingInterval;
}
@property (nonatomic) BOOL isAuthenticated;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) BOOL startStopButtonIsActive;
@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;
@property (nonatomic) NSMutableArray *accelerationPointsX;
@property (nonatomic) NSMutableArray *accelerationPointsY;
@property (nonatomic) NSMutableArray *accelerationPointsZ;


- (IBAction)startAuthentication:(id)sender;

@end
/*
@interface AccelerationPoint : NSObject
@property float x; // If you're using char c, why not use int a?
@property float y; // If you're using char c, why not use int a?
@property float z; // If you're using char c, why not use int a?
@end*/