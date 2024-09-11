//
//  IUIdentityQuery.m
//  IdentitySample
//
//  Created by Danil Korotenko on 8/8/24.
//

#import "IUIdentityQueryWatcher.h"

@interface IUIdentityQueryWatcher ()

@property(strong) void (^eventBlock)(CSIdentityQueryEvent event, NSError *anError);

@end

@implementation IUIdentityQueryWatcher

- (void)dealloc
{
    [self stop];
}

#pragma mark -

void QueryEventCallback(CSIdentityQueryRef query, CSIdentityQueryEvent event, CFArrayRef identities,
    CFErrorRef error, void *info)
{
    IUIdentityQueryWatcher *me = (__bridge IUIdentityQueryWatcher *)info;
    [me queryEvent:event identities:identities error:error];
}

- (void)startWithIncludeHidden:(BOOL)anIncludeHidden
    eventBlock:(void (^)(CSIdentityQueryEvent, NSError * _Nonnull))anEventBlock
{
    self.eventBlock = anEventBlock;

    CSIdentityQueryClientContext clientContext = { 0, (__bridge void *)(self), NULL, NULL, NULL, QueryEventCallback };

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

#pragma mark -

- (void)queryEvent:(CSIdentityQueryEvent)event identities:(CFArrayRef)identities error:(CFErrorRef)error
{
    if (self.eventBlock)
    {
        self.eventBlock(event, (__bridge NSError *)(error));
    }
}

@end
