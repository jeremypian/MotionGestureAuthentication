//
//  MGAViewController.h
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 2/16/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGAViewController : UIViewController <UITextFieldDelegate, UIAccelerometerDelegate>
@property (weak, nonatomic) IBOutlet UIView *statusLight;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (copy, nonatomic) NSString *userName;
@property (nonatomic) NSMutableArray *accelerationPoints;
@property (nonatomic) BOOL startStopButtonIsActive;
- (IBAction)changeGreeting:(id)sender;
@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;

@end
/*
@interface AccelerationPoint : NSObject
@property float x; // If you're using char c, why not use int a?
@property float y; // If you're using char c, why not use int a?
@property float z; // If you're using char c, why not use int a?
@end*/