/*
 File: IdentityController.m
 Abstract: IdentitySample builds a utility which demonstrates how to use the CoreServices Identity API to manage system-wide identities. These identities can then be used by applications to enable secure collaboration among users on a network. The utility allows you to add and delete identities, change identity information as well as query for identities by name.
 Version: 1.1

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2011 Apple Inc. All Rights Reserved.

 */

#import "IdentityController.h"
#import <CoreServices/CoreServices.h>

#import "IdentityUtilities/IUIdentityQuery.h"

@interface IdentityController ()

@property(strong) IBOutlet NSButton         *addAliasButton;
@property(strong) IBOutlet NSPopUpButton    *addIdentityClassPopUp;
@property(strong) IBOutlet NSTextField      *addIdentityFullName;
@property(strong) IBOutlet NSTextField      *addIdentityPasswordLabel;
@property(strong) IBOutlet NSSecureTextField *addIdentityPassword;
@property(strong) IBOutlet NSTextField      *addIdentityPosixName;
@property(strong) IBOutlet NSTextField      *addIdentityPosixNameLabel;
@property(strong) IBOutlet NSSecureTextField *addIdentityVerify;
@property(strong) IBOutlet NSTextField      *addIdentityVerifyLabel;
@property(strong) IBOutlet NSWindow         *addIdentityWindow;
@property(strong) IBOutlet NSTableView      *aliasesTableView;
@property(strong) IBOutlet NSWindow         *mainWindow;
@property(strong) IBOutlet NSTableView      *identityTableView;
@property(strong) IBOutlet NSSearchField    *searchText;
@property(strong) IBOutlet NSTextField      *fullName;
@property(strong) IBOutlet NSTextField      *posixName;
@property(strong) IBOutlet NSTextField      *emailAddress;
@property(strong) IBOutlet NSTextField      *uuid;
@property(strong) IBOutlet NSTextField      *posixID;
@property(strong) IBOutlet NSTextField      *imageURL;
@property(strong) IBOutlet NSTextField      *imageDataType;
@property(strong) IBOutlet NSImageView      *imageView;
@property(strong) IBOutlet NSButton         *isEnabled;
@property(strong) IBOutlet NSButton         *applyNowButton;
@property(strong) IBOutlet NSButton         *revertButton;
@property(strong) IBOutlet NSButton         *removeAliasButton;
@property(strong) IBOutlet NSButton         *removeIdentityButton;
@property(strong) IBOutlet NSButton         *generatePosixNameButton;

@property(strong) NSMutableArray *aliases;
@property(strong) NSMutableArray *identities;
@property(strong) NSImage *userImage;
@property(strong) NSImage *groupImage;
@property(strong) IUIdentityQuery *identityQuery;
@property(strong) NSTimer *queryStartTimer;

@end

@implementation IdentityController

@synthesize aliases;

- (NSMutableArray *)aliases
{
    if (aliases == nil)
    {
        aliases = [NSMutableArray array];
    }
    return aliases;
}

- (void)setAliases:(NSMutableArray *)anAliases
{
    if (aliases != anAliases)
    {
        aliases = anAliases ? anAliases : [NSMutableArray array];
        [self.aliasesTableView reloadData];
    }
}

- (void)setImageWithData:(NSData*)data type:(NSString *)type url:(NSURL *)url
{
    if (data)
    {
        self.imageView.image = [[NSImage alloc] initWithData:data];
    }

    self.imageDataType.stringValue = type ? type : @"";

    if (url)
    {
        NSString *imageURLString = url.relativePath;
        self.imageURL.stringValue = imageURLString ? imageURLString : @"";
        if (!data)
        {
            self.imageView.image = [[NSImage alloc] initWithContentsOfURL:url];
        }
    }
    else
    {
        self.imageURL.stringValue = @"";
        if (!data)
        {
            self.imageView.image = nil;
        }
    }
}

