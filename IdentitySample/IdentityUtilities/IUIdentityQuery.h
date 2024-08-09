//
//  IUIdentityQuery.h
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IUIdentityQuery : NSObject

@property(readonly) CSIdentityQueryRef identityQueryRef;

- (void)startForName:(NSString *)aName eventBlock:(void (^)(CSIdentityQueryEvent event, NSError *anError))anEventBlock;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
