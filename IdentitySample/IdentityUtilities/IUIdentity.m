//
//  IUIdentity.m
//  IdentitySample
//
//  Created by Danil Korotenko on 8/9/24.
//

#import "IUIdentity.h"

@interface IUIdentity ()

@property(readwrite) CSIdentityRef identity;

@end

@implementation IUIdentity

- (instancetype)initWithIdentity:(CSIdentityRef)anIdentity
{
    self = [super init];
    if (self)
    {
        self.identity = (CSIdentityRef)CFRetain(anIdentity);
    }
    return self;
}

- (void)dealloc
{
    if (self.identity)
    {
        CFRelease(self.identity);
    }
}

@end