- (void)setIdentityInfoEnabled:(BOOL)enabled
{
    self.fullName.enabled = enabled;
    self.posixName.enabled = enabled;
    self.emailAddress.enabled = enabled;
    self.uuid.enabled = enabled;
    self.imageURL.enabled = enabled;
    self.imageDataType.enabled = enabled;
    self.isEnabled.enabled = enabled;
    self.posixID.enabled = enabled;
    self.aliasesTableView.enabled = enabled;
    self.imageView.enabled = enabled;
}

- (void)reloadIdentityAtIndex:(NSInteger)currentIndex
{
    if (currentIndex != -1)
    {
        /* Fetch the CSIdentityRef corresponding to the current sidebar selection */
        CSIdentityRef identity = (__bridge CSIdentityRef)[self.identities objectAtIndex:currentIndex];

        /* Fetch all the Identity information to update the user interface */
        NSString *fullName = (__bridge NSString *)CSIdentityGetFullName(identity);
        NSString *posixName = (__bridge NSString *)CSIdentityGetPosixName(identity);
        NSString *emailAddress = (__bridge NSString *)CSIdentityGetEmailAddress(identity);
        NSArray *aliases = (__bridge NSArray *)CSIdentityGetAliases(identity);
        NSData *imageData = (__bridge NSData *)CSIdentityGetImageData(identity);
        NSString *imageDataType = (__bridge NSString *)CSIdentityGetImageDataType(identity);
        NSURL *imageURL = (__bridge NSURL *)CSIdentityGetImageURL(identity);
        NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, CSIdentityGetUUID(identity)));
        BOOL isEnabled = (BOOL)CSIdentityIsEnabled(identity);
        int posixID = (int)CSIdentityGetPosixID(identity);

        /* Enable all the controls */
        [self setIdentityInfoEnabled:YES];

        /* Update the user interface with the current info */
        self.fullName.stringValue = fullName ? fullName : @"";
        self.posixName.stringValue = posixName ? posixName : @"";
        self.emailAddress.stringValue = emailAddress ? emailAddress : @"";
        self.uuid.stringValue = uuidString ? uuidString : @"";
        self.isEnabled.state = isEnabled;
        self.posixID.intValue = posixID;
        [self setAliases:[aliases mutableCopy]];
        [self setImageWithData:imageData type:imageDataType url:imageURL];

        /* Enable the Add Alias button and disable the Remove Alias button */
        self.addAliasButton.enabled = YES;
        self.removeAliasButton.enabled = NO;
    }
    else
    {
        /* Disable all the controls */
        [self setIdentityInfoEnabled:NO];

        /* Clear all the info */
        self.uuid.stringValue = @"";
        self.posixID.stringValue = @"";
        self.imageURL.stringValue = @"";
        self.fullName.stringValue = @"";
        self.posixName.stringValue = @"";
        self.emailAddress.stringValue = @"";
        self.isEnabled.state = NO;
        [self setAliases:nil];
        [self setImageWithData:nil type:nil url:nil];

        /* Disable the Add/Remove Alias buttons */
        self.addAliasButton.enabled = NO;
        self.removeAliasButton.enabled = NO;
    }

    /* Disable the Apply and Revert buttons */
    self.applyNowButton.enabled = NO;
    self.revertButton.enabled = NO;
}

NSComparisonResult SortByFirstName(id val1, id val2, void *context)
{
    NSString *fullName1 = (__bridge NSString *)CSIdentityGetFullName((__bridge CSIdentityRef)val1);
    NSString *fullName2 = (__bridge NSString *)CSIdentityGetFullName((__bridge CSIdentityRef)val2);
    return [fullName1 caseInsensitiveCompare:fullName2];
}

