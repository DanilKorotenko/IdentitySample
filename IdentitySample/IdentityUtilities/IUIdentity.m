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
@synthesize uuid;

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

- (NSUUID *)uuid
{
    if (uuid == nil)
    {
        uuid = (__bridge NSUUID * _Nonnull)(CSIdentityGetUUID(self.identity));
    }
    return uuid;
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

- (void)addAlias:(NSString *)anAlias
{
    CSIdentityAddAlias(self.identity, (__bridge CFStringRef)(anAlias));
}

- (void)removeAlias:(NSString *)anAlias
{
    CSIdentityRemoveAlias(self.identity, (__bridge CFStringRef)(anAlias));
}

@end
