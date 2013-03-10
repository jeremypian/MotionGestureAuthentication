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
    samplingInterval = 0.05;
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

/*
 Current authentication scheme (simple): if phone moves right, then authenticate. Else, deny access.
 */
-(void) authenticate
{
    NSArray* velocities = [self calculateVelocity];
    NSArray* displacements = [self calculateDisplacement:velocities];
    
    NSLog(@"Acceleration");
    for (int i = 0; i<[self.accelerationPoints count]; i++){
        NSLog(@"(%f,%f),", [[self.accelerationPoints objectAtIndex:i] floatValue], samplingInterval * i);
    }
    
    NSLog(@"Velocity");
    for (int i = 0; i<[velocities count]; i++){
        NSLog(@"(%f,%f),", [[velocities objectAtIndex:i] floatValue], samplingInterval * i);
    }
    
    NSLog(@"Velocity");
    for (int i = 0; i<[displacements count]; i++){
        NSLog(@"(%f,%f),", [[displacements objectAtIndex:i] floatValue], samplingInterval * i);
    }
    NSNumber *totalDisplacement = [displacements valueForKeyPath:@"@sum.floatValue"];
    if(totalDisplacement > [NSNumber numberWithFloat:0.0])
        isAuthenticated = YES;
    else
        isAuthenticated = NO;
    
}

-(NSArray*) calculateVelocity
{
    NSMutableArray *velocity = [[NSMutableArray alloc] initWithCapacity:[self.accelerationPoints count] + 1];
    [velocity insertObject:[NSNumber numberWithInt:0] atIndex:0];
    for (int i = 1; i<[self.accelerationPoints count]; i++){
        float a_i = [[self.accelerationPoints objectAtIndex:i - 1] floatValue];
        float v_prev = [[velocity objectAtIndex:i-1] floatValue];
        float v_i = v_prev + a_i * samplingInterval;
        [velocity insertObject:[NSNumber numberWithFloat: v_i] atIndex:i];
    }
    return velocity;
}

-(NSArray*) calculateDisplacement:(NSArray *)velocity
{
    NSMutableArray *displacement = [[NSMutableArray alloc] initWithCapacity:[self.accelerationPoints count] + 1];
    [displacement insertObject:[NSNumber numberWithInt:0] atIndex:0];
    for (int i = 1; i<[self.accelerationPoints count]; i++){
        float v_i = [[velocity objectAtIndex:i - 1 ] floatValue];
        float a_i = [[self.accelerationPoints objectAtIndex:i - 1] floatValue];
        float d_prev = [[displacement objectAtIndex:i-1] floatValue];
        float d_i = d_prev + v_i * samplingInterval + 0.5 * a_i * pow(samplingInterval, 2);
        [displacement insertObject:[NSNumber numberWithFloat:d_i] atIndex:i];
    }
    return displacement;
    
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if(self.startStopButtonIsActive){
        NSNumber* x = [NSNumber numberWithFloat:acceleration.x * 9.8];
        //NSLog(@"%@", x);
        [self.accelerationPoints addObject:x];
    }
}

@end