- (void)updateIdentities
{
    CSIdentityRef selectedIdentity = NULL;
    NSInteger currentIndex = [self.identityTableView selectedRow];

    if (currentIndex != -1)
    {
        /* Save away the currently selected identity in the sidebar */
        selectedIdentity = (__bridge CSIdentityRef)[self.identities objectAtIndex:currentIndex];
    }

    /* Replace the previous identity list with the latest query results and sort it in alphabetical order */
    NSArray *identities = (NSArray *)CFBridgingRelease(CSIdentityQueryCopyResults(self.identityQuery.identityQueryRef));
    self.identities = [identities mutableCopy];
    [self.identities sortUsingFunction:SortByFirstName context:nil];
    [self.identityTableView reloadData];

    if (selectedIdentity)
    {
        /* Reselect the previously selected identity */
        NSUInteger index, count = self.identities.count;
        for (index = 0; index < count; index++)
        {
            if (CFEqual(selectedIdentity, (CSIdentityRef)[self.identities objectAtIndex:index]))
            {
                [self.identityTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
                break;
            }
        }
        CFRelease(selectedIdentity);
    }

    [self reloadIdentityAtIndex:[self.identityTableView selectedRow]];
}

- (void)receiveEvent:(CSIdentityQueryEvent)event error:(NSError*)error
{
    /* Our query callback was called so lets update the sidebar */
    [self updateIdentities];

    if (event == kCSIdentityQueryEventErrorOccurred)
    {
        NSLog(@"Query %p error %@, info %@", self.identityQuery, error, [error userInfo]);
    }
}

- (void)queryForIdentitiesByName:(NSString *)name
{
    if (!self.identityQuery)
    {
        self.identityQuery = [[IUIdentityQuery alloc] init];
    }

    [self.identityQuery startForName:name eventBlock:
        ^(CSIdentityQueryEvent event, NSError *anError)
        {
            [self receiveEvent:event error:anError];
        }];
}

- (void)startNewSearchQuery:(NSTimer*)theTimer
{
    [self queryForIdentitiesByName:[self.searchText stringValue]];
    [self.queryStartTimer invalidate];
    self.queryStartTimer = nil;
}

- (void)searchTextDidChange:(NSNotification *)notification
{
#define QUERY_DELAY 0.25
    if (self.queryStartTimer)
    {
        [self.queryStartTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:QUERY_DELAY]];
    }
    else
    {
        self.queryStartTimer = [NSTimer scheduledTimerWithTimeInterval:QUERY_DELAY target:self
            selector:@selector(startNewSearchQuery:) userInfo:nil repeats:NO];
    }
}

- (BOOL)wasIdentityChanged
{
    BOOL wasChanged = NO;
    NSInteger currentIndex = [self.identityTableView selectedRow];

    if (currentIndex != -1)
    {
        /* Fetch all the actual settable values from the current identity */
        CSIdentityRef identity = (__bridge CSIdentityRef)[self.identities objectAtIndex:currentIndex];
        NSString *fullName = (__bridge NSString *)CSIdentityGetFullName(identity);
        NSString *emailAddress = (__bridge NSString *)CSIdentityGetEmailAddress(identity);
        NSArray *aliases = (__bridge NSArray *)CSIdentityGetAliases(identity);
        NSURL *imageURL = (__bridge NSURL *)CSIdentityGetImageURL(identity);
        BOOL isEnabled = (BOOL)CSIdentityIsEnabled(identity);

        /* Fetch all the modified values for the current identity */
        NSString *_newFullName = [self.fullName stringValue];
        NSString *_newEmailAddress = [self.emailAddress stringValue];
        NSString *imageURLString = [self.imageURL stringValue];
        NSURL *_newImageURL = [NSURL fileURLWithPath:imageURLString];
        BOOL _newIsEnabled = [self.isEnabled state];

        /* If any of these values have changed, then return YES */
        if (![fullName isEqual:_newFullName])
        {
            wasChanged = YES;
        }
        else if (!((!emailAddress && [_newEmailAddress length] == 0) ||
            (emailAddress && [emailAddress isEqual:_newEmailAddress])))
        {
            wasChanged = YES;
        }
        else if (!((!imageURL && !_newImageURL) || (imageURL && [imageURL isEqual:_newImageURL])))
        {
            wasChanged = YES;
        }
        else if (!((!aliases && [self.aliases count] == 0) || (aliases && [aliases isEqual:self.aliases])))
        {
            wasChanged = YES;
        }
        else if (isEnabled != _newIsEnabled)
        {
            wasChanged = YES;
        }
    }

    return wasChanged;
}

