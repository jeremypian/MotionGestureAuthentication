//
//  MGAViewController.m
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 2/16/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import "MGAAppDelegate.h"
#import "MGAViewController.h"
#import "MGAKeySignature.h"
#import <CoreMotion/CoreMotion.h>

@interface MGAViewController ()

@end

@implementation MGAViewController
@synthesize startStopButtonIsActive;
@synthesize recordButtonIsActive;
@synthesize recordedMotionX;
@synthesize recordedMotionY;
@synthesize recordedMotionZ;
@synthesize accelerationPointsX;
@synthesize accelerationPointsY;
@synthesize accelerationPointsZ;
@synthesize isAuthenticated;
@synthesize isRecorded;
@synthesize securitySliderValue;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.statusLabel setText:@"Stopped"];
    [self.statusLabel setBackgroundColor:[UIColor blueColor]];
    
    self.startStopButtonIsActive = NO;

    samplingInterval = 0.01;
    self.recordButtonIsActive = NO;
    
    // Use this for UserAcceleration
    //[self startUpdates];
    
    // Use this for raw acceleration data
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.delegate = self;
    [self.accelerometer setUpdateInterval:samplingInterval];
    
    self.isAuthenticated = NO;
    
    self.accelerationPointsY = [[NSMutableArray alloc] init];
    self.accelerationPointsX = [[NSMutableArray alloc] init];
    self.accelerationPointsZ = [[NSMutableArray alloc] init];

    self.recordedMotionX = [[NSMutableArray alloc] init];
    self.recordedMotionY = [[NSMutableArray alloc] init];
    self.recordedMotionZ = [[NSMutableArray alloc] init];
    securitySliderValue = 0.5*5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)updateSliderValue:(UISlider *)sender {
    securitySliderValue = sender.value * 5;
}

- (IBAction)recordMotion:(id)sender {
    if(self.recordButtonIsActive == YES){
        self.recordButtonIsActive = NO;
        self.isRecorded = YES;
        [self.recordBtn setTitle:@"Re-record Motion" forState:UIControlStateNormal];
        [self.statusLabel setText:@"RECORDED"];
        [self.statusLabel setBackgroundColor:[UIColor blueColor]];
        NSLog(@"Motion Recorded");
        //NSLog(@"RECORDED MOTION: %@", self.recordedMotionX);
    }
    else{

        // Delete the recorded points before starting fresh
        // Should appear before setting startStopButtonIsActive to True or we might have race conditions
        [self.recordedMotionX removeAllObjects];
        [self.recordedMotionY removeAllObjects];
        [self.recordedMotionZ removeAllObjects];
        self.recordButtonIsActive = YES;
        self.isRecorded = NO;
        [self.statusLabel setText:@"Recording motion..."];
        [self.statusLabel setBackgroundColor:[UIColor brownColor]];
        [self.recordBtn setTitle:@"Recording..." forState:UIControlStateNormal];
        
        NSLog(@"Started Recording Motion");
    }
}

- (IBAction)startAuthentication:(id)sender {
    if (!self.isRecorded) {
        return;
    }
    if(self.startStopButtonIsActive == YES){
        self.startStopButtonIsActive = NO;

        MGAKeySignature* sig = [[MGAKeySignature alloc] initWithAccelerationPointsX:self.accelerationPointsX Y:self.accelerationPointsY Z:self.accelerationPointsZ AndRecordedMotionX:self.recordedMotionX AndRecordedMotionY:self.recordedMotionY AndRecordedMotionZ:self.recordedMotionZ AndSamplingInterval:samplingInterval];
        isAuthenticated = [sig authenticateWithSecurityLevel:self.securitySliderValue];
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
        float a_z = acceleration.z;
        
        // Invert accelerometer axes.
        a_x = -1.0 * a_x;
        a_y = -1.0 * a_y - 1;
        a_z = -1.0 * a_z;
        NSNumber* x = [NSNumber numberWithFloat:a_x];
        NSNumber* y = [NSNumber numberWithFloat:a_y];
        NSNumber* z = [NSNumber numberWithFloat:a_z];
        
        //NSLog(@"%@", y);
        [self.accelerationPointsX addObject:x];
        [self.accelerationPointsY addObject:y];
        [self.accelerationPointsZ addObject:z];

    } else if (self.recordButtonIsActive){
        // Filter out noise
        float a_x = acceleration.x;
        float a_y = acceleration.y;
        float a_z = acceleration.z;
        
        // Invert accelerometer axes.
        a_x = -1.0 * a_x;
        a_y = -1.0 * a_y - 1;
        a_z = -1.0 * a_z;
        NSNumber* x = [NSNumber numberWithFloat:a_x];
        NSNumber* y = [NSNumber numberWithFloat:a_y];
        NSNumber* z = [NSNumber numberWithFloat:a_z];
        
        //NSLog(@"%@", y);
        [self.recordedMotionX addObject:x];
        [self.recordedMotionY addObject:y];
        [self.recordedMotionZ addObject:z];
    }
}

- (void)startUpdates
{
    NSTimeInterval updateInterval = 0.0125;
    
    CMMotionManager *mManager = [(MGAAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    if ([mManager isDeviceMotionAvailable] == YES) {
        // Update interval specified here.
        [mManager setDeviceMotionUpdateInterval:updateInterval];
        [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            // Implement data storage here.
            if(self.startStopButtonIsActive){
                [self.accelerationPointsX addObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.x]];
                [self.accelerationPointsY addObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.y]];
                [self.accelerationPointsZ addObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.z]];
            } else if (self.recordButtonIsActive){
                [self.recordedMotionX addObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.x]];
                [self.recordedMotionY addObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.y]];
                [self.recordedMotionZ addObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.z]];
            }
        }];
    }
}


- (void)stopUpdates
{
    CMMotionManager *mManager = [(MGAAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    if ([mManager isDeviceMotionActive] == YES) {
        [mManager stopDeviceMotionUpdates];
    }
}

@end
