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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.statusLight setBackgroundColor:[UIColor redColor]];
    self.startStopButtonIsActive = NO;
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
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

        NSLog(@"Stopped Recording");
    }
    else{
        self.startStopButtonIsActive = YES;
        [self.startStopBtn setTitle:@"Stop" forState:UIControlStateNormal];
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
    NSLog(@"%@%f", @"X: ", acceleration.x);
    NSLog(@"%@%f", @"Y: ", acceleration.y);
    NSLog(@"%@%f", @"Z: ", acceleration.z);

}

@end