- (void)updateApplyAndRevert
{
    /* If any of the current identity info has changed, enable the Apply and Revert buttons */
    BOOL modified = [self wasIdentityChanged];
    self.applyNowButton.enabled = modified;
    self.revertButton.enabled = modified;
}

- (IBAction)generatePosixNameToggled:(id)sender
{
    if ([sender state])
    {
        [self.addIdentityPosixNameLabel setTextColor:[NSColor lightGrayColor]];
        self.addIdentityPosixName.enabled = NO;
    }
    else
    {
        [self.addIdentityPosixNameLabel setTextColor:[NSColor blackColor]];
        self.addIdentityPosixName.enabled = YES;
    }
}

- (IBAction)enableToggled:(id)sender
{
    [self updateApplyAndRevert];
}

- (void)identityDidChange:(NSNotification *)notification
{
    [self updateApplyAndRevert];
}

- (void)endAliasEditing
{
    [self.aliasesTableView deselectAll:self];
    [self.aliasesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.aliases.count - 1] byExtendingSelection:NO];
    [self updateApplyAndRevert];
}

- (void)aliasEditingDidEnd:(NSNotification *)notification
{
    [self performSelector:@selector(endAliasEditing) withObject:nil afterDelay:0.0];
}

- (void)identityTableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger currentIndex = [self.identityTableView selectedRow];

    if (currentIndex == -1)
    {
        self.removeIdentityButton.enabled = NO;
    }
    else
    {
        self.removeIdentityButton.enabled = YES;
    }

    [self reloadIdentityAtIndex:currentIndex];
}

- (void)aliasesTableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger currentIndex = [self.aliasesTableView selectedRow];

    if (currentIndex == -1)
    {
        self.removeAliasButton.enabled = NO;
    }
    else
    {
        self.removeAliasButton.enabled = YES;
    }
}

- (void)awakeFromNib
{
    self.identityQuery = NULL;
    self.userImage = [NSImage imageNamed:@"User"];
    self.groupImage = [NSImage imageNamed:@"Group"];
    self.queryStartTimer = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(identityTableViewSelectionDidChange:)
        name:NSTableViewSelectionDidChangeNotification object:self.identityTableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(identityTableViewSelectionDidChange:)
        name:NSTableViewSelectionIsChangingNotification object:self.identityTableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aliasesTableViewSelectionDidChange:)
        name:NSTableViewSelectionDidChangeNotification object:self.aliasesTableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aliasEditingDidEnd:)
        name:NSControlTextDidEndEditingNotification object:self.aliasesTableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:)
        name:NSControlTextDidChangeNotification object:self.searchText];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(identityDidChange:)
        name:NSControlTextDidChangeNotification object:self.fullName];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(identityDidChange:)
        name:NSControlTextDidChangeNotification object:self.emailAddress];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(identityDidChange:)
        name:NSControlTextDidChangeNotification object:self.imageURL];

    [self.mainWindow makeFirstResponder:self.identityTableView];

    /* Start a new identity query and search for all identities by passing in empty string */
    [self queryForIdentitiesByName:@""];
}


- (void)dealloc
{
    [self.queryStartTimer invalidate];
}

- (IBAction)classPopUpChanged:(id)sender
{
    BOOL hide = (BOOL)[sender indexOfSelectedItem];
    self.addIdentityPassword.hidden = hide;
    self.addIdentityVerify.hidden = hide;
    self.addIdentityVerify.hidden = hide;
    self.addIdentityPasswordLabel.hidden = hide;
    self.addIdentityVerifyLabel.hidden = hide;
    self.generatePosixNameButton.hidden = hide;
    self.addIdentityPosixNameLabel.hidden = hide;
    self.addIdentityPosixName.hidden = hide;

    if (hide)
    {
        [self.addIdentityWindow makeFirstResponder:self.addIdentityFullName];
    }
}

