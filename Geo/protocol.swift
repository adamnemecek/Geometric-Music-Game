//
//  protocol.swift
//  Touch Music
//
//  Created by Rodrigo Leite on 10/18/15.
//  Copyright © 2015 Kobe. All rights reserved.
//

import Foundation
import SceneKit

enum GeometryType {
    case CIRCLE, TRIANGLE, SQUARE
}


protocol GeometryFactory{
    
    func buildGeometry(type: GeometryType) -> SCNNode
    
}