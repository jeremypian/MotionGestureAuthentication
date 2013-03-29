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
@property (nonatomic) NSArray *accelerationPoints;
@property (nonatomic) NSArray *recordedMotion;
- (BOOL) authenticate;
- (id) initWithAccelerationPoints: (NSArray*)_accelerationPoints AndRecordedMotion: (NSArray*)_recoredMotion AndSamplingInterval: (float)_samplingInterval;
- (NSArray*) calculateVelocity;
- (NSArray*) calculateDisplacement:(NSArray*)velocity;
@end
