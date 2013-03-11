//
//  MGAKeySignature.h
//  Motion Gesture Authenticator
//
//  Created by Jeremy Pian on 3/10/13.
//  Copyright (c) 2013 Jeremy Pian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGAKeySignature : NSObject {
    NSArray* accelerationPoints;
    float samplingInterval;
}
@property (nonatomic) NSArray *accelerationPoints;
- (BOOL) authenticate;
- (id) initWithAccelerationPoints: (NSArray*)_accelerationPoints AndSamplingInterval: (float)_samplingInterval;
- (NSArray*) calculateVelocity;
- (NSArray*) calculateDisplacement:(NSArray*)velocity;
@end
