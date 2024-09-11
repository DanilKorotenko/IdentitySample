//
//  IUIdentityQuery.m
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import "IUIdentityQuery.h"

@interface IUIdentityQuery ()

@end

@implementation IUIdentityQuery

@synthesize identityQuery;

+ (NSArray *)identititesWithClass:(CSIdentityClass)aClass
{
    NSArray *result = nil;

    CSIdentityQueryRef iQuery = CSIdentityQueryCreate(kCFAllocatorDefault, kCSIdentityClassUser,
        CSGetLocalIdentityAuthority());

    IUIdentityQuery *query = [[IUIdentityQuery alloc] initWithIdentityQuery:iQuery];

    NSError *error = nil;
    if ([query execute:&error])
    {
        result = query.identities;
    }
    else
    {
        NSLog(@"CSIdentityQueryRef execute error occured: %@", error);
    }

    return result;
}

+ (NSArray *)localUsers
{
    return [IUIdentityQuery identititesWithClass:kCSIdentityClassUser];
}

+ (NSArray *)localGroups
{
    return [IUIdentityQuery identititesWithClass:kCSIdentityClassGroup];
}

#pragma mark -

- (instancetype)initWithIdentityQuery:(CSIdentityQueryRef)anIdentityQuery
{
    self = [super init];
    if (self)
    {
        identityQuery = anIdentityQuery;
    }
    return self;
}

- (void)dealloc
{
    if (identityQuery)
    {
        CFRelease(identityQuery);
    }
}
#pragma mark -

- (NSArray *)identities
{
    NSArray *result = nil;
    CFArrayRef identities = CSIdentityQueryCopyResults(self.identityQuery);
    if (identities)
    {
        NSMutableArray *mutableIdentitites = [NSMutableArray array];
        for (CFIndex i = 0; i < CFArrayGetCount(identities); i++)
        {
            CSIdentityRef identity = (CSIdentityRef)CFArrayGetValueAtIndex(identities, i);
            [mutableIdentitites addObject:[[IUIdentity alloc] initWithIdentity:identity]];
        }
        CFRelease(identities);
        result = mutableIdentitites;
    }
    return result;
}

- (BOOL)execute:(NSError **)anError
{
    CFErrorRef error = NULL;
    Boolean result = CSIdentityQueryExecute(self.identityQuery, kCSIdentityQueryIncludeHiddenIdentities, &error);
    if (anError && error)
    {
        *anError = (__bridge NSError *)(error);
    }
    return result ? YES : NO;
}

#pragma mark -

- (CSIdentityAuthorityRef)authorityForType:(IUIdentityQueryAuthority)anAuthorityType
{
    switch (anAuthorityType)
    {
        case IUIdentityQueryAuthorityManaged: return CSGetManagedIdentityAuthority();
        case IUIdentityQueryAuthorityDefault: return CSGetDefaultIdentityAuthority();
        default:
            break;
    }
    return CSGetLocalIdentityAuthority();
}

@end
