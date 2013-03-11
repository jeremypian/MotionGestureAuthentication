//
//  MGAViewController.m
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 2/16/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import "MGAViewController.h"
#import "MGAKeySignature.h"

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
    
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    samplingInterval = 0.01;
    self.accelerometer.updateInterval = samplingInterval;
    self.accelerometer.delegate = self;
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

        // Delete the recorded points before starting fresh
        // Should appear before setting startStopButtonIsActive to True or we might have race conditions
        [self.accelerationPoints removeAllObjects];
        self.startStopButtonIsActive = YES;
        isAuthenticated = NO;
        [self.startStopBtn setTitle:@"Stop" forState:UIControlStateNormal];
        
        
        
        NSLog(@"Started Recording");
    }
    

}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if(self.startStopButtonIsActive){
        // Filter out noise
        float a_x = fabsf(acceleration.x) >= 0.0 ? acceleration.x : 0.0;
        // Invert accelerometer axes.   
        a_x = -1.0 * a_x;
        NSNumber* x = [NSNumber numberWithFloat:a_x];
        //NSLog(@"%@", x);
        [self.accelerationPoints addObject:x];
    }
}

@end
