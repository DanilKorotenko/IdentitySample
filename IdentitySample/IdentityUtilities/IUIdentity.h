//
//  IUIdentity.h
//  IdentitySample
//
//  Created by Danil Korotenko on 8/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IUIdentity : NSObject

- (instancetype)initWithIdentity:(CSIdentityRef)anIdentity;

@end

NS_ASSUME_NONNULL_END
