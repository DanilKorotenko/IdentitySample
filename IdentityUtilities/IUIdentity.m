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

@synthesize fullName;
@synthesize posixName;
@synthesize emailAddress;
@synthesize aliases;
@synthesize imageData;
@synthesize imageDataType;
@synthesize imageURL;
@synthesize uuidString;

+ (IUIdentity *)newHiddenUserWithFullName:(NSString *)aFullName password:(NSString *)aPassword
{
    if (aFullName.length == 0 || aPassword.length == 0)
    {
        return nil;
    }

    IUIdentity *result = nil;

    /* Create a brand new identity */
    CSIdentityRef identity = CSIdentityCreate(kCFAllocatorDefault, kCSIdentityClassUser, (__bridge CFStringRef)aFullName,
        kCSIdentityGeneratePosixName, kCSIdentityFlagHidden, CSGetLocalIdentityAuthority());

    if (identity)
    {
        CSIdentitySetPassword(identity, (__bridge CFStringRef)aPassword);
        result = [[IUIdentity alloc] initWithIdentity:identity];
        CFRelease(identity);
    }

    return result;
}

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

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.fullName];
}

#pragma mark -

- (NSString *)fullName
{
    if (fullName == nil)
    {
        fullName = (__bridge NSString *)CSIdentityGetFullName(self.identity);
    }
    return fullName;
}

- (void)setFullName:(NSString *)aFullName
{
    fullName = nil;
    CSIdentitySetFullName(self.identity, (__bridge CFStringRef)(aFullName));
}

- (NSString *)posixName
{
    if (posixName == nil)
    {
        posixName = (__bridge NSString *)CSIdentityGetPosixName(self.identity);
    }
    return posixName;
}

- (NSString *)emailAddress
{
    if (emailAddress == nil)
    {
        emailAddress = (__bridge NSString *)CSIdentityGetEmailAddress(self.identity);
    }
    return emailAddress;
}

- (void)setEmailAddress:(NSString *)aEmailAddress
{
    emailAddress = nil;
    CFStringRef emailAddressRef = (__bridge CFStringRef)(aEmailAddress);
    CSIdentitySetEmailAddress(self.identity, CFStringGetLength(emailAddressRef) ? emailAddressRef : NULL);
}

- (NSArray *)aliases
{
    if (aliases == nil)
    {
        aliases = (__bridge NSArray *)CSIdentityGetAliases(self.identity);
    }
    return aliases;
}

- (NSData *)imageData
{
    if (imageData == nil)
    {
        imageData = (__bridge NSData *)CSIdentityGetImageData(self.identity);
    }
    return imageData;
}

- (NSString *)imageDataType
{
    if (imageDataType == nil)
    {
        imageDataType = (__bridge NSString *)CSIdentityGetImageDataType(self.identity);
    }
    return imageDataType;
}

- (NSURL *)imageURL
{
    if (imageURL == nil)
    {
        imageURL = (__bridge NSURL *)CSIdentityGetImageURL(self.identity);
    }
    return imageURL;
}

- (void)setImageURL:(NSURL *)imageURL
{
    imageURL = nil;
    CSIdentitySetImageURL(self.identity, (__bridge CFURLRef)(imageURL));
}

- (NSString *)uuidString
{
    if (uuidString == nil)
    {
        CFUUIDRef identityUUID = CSIdentityGetUUID(self.identity);
        CFStringRef uuidStringRef = CFUUIDCreateString(kCFAllocatorDefault, identityUUID);
        uuidString = (__bridge NSString * _Nonnull)(uuidStringRef);
    }
    return uuidString;
}

- (BOOL)isEnabled
{
    return (BOOL)CSIdentityIsEnabled(self.identity);
}

- (void)setIsEnabled:(BOOL)isEnabled
{
    CSIdentitySetIsEnabled(self.identity, (Boolean)isEnabled);
}

- (NSInteger)posixID
{
    return (NSInteger)CSIdentityGetPosixID(self.identity);
}

- (CSIdentityClass)identityClass
{
    return CSIdentityGetClass(self.identity);
}

#pragma mark -

- (void)deleteIdentity
{
    CSIdentityDelete(self.identity);
}

- (BOOL)commit:(NSError **)anError
{
    CFErrorRef error = NULL;
    Boolean result = CSIdentityCommit(self.identity, NULL, &error);
    if (anError && error)
    {
        *anError = (__bridge NSError *)(error);
    }
    return result ? YES : NO;
}

- (void)commitAsyncDidEndBlock:(void (^)(BOOL commitResult, NSError *anError))didEndBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        NSError *error = nil;
        BOOL result = [self commit:&error];
        didEndBlock(result, error);
    });
}

- (void)addAlias:(NSString *)anAlias
{
    CSIdentityAddAlias(self.identity, (__bridge CFStringRef)(anAlias));
}

- (void)removeAlias:(NSString *)anAlias
{
    CSIdentityRemoveAlias(self.identity, (__bridge CFStringRef)(anAlias));
}

- (void)addMember:(IUIdentity *)anIdentity
{
    if (self.identityClass != kCSIdentityClassGroup)
    {
        return;
    }
    CSIdentityAddMember(self.identity, anIdentity.identity);
}

@end