- (IBAction)createIdentity:(id)sender
{
    /* Only allow identities to be created if the Full Name is at least one character */
    if (self.addIdentityFullName.stringValue.length)
    {
        CSIdentityClass class = [self.addIdentityClassPopUp indexOfSelectedItem] + 1;
        if (class == kCSIdentityClassGroup)
        {
            [[NSApplication sharedApplication] endSheet:self.addIdentityWindow returnCode:NSModalResponseOK];
        }
        else if (class == kCSIdentityClassUser)
        {
            /* Only proceed if the Password and the Verify field contain the same value */
            if ([[self.addIdentityPassword stringValue] isEqual:self.addIdentityVerify.stringValue])
            {
                BOOL generatePosixName = self.generatePosixNameButton.state;

                /* Only proceed if Generate Posix Name is set or if Posix name is at least one character */
                if (generatePosixName || (!generatePosixName && self.addIdentityPosixName.stringValue.length))
                {
                    [[NSApplication sharedApplication] endSheet:self.addIdentityWindow returnCode:NSModalResponseOK];
                }
            }
        }
    }
}

- (IBAction)cancelIdentity:(id)sender
{
    [[NSApplication sharedApplication] endSheet:self.addIdentityWindow returnCode:NSModalResponseCancel];
}

- (void)addIdentitySheetDidEnd:(NSModalResponse)returnCode
{
    if (returnCode == NSModalResponseOK)
    {
        NSString *fullName = self.addIdentityFullName.stringValue;

        if ([fullName length])
        {
            CFErrorRef error;
            CSIdentityClass class = [self.addIdentityClassPopUp indexOfSelectedItem] + 1;
            CFStringRef posixName = self.generatePosixNameButton.state ?
                kCSIdentityGeneratePosixName : (__bridge CFStringRef)self.addIdentityPosixName.stringValue;

            /* Create a brand new identity */
            CSIdentityRef identity = CSIdentityCreate(NULL, class, (__bridge CFStringRef)fullName, posixName,
                kCSIdentityFlagNone, CSGetLocalIdentityAuthority());
            if (class == kCSIdentityClassUser)
            {
                /* If this is a user identity, add a password */
                CSIdentitySetPassword(identity, (__bridge CFStringRef)self.addIdentityPassword.stringValue);
            }

            /* Commit the new identity to the identity store */
            if (!CSIdentityCommit(identity, NULL, &error))
            {
                NSLog(@"CSIdentityCommit returned error %@ userInfo %@)", error, [(__bridge NSError*)error userInfo] );
            }
            [self queryForIdentitiesByName:self.searchText.stringValue];
        }
    }

    self.addIdentityFullName.stringValue = @"";
    self.addIdentityPosixName.stringValue = @"";
    self.addIdentityPassword.stringValue = @"";
    self.addIdentityVerify.stringValue = @"";
    self.generatePosixNameButton.state = YES;
}

- (IBAction)addIdentity:(id)sender
{
    [self.addIdentityWindow makeFirstResponder:self.addIdentityFullName];
    self.generatePosixNameButton.state = YES;
    self.addIdentityPosixNameLabel.textColor = [NSColor lightGrayColor];
    self.addIdentityPosixName.enabled = NO;

    [self.mainWindow beginSheet:self.addIdentityWindow completionHandler:
        ^(NSModalResponse returnCode)
        {
            [self addIdentitySheetDidEnd:returnCode];
        }];
}

