//
//  StandartURLs.swift
//  Sigma
//
//  Created by Sania on 10.09.16.
//  Copyright © 2016 Fructose Tech. All rights reserved.
//

import Foundation

//MARK: -
func DOCUMENTS_URL() -> URL {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls.last!
}

func CACHE_URL() -> URL {
    let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    return urls.last!
}
