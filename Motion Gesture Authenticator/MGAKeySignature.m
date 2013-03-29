//
//  MGAKeySignature.m
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 3/10/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import "MGAKeySignature.h"

@implementation MGAKeySignature
@synthesize accelerationPoints;
@synthesize recordedMotion;

-(id) initWithAccelerationPoints: (NSArray*)_accelerationPoints AndRecordedMotion: (NSArray*)_recordedMotion AndSamplingInterval: (float)_samplingInterval
{
    self = [super init];
    if (self) {
        samplingInterval  = _samplingInterval;
        accelerationPoints = _accelerationPoints;
        recordedMotion = _recordedMotion;
    }
    return self;
}

/*
 Current authentication scheme (simple): if phone moves right, then authenticate. Else, deny access.
 */
-(BOOL) authenticate
{
    NSArray* velocities = [self calculateVelocity];
    NSArray* displacements = [self calculateDisplacement:velocities];
    
    /*
    NSLog(@"Acceleration");
    for (int i = 0; i<[self.accelerationPoints count]; i++){
        NSLog(@"(%f,%f),", [[self.accelerationPoints objectAtIndex:i] floatValue], samplingInterval * i);
    }
    
    NSLog(@"Velocity");
    for (int i = 0; i<[velocities count]; i++){
        NSLog(@"(%f,%f),", [[velocities objectAtIndex:i] floatValue], samplingInterval * i);
    }
    
    NSLog(@"Displacements");
    for (int i = 0; i<[displacements count]; i++){
        NSLog(@"(%f,%f),", [[displacements objectAtIndex:i] floatValue], samplingInterval * i);
    }*/
    
    BOOL pass = [self dynamicTimeWarp:self.accelerationPoints];
    //NSNumber *totalDisplacement = [displacements valueForKeyPath:@"@sum.floatValue"];
    //BOOL pass = ([totalDisplacement floatValue] > 0.0);
    return pass;
}

-(BOOL) dynamicTimeWarp:(NSArray *) values
{
    //NSMutableArray *storedGesture = [[NSMutableArray alloc] initWithCapacity:100];
//    float storedGesture[6] = {0.0f, 0.005f, 0.01f, 0.013f, 0.018f, 0.023f};
    float matrix[[self.recordedMotion count]][[values count]];
    for (int i = 0; i < [self.recordedMotion count]; ++i) {
        for (int j = 0; j < [values count]; ++j) {
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
            matrix[i][j] = [self dtwCost:[[self.recordedMotion objectAtIndex:i] floatValue] AndY:[[values objectAtIndex:j] floatValue]] + secondTerm;
            //NSLog(@"matrix [%i, %i] %f", i, j, matrix[i][j]);
        }
    }
    float cost = matrix[[self.recordedMotion count]-1][[values count] - 1];
    NSLog(@"DYNAMICTIMEWARPCOST %f",  cost);
    return true;
}

-(float) dtwCost:(float) x AndY: (float) y
{
    return pow((x-y), 2);
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
@end
