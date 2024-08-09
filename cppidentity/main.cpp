//
//  main.cpp
//  cppidentity
//
//  Created by Danil Korotenko on 8/9/24.
//

#include <iostream>
#include "../IdentityUtilities/IUIdentityAdapter.h"

int main(int argc, const char * argv[])
{
    std::cout << "Hello, cpp identity!" << std::endl;

    std::string userName = "testUser";
    std::string password = "pass123456";
    std::string errorDescription;
    if (IUIdentityUserExist(userName))
    {
        std::cout << "user exist" << std::endl;
        std::cout << "delete user" << std::endl;
        if (!IUIdentityDeleteUser(userName, errorDescription))
        {
            std::cout << "delete user error: " << errorDescription.c_str() << std::endl;
        }
    }
    else
    {
        std::cout << "add user" << std::endl;
        if (!IUIdentityAddAdminUser(userName, password, errorDescription))
        {
            std::cout << "add user error: " << errorDescription.c_str() << std::endl;
        }
    }

    return 0;
}
