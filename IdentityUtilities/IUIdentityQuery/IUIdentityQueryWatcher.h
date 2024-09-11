//
//  IUIdentityQuery.h
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import <Foundation/Foundation.h>
#import "IUIdentityQuery.h"

NS_ASSUME_NONNULL_BEGIN

@interface IUIdentityQueryWatcher : IUIdentityQuery

- (void)startWithIncludeHidden:(BOOL)anIncludeHidden
    eventBlock:(void (^)(CSIdentityQueryEvent event, NSError *anError))anEventBlock;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
