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
@synthesize accelerationPointsX;
@synthesize accelerationPointsY;
@synthesize accelerationPointsZ;




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.statusLabel setText:@"Stopped"];
    [self.statusLabel setBackgroundColor:[UIColor blueColor]];
    
    self.startStopButtonIsActive = NO;

    samplingInterval = 0.01;
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.delegate = self;
    [self.accelerometer setUpdateInterval:samplingInterval];
    
    self.isAuthenticated = NO;
    
    self.accelerationPointsY = [[NSMutableArray alloc] init];
    self.accelerationPointsX = [[NSMutableArray alloc] init];
    self.accelerationPointsZ = [[NSMutableArray alloc] init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAuthentication:(id)sender {
    if(self.startStopButtonIsActive == YES){
        self.startStopButtonIsActive = NO;

        MGAKeySignature* sig = [[MGAKeySignature alloc] initWithAccelerationPointsX:self.accelerationPointsX Y:self.accelerationPointsY AndSamplingInterval:samplingInterval];
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
        NSNumber* y = [NSNumber numberWithFloat:a_y];
        
        //NSLog(@"%@", y);
        [self.accelerationPointsX addObject:x];
        [self.accelerationPointsY addObject:y];
    }
}


@end
