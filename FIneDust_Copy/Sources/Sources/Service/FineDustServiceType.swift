//
//  FineDustServiceType.swift
//  FineDust_Copy
//
//  Created by 승진김 on 25/02/2019.
//  Copyright © 2019 승진김. All rights reserved.
//

import Foundation
import Alamofire

protocol FineDustServiceType {
    func requestFineDustInfo(sido: String, completion: @escaping (Result<FineDustModel>) -> ())
}