- (void)alertDidEnd:(NSModalResponse)returnCode
{
    if (returnCode == NSAlertFirstButtonReturn)
    {
        NSInteger currentIndex = [self.identityTableView selectedRow];

        if (currentIndex != -1)
        {
            NSUInteger count = self.identities.count;
            CSIdentityRef identity = (__bridge CSIdentityRef)[self.identities objectAtIndex:currentIndex];

            /* Don't allow us to delete the currently logged-in user */
            if (getuid() != CSIdentityGetPosixID(identity))
            {
                CFErrorRef error;

                /* Delete the currently selected identity */
                CSIdentityDelete(identity);

                /* Commit the change back to the identity store */
                if (CSIdentityCommit(identity, NULL, &error))
                {
                    [self queryForIdentitiesByName:[self.searchText stringValue]];
                    NSUInteger indexToSelect = ((NSUInteger)currentIndex == count && currentIndex > 0) ?
                        (currentIndex - 1) : currentIndex;
                    [self.identityTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexToSelect]
                        byExtendingSelection:NO];
                }
                else
                {
                    NSLog(@"CSIdentityCommit returned error %@ userInfo %@)", error, [(__bridge NSError*)error userInfo]);
                }
            }
            else
            {
                NSLog(@"Deleting the currently logged-in user is a bad idea");
            }
        }
    }
}

- (IBAction)removeIdentity:(id)sender
{
    NSString *currentFullName = (__bridge NSString *)CSIdentityGetFullName((__bridge CSIdentityRef)[self.identities
        objectAtIndex:[self.identityTableView selectedRow]]);
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to delete the identity \"%@\"?",
        currentFullName]];
    [alert setInformativeText:@"You better be sure because this can't be undone."];
    [alert beginSheetModalForWindow:self.mainWindow completionHandler:
        ^(NSModalResponse returnCode)
        {
            [self alertDidEnd:returnCode];
        }];
}

- (IBAction)addAlias:(id)sender
{
    NSUInteger lastRow = self.aliases.count;
    [self.aliases addObject:@""];
    [self.aliasesTableView reloadData];
    [self.mainWindow makeFirstResponder:self.aliasesTableView];
    [self.aliasesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:lastRow] byExtendingSelection:NO];
    [self.aliasesTableView editColumn:0 row:lastRow withEvent:nil select:YES];
}

- (IBAction)removeAlias:(id)sender
{
    NSIndexSet *selected = [self.aliasesTableView selectedRowIndexes];
    NSUInteger lastRow = [selected lastIndex];
    [self.aliases removeObjectsAtIndexes:selected];
    [self.aliasesTableView reloadData];
    [self.aliasesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:lastRow - 1] byExtendingSelection:NO];
    [self updateApplyAndRevert];
}

- (void)setAliases:(NSArray *)aliases forIdentity:(CSIdentityRef)identity
{
    CFArrayRef currentAliases = CFArrayCreateCopy(NULL, CSIdentityGetAliases(identity));
    CFIndex index, count = CFArrayGetCount(currentAliases);

    /* First remove all the current aliases for this identity */
    for (index = 0; index < count; index++)
    {
        CSIdentityRemoveAlias(identity, (CFStringRef)CFArrayGetValueAtIndex(currentAliases, index));
    }

    /* Then add all the new aliases for this identity */
    count = aliases ? [aliases count] : 0;
    for (index = 0; index < count; index++)
    {
        CSIdentityAddAlias(identity, (__bridge CFStringRef)[aliases objectAtIndex:index]);
    }

    CFRelease(currentAliases);
}

- (IBAction)apply:(id)sender
{
    NSInteger currentIndex = [self.identityTableView selectedRow];

    if (currentIndex != -1)
    {
        CFErrorRef error;
        CSIdentityRef identity = (__bridge CSIdentityRef)[self.identities objectAtIndex:currentIndex];

        CFStringRef fullName = (__bridge CFStringRef)self.fullName.stringValue;
        CFStringRef emailAddress = (__bridge CFStringRef)self.emailAddress.stringValue;
        NSString *imageURLString = self.imageURL.stringValue;
        CFURLRef imageURL = (__bridge CFURLRef)[NSURL fileURLWithPath:imageURLString];
        Boolean isEnabled = (Boolean)self.isEnabled.state;

        if (fullName)
        {
            CSIdentitySetFullName(identity, fullName);
        }
        CSIdentitySetEmailAddress(identity, CFStringGetLength(emailAddress) ? emailAddress : NULL);
        CSIdentitySetImageURL(identity, imageURL);
        [self setAliases:self.aliases forIdentity:identity];

        /* Don't allow us to disable the currently logged-in user */
        if (getuid() == CSIdentityGetPosixID(identity) && isEnabled == NO)
        {
            NSLog(@"Disabling the currently logged-in user is a bad idea");
            [self.isEnabled setState:YES];
        }
        else
        {
            CSIdentitySetIsEnabled(identity, isEnabled);
        }

        /* Commit the changes back to the identity store */
        if (!CSIdentityCommit(identity, NULL, &error))
        {
            NSLog(@"CSIdentityCommit returned error %@ userInfo %@)", error, [(__bridge NSError*)error userInfo]);
        }
        else
        {
            [self updateApplyAndRevert];
        }
    }

    [self.mainWindow makeFirstResponder:self.identityTableView];
}

