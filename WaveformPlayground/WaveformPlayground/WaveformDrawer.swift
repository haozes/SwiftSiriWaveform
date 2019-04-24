//
//  WaveformDrawer.swift
//  WaveformPlayground
//
//  Created by haozes on 2019/4/23.
//  Copyright © 2019 Dejoe John. All rights reserved.
//

import Foundation

#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

class WavefromDrawer {
    /*
     * The frequency of the sinus wave. The higher the value, the more sinus wave peaks you will have.
     * Default: 1.5
     */
     var frequency:Float = 1.5
    
    /*
     * The amplitude that is used when the incoming amplitude is near zero.
     * Setting a value greater 0 provides a more vivid visualization.
     * Default: 0.01
     */
     var idleAmplitude:Float = 0.01
    
    /*
     * The phase shift that will be applied with each level setting
     * Change this to modify the animation speed or direction
     * Default: -0.15
     */
     var phaseShift:Float = -0.15
    
    /*
     * The lines are joined stepwise, the more dense you draw, the more CPU power is used.
     * Default: 5
     */
     var density:Float = 5.0
    
    /*
     * Line width used for the prominent wave
     * Default: 1.5
     */
     var primaryLineWidth:Float = 3
    
    /*
     * Line width used for all secondary waves
     * Default: 0.5
     */
     var secondaryLineWidth:Float = 1
    
    
    /*
     * The total number of waves
     * Default: 5
     */
     var numberOfWaves:Int = 1
    
    /*
     * Color to use when drawing the waves
     * Default: white
     */
     var waveColor:UIColor =  UIColor(red: 0.33, green: 0.36, blue: 1, alpha: 1)
     var startColor: UIColor = UIColor(red: 0.33, green: 0.36, blue: 1, alpha: 1)
    var endColor: UIColor = UIColor(red: 0.33, green: 0.36, blue: 1, alpha: 0.0)
    
    /*
     * The current amplitude.
     */
     var amplitude:Float = 1.0
    
    var phase:Float = 0.0
    
    private func creatGradient() -> CGGradient{
        
        let colors = [startColor.cgColor, endColor.cgColor]
        
        // 3
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 4
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        // 5
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        return gradient
        
    }
    func drawLevel(context: CGContext, rect: CGRect,level:Float)  {
        self.phase += self.phaseShift
        self.amplitude = fmax(level, self.idleAmplitude)
        
        let bounds = rect
     
        context.clear(bounds)
       // self.backgroundColor?.set()
    
        context.fill(rect)
        var i:Int = 0;
        while(i < self.numberOfWaves) {
            let strokeLineWidth = (i == 0 ? self.primaryLineWidth : self.secondaryLineWidth)
            let graphPath = UIBezierPath()
           //context.setLineWidth(CGFloat(Float(strokeLineWidth)))
            graphPath.lineWidth = CGFloat(strokeLineWidth)
    
            
            let halfHeight = Float(bounds.height) / 2;
            let width = Float(bounds.width)
            let mid = width/2
            
            let maxAmplitude:Float = halfHeight - (strokeLineWidth*2)
            
            let progress:Float = 1 - Float(i)/Float(self.numberOfWaves)
            let normedAmplitude = (1.5 * progress - (2/Float(self.numberOfWaves))) * self.amplitude
            let multipler:Float = min(1, (progress / 3.0 * 2.0) + (1.0/3.0))
            
            self.waveColor.withAlphaComponent(CGFloat(multipler * Float(waveColor.cgColor.alpha))).set()
            
            var x:Float = Float(0);
            while (x < width + self.density) {
                let scaling:Float = Float(-pow(1/mid*(x-mid), 2) + 1)
                let y: Float = scaling * maxAmplitude * normedAmplitude * sinf(2.0 * Float(Double.pi) * (x/width) * self.frequency + self.phase) + halfHeight;
                
                let xTemp = x
                let yTemp = y
                if(x == 0){
                    graphPath.move(to: CGPointMake(xTemp, yTemp))
                } else {
                    graphPath.addLine(to: CGPointMake(xTemp, yTemp))
                }
                x += self.density
            }
            
            context.addPath(graphPath.cgPath)
            graphPath.stroke()
            context.saveGState()
            
            let clippingPath = graphPath.copy() as! UIBezierPath
            clippingPath.addLine(to: CGPoint(x: CGFloat(x), y:bounds.height))
            clippingPath.addLine(to: CGPoint(x:0, y:bounds.height))
            clippingPath.close()
            
            //4 - add the clipping path to the context
            clippingPath.addClip()
            
            let startPoint = CGPoint(x:0.0, y: 0)
            let endPoint = CGPoint(x:0, y:bounds.height)
            let gradient = self.creatGradient()
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            context.restoreGState()
            
          
            i+=1
        }
    }
}


