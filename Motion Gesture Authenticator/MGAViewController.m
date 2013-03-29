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
@synthesize accelerationPoints;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.statusLabel setText:@"Stopped"];
    [self.statusLabel setBackgroundColor:[UIColor blueColor]];
    
    self.startStopButtonIsActive = NO;

    samplingInterval = 0.01;
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:samplingInterval];
    self.isAuthenticated = NO;
    
    self.accelerationPoints = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAuthentication:(id)sender {
    if(self.startStopButtonIsActive == YES){
        self.startStopButtonIsActive = NO;
        
        MGAKeySignature* sig = [[MGAKeySignature alloc] initWithAccelerationPoints:self.accelerationPoints AndSamplingInterval:samplingInterval];
        isAuthenticated = [sig authenticate];
        [self stopMotionDetect];
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
        [self.statusLabel setText:@"Recording motion"];
        [self.statusLabel setBackgroundColor:[UIColor blueColor]];
        [self startMotionDetect];

        // Delete the recorded points before starting fresh
        // Should appear before setting startStopButtonIsActive to True or we might have race conditions
        [self.accelerationPoints removeAllObjects];
        self.startStopButtonIsActive = YES;
        isAuthenticated = NO;
        [self.startStopBtn setTitle:@"Stop" forState:UIControlStateNormal];
        
        
        
        NSLog(@"Started Recording");
    }
    

}

- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    
    return motionManager;
}

- (void)startMotionDetect
{
    [self.motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             // Filter out noise
             float a_x = data.acceleration.x;
             
             // Invert accelerometer axes.
             a_x = -1.0 * a_x;
             NSNumber* x = [NSNumber numberWithFloat:a_x];
             //NSLog(@"%@", x);
             [self.accelerationPoints addObject:x];
         }
        );
     }
     ];
    
}

- (void) stopMotionDetect
{
    [[self motionManager] stopAccelerometerUpdates];
}


@end
