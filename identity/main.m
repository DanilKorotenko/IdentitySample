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

        NSLog(@"local users:");
        NSLog(@"%@", [IUIdentityQuery localUsers]);

    }
    return 0;
}
