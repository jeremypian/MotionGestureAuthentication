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
@synthesize userName;
@synthesize startStopButtonIsActive;
@synthesize accelerationPoints;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.statusLight setBackgroundColor:[UIColor redColor]];
    
    self.startStopButtonIsActive = NO;
    
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    self.accelerometer.delegate = self;
    
    self.accelerationPoints = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self setTextField:nil];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeGreeting:(id)sender {
    self.userName = self.textField.text;
    NSString *nameString = self.userName;
    if ([nameString length] == 0) {
        nameString = @"World";
    }
    NSString *greeting = [[NSString alloc] initWithFormat:@"Hello, %@!", nameString];
    self.label.text = greeting;
    if(self.statusLight.backgroundColor == [UIColor redColor]){
        [self.statusLight setBackgroundColor:[UIColor greenColor]];
    }
    else {
        [self.statusLight setBackgroundColor:[UIColor redColor]];
    }
    if(self.startStopButtonIsActive == YES){
        self.startStopButtonIsActive = NO;
        [self.startStopBtn setTitle:@"Start" forState:UIControlStateNormal];
        [self.startStopBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        
        for (NSNumber* x in self.accelerationPoints){
            NSLog(@"(%f,0,0),", [x floatValue]);
        }
        

        NSLog(@"Stopped Recording");
    }
    else{
        self.startStopButtonIsActive = YES;
        [self.startStopBtn setTitle:@"Stop" forState:UIControlStateNormal];
        [self.accelerationPoints removeAllObjects];
        NSLog(@"Started Recording");
    }
    

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.textField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if(self.startStopButtonIsActive){
        NSNumber* x = [NSNumber numberWithFloat:acceleration.x];
        //NSLog(@"%@", x);
        [self.accelerationPoints addObject:x];
    }
}

@end
