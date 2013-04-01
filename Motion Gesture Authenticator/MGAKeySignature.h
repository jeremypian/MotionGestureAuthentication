//
//  MGAKeySignature.h
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 3/10/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGAKeySignature : NSObject {
    NSArray* accelerationPointsX;
    NSArray* accelerationPointsY;
    float samplingInterval;
}
@property (nonatomic) NSArray *accelerationPointsX;
@property (nonatomic) NSArray *accelerationPointsY;
@property (nonatomic) NSArray *accelerationPointsZ;
@property (nonatomic) NSArray *recordedMotionX;
@property (nonatomic) NSArray *recordedMotionY;
@property (nonatomic) NSArray *recordedMotionZ;

- (BOOL) authenticateWithSecurityLevel:(float)securityLevel;
- (id) initWithAccelerationPointsX: (NSArray*)_accelerationPointsX Y:(NSArray*)_accelerationPointsY Z:(NSArray*)_accelerationPointsZ AndRecordedMotionX:(NSArray*)_recordedMotionX AndRecordedMotionY:(NSArray*)_recordedMotionY AndRecordedMotionZ:(NSArray*)_recordedMotionZ AndSamplingInterval: (float)_samplingInterval;
- (NSArray*) calculateVelocity:(NSArray*)accelerationPoints;
- (NSArray*) calculateDisplacementWithVelocity:(NSArray*)velocity AndAcceleration:(NSArray*) accelerationPoints;
@end
