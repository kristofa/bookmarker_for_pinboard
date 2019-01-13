//
//  ApiTokenAccessResponse.swift
//  pinboard.in bookmarker
//
//  Created by Kristof Adriaenssens on 13/01/2019.
//  Copyright © 2019 Kristof Adriaenssens. All rights reserved.
//

import Foundation

enum ApiTokenCreateOrUpdateResponse {
    case Success
    case ErrorCreatingTrustedApplicationsFailed(OSStatus, OSStatus)
    case ErrorCreatingSecAccess(OSStatus)
    case ErrorCreatingOrUpdatingApiToken(OSStatus)
}
