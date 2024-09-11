//
//  IUIdentityAdapter.m
//  IdentitySample
//
//  Created by Danil Korotenko on 8/9/24.
//

#import "IUIdentityQuery/IUIdentityQuery.h"

#include <string>

bool IUIdentityUserExist(const std::string &aUserName)
{
    NSString *userName = [NSString stringWithUTF8String:aUserName.c_str()];
    IUIdentity *user = [IUIdentity localUserWithFullName:userName];
    if (user)
    {
        return true;
    }
    return false;
}

bool IUIdentityAddAdminUser(const std::string &aUserName, const std::string &aPassword, std::string &errorDescription)
{
    NSString *userName = [NSString stringWithUTF8String:aUserName.c_str()];
    NSString *userPass = [NSString stringWithUTF8String:aPassword.c_str()];

    IUIdentity *user = [IUIdentity newHiddenUserWithFullName:userName password:userPass];

    NSError *error = nil;
    if (![user commit:&error])
    {
        errorDescription = std::string([[error description] UTF8String]);
        return false;
    }

    IUIdentity *administrators = [IUIdentity administratorsGroup];
    if (!administrators)
    {
        errorDescription = "No administrators group";
        return false;
    }

    [administrators addMember:user];

    if (![administrators commit:&error])
    {
        errorDescription = "No administrators group";
        return false;
    }
    return true;
}

bool IUIdentityDeleteUser(const std::string &aUserName, std::string &errorDescription)
{
    NSString *userName = [NSString stringWithUTF8String:aUserName.c_str()];
    IUIdentity *testUser = [IUIdentity localUserWithFullName:userName];
    if (testUser)
    {
        [testUser deleteIdentity];
        NSError *error = nil;
        if (![testUser commit:&error])
        {
            errorDescription = std::string([[error description] UTF8String]);
            return false;
        }
    }
    return true;
}

bool IUCurrentUserIsAdmin()
{
    return [IUIdentity currentUser].isAdmin ? true : false;
}
