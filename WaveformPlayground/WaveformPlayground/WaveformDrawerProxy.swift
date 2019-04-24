//
//  WaveformDrawerProxy.swift
//  WaveformPlayground
//
//  Created by haozes on 2019/4/23.
//  Copyright © 2019 Dejoe John. All rights reserved.
//

import Foundation
import UIKit


class WavefromDrawerProxy {
    var drawer:WavefromDrawer!
    private var image:UIImageView!
    
    init(image:UIImageView) {
        self.image = image
        self.drawer = WavefromDrawer()
    }
    
    func updateWithLevel(level:Float){
        let rect = self.image.bounds
        let size = rect.size
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        self.drawer.drawLevel(context: context!, rect: rect, level: level)
        let cgImage = context?.makeImage()
        let uiImage = UIImage(cgImage: cgImage!)
        UIGraphicsEndImageContext()
        
        self.image.image = uiImage
    }
    
}


