//
//  IUIdentityQuery.h
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import <Foundation/Foundation.h>
#import "IUIdentityQueryWatcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface IUIdentityQueryNameWatcher : IUIdentityQueryWatcher

- (void)startForName:(NSString *)aName
    authority:(IUIdentityQueryAuthority)anAuthority
    identityClass:(CSIdentityClass)anIdentityClass
    includeHidden:(BOOL)anIncludeHidden
    eventBlock:(void (^)(CSIdentityQueryEvent event, NSError *anError))anEventBlock;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
