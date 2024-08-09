//
//  IUIdentityAdapter.h
//  IdentitySample
//
//  Created by Danil Korotenko on 8/9/24.
//

#pragma once

#include <string>

bool IUIdentityUserExist(const std::string &aUserName);

bool IUIdentityAddAdminUser(const std::string &aUserName, const std::string &aPassword,
    std::string &errorDescription);
bool IUIdentityDeleteUser(const std::string &aUserName, std::string &errorDescription);
