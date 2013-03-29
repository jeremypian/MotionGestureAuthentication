//
//  MGAViewController.m
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 2/16/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import "MGAViewController.h"
#import "MGAKeySignature.h"
#import <CoreMotion/CoreMotion.h>

@interface MGAViewController ()

@end

@implementation MGAViewController
@synthesize startStopButtonIsActive;
@synthesize recordButtonIsActive;
@synthesize recordedMotion;
@synthesize accelerationPoints;
@synthesize isAuthenticated;
@synthesize isRecorded;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.statusLabel setText:@"Stopped"];
    [self.statusLabel setBackgroundColor:[UIColor blueColor]];
    
    self.startStopButtonIsActive = NO;
    self.recordButtonIsActive = NO;
    
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    samplingInterval = 0.01;
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.delegate = self;
    [self.accelerometer setUpdateInterval:samplingInterval];
    
    self.isAuthenticated = NO;
    self.accelerationPoints = [[NSMutableArray alloc] init];
    self.recordedMotion = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordMotion:(id)sender {
    if(self.recordButtonIsActive == YES){
        self.recordButtonIsActive = NO;
        self.isRecorded = YES;
        [self.recordBtn setTitle:@"Re-record Motion" forState:UIControlStateNormal];
        [self.statusLabel setText:@"RECORDED"];
        [self.statusLabel setBackgroundColor:[UIColor blueColor]];
        //NSLog(@"RECORDED MOTION: %@", self.recordedMotion);
        NSLog(@"Motion Recorded");
    }
    else{

        // Delete the recorded points before starting fresh
        // Should appear before setting startStopButtonIsActive to True or we might have race conditions
        [self.recordedMotion removeAllObjects];
        self.recordButtonIsActive = YES;
        self.isRecorded = NO;
        [self.statusLabel setText:@"Recording motion..."];
        [self.statusLabel setBackgroundColor:[UIColor brownColor]];
        [self.recordBtn setTitle:@"Recording..." forState:UIControlStateNormal];
        //NSLog(@"RECORDED MOTION: %@", self.recordedMotion);
        
        
        NSLog(@"Started Recording Motion");
    }
}

- (IBAction)startAuthentication:(id)sender {
    if (!self.isRecorded) {
        return;
    }
    if(self.startStopButtonIsActive == YES){
        self.startStopButtonIsActive = NO;
        //NSLog(@"RECORDED MOTION: %@", self.recordedMotion);
        MGAKeySignature* sig = [[MGAKeySignature alloc] initWithAccelerationPoints:self.accelerationPoints AndRecordedMotion:self.recordedMotion AndSamplingInterval:samplingInterval];
        isAuthenticated = [sig authenticate];
        if(isAuthenticated){
            [self.statusLabel setText:@"Authenticated"];
            [self.statusLabel setBackgroundColor:[UIColor greenColor]];
        }
        else {
            [self.statusLabel setText:@"Imposter!"];
            [self.statusLabel setBackgroundColor:[UIColor redColor]];
        }
        
        [self.startStopBtn setTitle:@"Start Authentication" forState:UIControlStateNormal];

        NSLog(@"Stopped Recording");
    }
    else{
        [self.statusLabel setText:@"Authenticating motion"];
        [self.statusLabel setBackgroundColor:[UIColor blueColor]];

        // Delete the recorded points before starting fresh
        // Should appear before setting startStopButtonIsActive to True or we might have race conditions
        [self.accelerationPointsX removeAllObjects];
        [self.accelerationPointsY removeAllObjects];
        [self.accelerationPointsZ removeAllObjects];

        self.startStopButtonIsActive = YES;
        isAuthenticated = NO;
        [self.startStopBtn setTitle:@"Stop" forState:UIControlStateNormal];
        
        NSLog(@"Started Recording");
    }
    

}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if(self.startStopButtonIsActive){
        // Filter out noise
        float a_x = acceleration.x;
        float a_y = acceleration.y;
        
        // Invert accelerometer axes.
        a_x = -1.0 * a_x;
        a_y = -1.0 * a_y - 1;
        NSNumber* x = [NSNumber numberWithFloat:a_x];
        //NSLog(@"%@", x);
        [self.accelerationPoints addObject:x];
    } else if (self.recordButtonIsActive){
        // Filter out noise
        float a_x = fabsf(acceleration.x) >= 0.0 ? acceleration.x : 0.0;
        // Invert accelerometer axes.
        a_x = -1.0 * a_x;
        NSNumber* x = [NSNumber numberWithFloat:a_x];
        NSLog(@"%@", x);
        [self.recordedMotion addObject:x];
    }
}


@end
