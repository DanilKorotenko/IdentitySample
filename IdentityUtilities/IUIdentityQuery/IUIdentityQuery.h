//
//  IUIdentityQuery.h
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IUIdentityQueryAuthority)
{
    IUIdentityQueryAuthorityLocal,
    IUIdentityQueryAuthorityManaged,
    IUIdentityQueryAuthorityDefault,
};

@interface IUIdentityQuery : NSObject

+ (NSArray *)localUsers;

- (instancetype)initWithIdentityQuery:(CSIdentityQueryRef)anIdentityQuery;

@property(readonly) CSIdentityQueryRef  identityQuery;
@property(readonly) NSArray             *identities;

- (BOOL)execute:(NSError **)anError;

@end

NS_ASSUME_NONNULL_END
