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
@synthesize accelerationPointsZ;
@synthesize recordedMotionX;
@synthesize recordedMotionY;
@synthesize recordedMotionZ;


-(id) initWithAccelerationPointsX: (NSArray*)_accelerationPointsX Y:(NSArray*)_accelerationPointsY Z:(NSArray *)_accelerationPointsZ AndRecordedMotionX:(NSArray *)_recordedMotionX AndRecordedMotionY:(NSArray *)_recordedMotionY AndRecordedMotionZ:(NSArray *)_recordedMotionZ AndSamplingInterval:(float)_samplingInterval
{
    self = [super init];
    if (self) {
        samplingInterval  = _samplingInterval;
        accelerationPointsX = _accelerationPointsX;
        accelerationPointsY = _accelerationPointsY;
        accelerationPointsZ = _accelerationPointsZ;
        recordedMotionX = _recordedMotionX;
        recordedMotionY = _recordedMotionY;
        recordedMotionZ = _recordedMotionZ;
    }
    return self;
}

/*
 Current authentication scheme (simple): if phone moves right, then authenticate. Else, deny access.
 */
-(BOOL) authenticateWithSecurityLevel:(float)securityLevel
{
    /*
    NSArray* velocities_x = [self calculateVelocity:self.accelerationPointsX];
    NSArray* displacements_x = [self calculateDisplacementWithVelocity:velocities_x AndAcceleration:self.accelerationPointsX];
    
    NSArray* velocities_y = [self calculateVelocity:self.accelerationPointsY];
    NSArray* displacements_y = [self calculateDisplacementWithVelocity:velocities_y AndAcceleration:self.accelerationPointsY];
    */
    /*
    NSLog(@"Acceleration");
    NSMutableString *output = [[NSMutableString alloc] init];
    for (int i = 0; i<[self.accelerationPointsY count]; i++){
        [output appendString:[NSString stringWithFormat:@"%@,", [self.accelerationPointsY objectAtIndex:i]]];
    }
    NSLog(@"%@", output);
    
    
    output = [[NSMutableString alloc] init];
    NSLog(@"Velocity");
    for (int i = 0; i<[velocities_y count]; i++){
        [output appendString:[NSString stringWithFormat:@"%@,", [velocities_y objectAtIndex:i]]];
    }
    NSLog(@"%@", output);

    NSLog(@"Displacements");
    output = [[NSMutableString alloc] init];
    for (int i = 0; i<[displacements_y count]; i++){
        [output appendString:[NSString stringWithFormat:@"%@,", [displacements_y objectAtIndex:i]]];
    }
    NSLog(@"%@", output);
    */
    BOOL pass = NO;
    float x_cost = [self dynamicTimeWarp:self.accelerationPointsX AndRecorded:self.recordedMotionX];
    float y_cost = [self dynamicTimeWarp:self.accelerationPointsY AndRecorded:self.recordedMotionY];
    float z_cost = [self dynamicTimeWarp:self.accelerationPointsZ AndRecorded:self.recordedMotionZ];
    if (x_cost < securityLevel && y_cost < securityLevel && z_cost < securityLevel) {
        pass = YES;
    }
    //NSNumber *totalDisplacement = [displacements valueForKeyPath:@"@sum.floatValue"];
    //BOOL pass = ([totalDisplacement floatValue] > 0.0);
    return pass;
}

-(float) dynamicTimeWarp:(NSArray *)measured AndRecorded:(NSArray *)recorded
{
    //NSMutableArray *storedGesture = [[NSMutableArray alloc] initWithCapacity:100];
//    float storedGesture[6] = {0.0f, 0.005f, 0.01f, 0.013f, 0.018f, 0.023f};
    float matrix[[recorded count]][[measured count]];
    for (int i = 0; i < [recorded count]; ++i) {
        for (int j = 0; j < [measured count]; ++j) {
            float secondTerm;
            if (i == 0 && j == 0) {
                secondTerm = 0;
            } else if (i == 0) {
                secondTerm = matrix[i][j-1];
            } else if (j == 0) {
                secondTerm = matrix[i-1][j];
            } else {
                secondTerm = fminf(matrix[i][j-1], fminf(matrix[i-1][j], matrix[i-1][j-1]));
            }
            // Calculate distance using distance function
            matrix[i][j] = [self dtwCost:[[recorded objectAtIndex:i] floatValue] AndY:[[measured objectAtIndex:j] floatValue]] + secondTerm;
            //NSLog(@"matrix [%i, %i] %f", i, j, matrix[i][j]);
        }
    }
    float cost = matrix[[recorded count] - 1][[measured count] - 1];
    NSLog(@"DYNAMICTIMEWARPCOST %f",  cost);
    return cost;
}

-(float) dtwCost:(float) x AndY: (float) y
{
    return pow((x-y), 2);
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