- (IBAction)revert:(id)sender
{
    [self.mainWindow makeFirstResponder:self.identityTableView];
    [self reloadIdentityAtIndex:[self.identityTableView selectedRow]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tv
{
    NSInteger count = 0;

    if (tv == self.identityTableView)
    {
        count = self.identities.count;
    }
    else if (tv == self.aliasesTableView)
    {
        count = self.aliases.count;
    }

    return count;
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    id value = nil;

    if (tv == self.identityTableView)
    {
        CSIdentityRef identity = (__bridge CSIdentityRef)[self.identities objectAtIndex:row];
        if ([[tableColumn identifier] isEqual:@"Icon"])
        {
            CSIdentityClass class = CSIdentityGetClass(identity);
            if (class == kCSIdentityClassUser)
            {
                value = self.userImage;
            }
            else if (class == kCSIdentityClassGroup)
            {
                value = self.groupImage;
            }
        }
        else if ([[tableColumn identifier] isEqual:@"Name"])
        {
            value = (__bridge NSString *)CSIdentityGetFullName(identity);
        }
    }
    else if (tv == self.aliasesTableView)
    {
        value = [self.aliases objectAtIndex:row];
    }

    return value;
}

- (void)removeAliases:(NSIndexSet *)set
{
    [self.aliases removeObjectsAtIndexes:set];
    [self.aliasesTableView reloadData];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn
    row:(int)row
{
    if (tableView == self.aliasesTableView)
    {
        if ([object length])
        {
            [self.aliases replaceObjectAtIndex:row withObject:object];
        }
        else
        {
            [self performSelector:@selector(removeAliases:) withObject:[NSIndexSet indexSetWithIndex:row]
                afterDelay:0.0];
        }
    }

    [self.aliasesTableView deselectAll:self];
}

- (void)confirmPanelDidClose:(NSModalResponse)returnCode selectedRow:(NSInteger)selectedRow
{
    if (returnCode == NSAlertFirstButtonReturn)
    {
        [self apply:self];
    }

    if (returnCode != NSAlertSecondButtonReturn)
    {
        [self.identityTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    BOOL shouldSelect = YES;
    if (tableView == self.identityTableView)
    {
        if ([self wasIdentityChanged] && [self.identityTableView selectedRow] != row)
        {
            NSString *currentFullName = (__bridge NSString *)CSIdentityGetFullName((__bridge CSIdentityRef)[self.identities
                objectAtIndex:[self.identityTableView selectedRow]]);
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSAlertStyleInformational];
            [alert addButtonWithTitle:@"Apply"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert addButtonWithTitle:@"Don't Apply"];
            [alert setMessageText:[NSString stringWithFormat:@"Apple changes to identity \"%@\"?", currentFullName]];
            [alert setInformativeText:@"Click Apply if you'd like to save the changes for this identity."];
            [alert beginSheetModalForWindow:self.mainWindow completionHandler:
                ^(NSModalResponse returnCode)
                {
                    [self confirmPanelDidClose:returnCode selectedRow:row];
                }];
            shouldSelect = NO;
        }
    }
    return shouldSelect;
}

@end
