//
//  IUIdentityQuery.m
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import "IUIdentityQuery.h"

@interface IUIdentityQuery ()

@property(readwrite) CSIdentityQueryRef identityQuery;

@property(strong) void (^eventBlock)(CSIdentityQueryEvent event, NSError *anError);

@end

@implementation IUIdentityQuery

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

// returns identity with exact match by FullName
+ (IUIdentity *)identityWithClass:(CSIdentityClass)aClass fullName:(NSString *)aName
{
    IUIdentity *result = nil;

    CSIdentityQueryRef iQuery = CSIdentityQueryCreateForName(kCFAllocatorDefault, (__bridge CFStringRef)(aName),
        kCSIdentityQueryStringEquals, aClass, CSGetLocalIdentityAuthority());

    IUIdentityQuery *query = [[IUIdentityQuery alloc] initWithIdentityQuery:iQuery];

    NSError *error = nil;
    if ([query execute:&error])
    {
        NSArray *identities = query.identities;
        if (identities.count > 0)
        {
            result = [identities objectAtIndex:0];
        }
    }
    else
    {
        NSLog(@"CSIdentityQueryRef execute error occured: %@", error);
    }

    return result;
}

// returns identity for user with exact match by FullName
+ (IUIdentity *)localUserWithFullName:(NSString *)aName
{
    return [IUIdentityQuery identityWithClass:kCSIdentityClassUser fullName:aName];
}

+ (IUIdentity *)administratorsGroup
{
    return [IUIdentityQuery identityWithClass:kCSIdentityClassGroup fullName:@"admin"];
}

#pragma mark -

- (instancetype)initWithIdentityQuery:(CSIdentityQueryRef)anIdentityQuery
{
    self = [super init];
    if (self)
    {
        self.identityQuery = anIdentityQuery;
    }
    return self;
}

- (void)dealloc
{
    [self stop];
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

#pragma mark -

void QueryEventCallback(CSIdentityQueryRef query, CSIdentityQueryEvent event, CFArrayRef identities,
    CFErrorRef error, void *info)
{
    IUIdentityQuery *me = (__bridge IUIdentityQuery *)info;
    [me queryEvent:event identities:identities error:error];
}

- (void)startForName:(NSString *)aName eventBlock:(void (^)(CSIdentityQueryEvent event, NSError *anError))anEventBlock;
{
    [self stop];

    self.eventBlock = anEventBlock;

    CSIdentityQueryClientContext clientContext = { 0, (__bridge void *)(self), NULL, NULL, NULL, QueryEventCallback };

    /* Create a new identity query with the name passed in, most likely taken from the search field */
    self.identityQuery = CSIdentityQueryCreateForName(NULL, (__bridge CFStringRef)aName, kCSIdentityQueryStringBeginsWith,
        kCSIdentityClassUser, CSGetLocalIdentityAuthority());

    /* Run the query asynchronously and we'll get callbacks sent to our QueryEventCallback function. */
    CSIdentityQueryExecuteAsynchronously(self.identityQuery, kCSIdentityQueryGenerateUpdateEvents, &clientContext,
        CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
}

- (void)stop
{
    if (self.identityQuery)
    {
        CSIdentityQueryStop(self.identityQuery);
        CFRelease(self.identityQuery);
        self.identityQuery = NULL;
    }
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

- (void)queryEvent:(CSIdentityQueryEvent)event identities:(CFArrayRef)identities error:(CFErrorRef)error
{
    if (self.eventBlock)
    {
        self.eventBlock(event, (__bridge NSError *)(error));
    }
}

@end
