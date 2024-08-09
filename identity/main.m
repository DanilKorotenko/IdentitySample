//
//  main.m
//  identity
//
//  Created by Danil Korotenko on 8/9/24.
//

#import <Foundation/Foundation.h>
#import "../IdentityUtilities/IUIdentityQuery.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hello, identity!");

//        NSLog(@"local users:");
//        NSLog(@"%@", [IUIdentityQuery localUsers]);

        IUIdentity *testUser = [IUIdentityQuery localUserWithFullName:@"testUser"];
        if (testUser)
        {
            NSLog(@"testUser exist: %@", testUser);
            NSLog(@"delete testUser");
            [testUser deleteIdentity];
            NSError *error = nil;
            if ([testUser commit:&error])
            {
                NSLog(@"testUser delete successfully");
            }
            else
            {
                NSLog(@"Error occured on commit identity: %@", error);
            }
        }
        else
        {
            NSLog(@"Create testUser");
            testUser = [IUIdentity newHiddenUserWithFullName:@"testUser" password:@"pass123456"];
            NSError *error = nil;
            if ([testUser commit:&error])
            {
                NSLog(@"testUser added successfully");
            }
            else
            {
                NSLog(@"Error occured on commit identity: %@", error);
            }
        }
    }
    return 0;
}
