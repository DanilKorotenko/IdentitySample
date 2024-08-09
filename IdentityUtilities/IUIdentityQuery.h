//
//  IUIdentityQuery.h
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import <Foundation/Foundation.h>
#import "IUIdentity.h"

NS_ASSUME_NONNULL_BEGIN

@interface IUIdentityQuery : NSObject

+ (NSArray *)localUsers;
+ (NSArray *)localGroups;

// returns identity for user with exact match by FullName
+ (IUIdentity *)localUserWithFullName:(NSString *)aName;

+ (IUIdentity *)administratorsGroup;

@property(readonly) NSArray *identities;

- (void)startForName:(NSString *)aName eventBlock:(void (^)(CSIdentityQueryEvent event, NSError *anError))anEventBlock;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
