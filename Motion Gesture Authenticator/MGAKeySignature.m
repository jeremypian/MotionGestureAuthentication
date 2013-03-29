//
//  MGAKeySignature.m
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 3/10/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import "MGAKeySignature.h"

@implementation MGAKeySignature
@synthesize accelerationPointsX;
@synthesize accelerationPointsY;


-(id) initWithAccelerationPointsX: (NSArray*)_accelerationPointsX Y:(NSArray*)_accelerationPointsY AndSamplingInterval: (float)_samplingInterval
{
    self = [super init];
    if (self) {
        samplingInterval  = _samplingInterval;
        accelerationPointsX = _accelerationPointsX;
        accelerationPointsY = _accelerationPointsY;

    }
    return self;
}

/*
 Current authentication scheme (simple): if phone moves right, then authenticate. Else, deny access.
 */
-(BOOL) authenticate
{
    NSArray* velocities = [self calculateVelocity:self.accelerationPointsX];
    NSArray* displacements = [self calculateDisplacementWithVelocity:velocities AndAcceleration:self.accelerationPointsX];
    
    
    NSLog(@"Acceleration");
    NSMutableString *output = [[NSMutableString alloc] init];
    for (int i = 0; i<[self.accelerationPointsX count]; i++){
        [output appendString:[NSString stringWithFormat:@"%@,", [self.accelerationPointsX objectAtIndex:i]]];
    }
    NSLog(@"%@", output);
    
    output = [[NSMutableString alloc] init];
    NSLog(@"Velocity");
    for (int i = 0; i<[velocities count]; i++){
        [output appendString:[NSString stringWithFormat:@"%@,", [velocities objectAtIndex:i]]];
    }
    NSLog(@"%@", output);

    NSLog(@"Displacements");
    output = [[NSMutableString alloc] init];
    for (int i = 0; i<[displacements count]; i++){
        [output appendString:[NSString stringWithFormat:@"%@,", [displacements objectAtIndex:i]]];
    }
    NSLog(@"%@", output);
    
    NSNumber *totalDisplacement = [displacements valueForKeyPath:@"@sum.floatValue"];
    BOOL pass = ([totalDisplacement floatValue] > 0.0);
    return pass;
}

-(NSArray*) calculateVelocity:(NSArray*)accelerationPoints
{
    NSMutableArray *velocity = [[NSMutableArray alloc] initWithCapacity:[accelerationPoints count] + 1];
    [velocity insertObject:[NSNumber numberWithInt:0] atIndex:0];
    for (int i = 1; i<[accelerationPoints count]; i++){
        float a_i = [[accelerationPoints objectAtIndex:i - 1] floatValue];
        float v_prev = [[velocity objectAtIndex:i-1] floatValue];
        float v_i = v_prev + a_i * samplingInterval;
        [velocity insertObject:[NSNumber numberWithFloat: v_i] atIndex:i];
    }
    return velocity;
}

-(NSArray*) calculateDisplacementWithVelocity:(NSArray *)velocity AndAcceleration:(NSArray *)accelerationPoints
{
    NSMutableArray *displacement = [[NSMutableArray alloc] initWithCapacity:[accelerationPoints count] + 1];
    [displacement insertObject:[NSNumber numberWithInt:0] atIndex:0];
    for (int i = 1; i<[accelerationPoints count]; i++){
        float v_i = [[velocity objectAtIndex:i - 1 ] floatValue];
        float a_i = [[accelerationPoints objectAtIndex:i - 1] floatValue];
        float d_prev = [[displacement objectAtIndex:i-1] floatValue];
        float d_i = d_prev + v_i * samplingInterval + 0.5 * a_i * pow(samplingInterval, 2);
        [displacement insertObject:[NSNumber numberWithFloat:d_i] atIndex:i];
    }
    return displacement;
    
}
@end
