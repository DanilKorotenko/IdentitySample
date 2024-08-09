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

- (void)dealloc
{
    [self stop];
}

#pragma mark -

- (CSIdentityQueryRef)identityQueryRef
{
    return self.identityQuery;
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

#pragma mark -

- (void)queryEvent:(CSIdentityQueryEvent)event identities:(CFArrayRef)identities error:(CFErrorRef)error
{
    if (self.eventBlock)
    {
        self.eventBlock(event, (__bridge NSError *)(error));
    }
}

@end
