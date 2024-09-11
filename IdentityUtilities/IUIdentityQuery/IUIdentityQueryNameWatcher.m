//
//  IUIdentityQuery.m
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import "IUIdentityQueryNameWatcher.h"

@interface IUIdentityQueryNameWatcher ()

@property(strong) void (^eventBlock)(CSIdentityQueryEvent event, NSError *anError);

@end

@implementation IUIdentityQueryNameWatcher

@synthesize identityQuery;

#pragma mark -

void QueryNameEventCallback(CSIdentityQueryRef query, CSIdentityQueryEvent event, CFArrayRef identities,
    CFErrorRef error, void *info)
{
    IUIdentityQueryNameWatcher *me = (__bridge IUIdentityQueryNameWatcher *)info;
    [me queryEvent:event identities:identities error:error];
}

- (void)startForName:(NSString *)aName
    authority:(IUIdentityQueryAuthority)anAuthority
    identityClass:(CSIdentityClass)anIdentityClass
    includeHidden:(BOOL)anIncludeHidden
    eventBlock:(void (^)(CSIdentityQueryEvent event, NSError *anError))anEventBlock
{
    [self stop];

    self.eventBlock = anEventBlock;

    CSIdentityQueryClientContext clientContext =
        { 0, (__bridge void *)(self), NULL, NULL, NULL, QueryNameEventCallback };

    /* Create a new identity query with the name passed in, most likely taken from the search field */
    identityQuery = CSIdentityQueryCreateForName(kCFAllocatorDefault,
        (__bridge CFStringRef)aName,
        kCSIdentityQueryStringBeginsWith,
        anIdentityClass, [self authorityForType:anAuthority]);

    CSIdentityQueryFlags flags = anIncludeHidden ?
        kCSIdentityQueryGenerateUpdateEvents | kCSIdentityQueryIncludeHiddenIdentities :
        kCSIdentityQueryGenerateUpdateEvents;

    /* Run the query asynchronously and we'll get callbacks sent to our QueryEventCallback function. */
    CSIdentityQueryExecuteAsynchronously(self.identityQuery, flags, &clientContext,
        CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
}

- (void)stop
{
    if (self.identityQuery)
    {
        CSIdentityQueryStop(self.identityQuery);
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
