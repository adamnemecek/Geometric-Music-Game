//
//  Extension.swift
//  Touch Music
//
//  Created by Rodrigo Leite on 10/18/15.
//  Copyright © 2015 Kobe. All rights reserved.
//

import Foundation
import SceneKit


//public let rawValue : Int
//public init(rawValue:Int){ self.rawValue = rawValue}
//
//static let Up  = Directions(rawValue:1)
//static let Down  = Directions(rawValue:2)
//static let Left = Directions(rawValue:4)
//static let Right = Directions(rawValue:8)


struct CollisionCategory: OptionSetType {
    
    internal let rawValue : Int
    internal init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let CAM     = CollisionCategory(rawValue: Int(1 << 0))
    static let PLAYER  = CollisionCategory(rawValue: Int(1 << 1))
    static let ENEMIE  = CollisionCategory(rawValue: Int(1 << 2))
    static let FIELD   = CollisionCategory(rawValue: Int(1 << 3))
    
}



extension UIColor{
    
    class func MusicDarkBlue() -> UIColor{
        return UIColor(red: CGFloat(26)/255.0, green: CGFloat(31)/255.0, blue: CGFloat(43)/255.0, alpha: 1.0)
    }
    
    class func MusicBoldBlue() -> UIColor{
        return UIColor(red: CGFloat(48)/255.0, green: CGFloat(57)/255.0, blue: CGFloat(92)/255.0, alpha: 1.0)
    }
    
    class func MusicMiddleBlue() -> UIColor{
        return UIColor(red: CGFloat(74)/255.0, green: CGFloat(100)/255.0, blue: CGFloat(145)/255.0, alpha: 1.0)
    }
    
    class func MusicLightBlue() -> UIColor{
        return UIColor(red: CGFloat(133)/255.0, green: CGFloat(165)/255.0, blue: CGFloat(204)/255.0, alpha: 1.0)
    }
    
    class func MusicIceBlue() -> UIColor{
        return UIColor(red: CGFloat(208)/255.0, green: CGFloat(228)/255.0, blue: CGFloat(242)/255.0, alpha: 1.0)
    }
    
    class func RandomColor() -> UIColor{
        let red = arc4random_uniform(256)
        let green = arc4random_uniform(256)
        let blue = arc4random_uniform(256)
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
        
        
    }
    
    
}