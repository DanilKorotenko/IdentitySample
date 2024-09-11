//
//  IUIdentity.h
//  IdentitySample
//
//  Created by Danil Korotenko on 8/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IUIdentity : NSObject

+ (IUIdentity *)administratorsGroup;
+ (IUIdentity *)localUserWithFullName:(NSString *)aName;
+ (IUIdentity *)currentUser;

+ (IUIdentity *)newHiddenUserWithFullName:(NSString *)aFullName password:(NSString *)aPassword;

- (instancetype)initWithIdentity:(CSIdentityRef)anIdentity;

@property(readwrite)    NSString        *fullName;
@property(readonly)     NSString        *posixName;
@property(readwrite)    NSString        *emailAddress;
@property(readonly)     NSArray         *aliases;
@property(readonly)     NSData          *imageData;
@property(readonly)     NSString        *imageDataType;
@property(readwrite)    NSURL           *imageURL;
@property(readonly)     NSString        *uuidString;
@property(readonly)     BOOL            isGroup;
@property(readwrite)    BOOL            isEnabled;
@property(readonly)     NSInteger       posixID;
@property(readonly)     CSIdentityClass identityClass;

@property(readonly)     BOOL isAdmin; // is member of admin group

@property(readonly)     CSIdentityQueryRef groupMemebershipQuery;

- (void)deleteIdentity;
- (BOOL)commit:(NSError **)anError;
- (void)commitAsyncDidEndBlock:(void (^)(BOOL commitResult, NSError *anError))didEndBlock;

- (void)addAlias:(NSString *)anAlias;
- (void)removeAlias:(NSString *)anAlias;

#pragma mark group class

- (void)addMember:(IUIdentity *)anIdentity;

@end

NS_ASSUME_NONNULL_END
