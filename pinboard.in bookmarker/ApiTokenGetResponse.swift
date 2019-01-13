//
//  ExtensionApiTokenAccessResponse.swift
//  pinboard.in bookmarker Extension
//
//  Created by Kristof Adriaenssens on 13/01/2019.
//  Copyright © 2019 Kristof Adriaenssens. All rights reserved.
//

import Foundation

enum ApiTokenGetResponse {
    case Success(String)
    case ErrorApiTokenItemNotFound
    case ErrorUnexpectedApiTokenData
    case ErrorUnknown(OSStatus)
}
