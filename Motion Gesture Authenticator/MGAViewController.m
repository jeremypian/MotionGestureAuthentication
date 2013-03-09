//
//  MGAViewController.m
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 2/16/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import "MGAViewController.h"

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
    self.accelerometer.updateInterval = .1;
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
        [self authenticate];
        
        if(isAuthenticated){
            [self.statusLabel setText:@"Authenticated"];
            [self.statusLabel setBackgroundColor:[UIColor greenColor]];
        }
        else {
            [self.statusLabel setText:@"Imposter!"];
            [self.statusLabel setBackgroundColor:[UIColor redColor]];
        }
        
        self.startStopButtonIsActive = NO;
        
        [self.startStopBtn setTitle:@"Start Authentication" forState:UIControlStateNormal];
        
        for (NSNumber* x in self.accelerationPoints){
            NSLog(@"(%f,0,0),", [x floatValue]);
        }
        

        NSLog(@"Stopped Recording");
    }
    else{
        [self.statusLabel setText:@"Recording motion"];
        [self.statusLabel setBackgroundColor:[UIColor blueColor]];

        self.startStopButtonIsActive = YES;
        isAuthenticated = NO;
        [self.startStopBtn setTitle:@"Stop" forState:UIControlStateNormal];
        
        // Delete the recorded points
        [self.accelerationPoints removeAllObjects];
        NSLog(@"Started Recording");
    }
    

}

-(void) authenticate
{
    if(arc4random() % 2 == 0)
        isAuthenticated = YES;
    else
        isAuthenticated = NO;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if(self.startStopButtonIsActive){
        NSNumber* x = [NSNumber numberWithFloat:acceleration.x];
        //NSLog(@"%@", x);
        [self.accelerationPoints addObject:x];
    }
}

@end
