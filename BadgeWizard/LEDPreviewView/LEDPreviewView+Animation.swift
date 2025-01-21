//
//  LEDPreviewView+asd.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
extension LEDPreviewView {
    internal func displayAnimation() {
        let badgeHeight = 11
        let badgeWidth = 44
        let displayWidth = min(pixels[0].count, badgeWidth)
        let horizontalOffset = (badgeWidth - displayWidth) / 2
        
        // Add pause phase: total length is now badge width + pause length
        let pauseLength = 20
        let totalAnimationLength = badgeWidth + pauseLength
        let currentStep = Int(currentPosition) % totalAnimationLength
        
        let revealPhase = currentStep < badgeWidth / 2
        let pausePhase = currentStep >= badgeWidth / 2 && currentStep < badgeWidth / 2 + pauseLength
        let hidePhase = currentStep >= badgeWidth / 2 + pauseLength
        
        let leftCenterCol = badgeWidth / 2 - 1
        let rightCenterCol = badgeWidth / 2
        let maxDistance = leftCenterCol
        
        let currentAnimationIndex = if hidePhase {
            currentStep - (badgeWidth / 2 + pauseLength)
        } else {
            currentStep % (maxDistance + 1)
        }
        
        var leftColPos = leftCenterCol - currentAnimationIndex
        var rightColPos = rightCenterCol + currentAnimationIndex
        
        if leftColPos < 0 { leftColPos += badgeWidth }
        if rightColPos >= badgeWidth { rightColPos -= badgeWidth }
        
        for i in 0..<badgeHeight {
            for j in 0..<badgeWidth {
                let lineShow = !pausePhase && (j == leftColPos || j == rightColPos)
                var bitmapShowCenter = false
                var bitmapShowOut = false
                
                let sourceCol = j - horizontalOffset
                let isWithinNewGrid = sourceCol >= 0 && sourceCol < displayWidth
                
                if pausePhase {
                    if isWithinNewGrid {
                        displayBuffer.set(j, i, pixels[i][sourceCol].isOn)
                    }
                    continue
                }
                
                if revealPhase {
                    if isWithinNewGrid && j > leftColPos && j < rightColPos {
                        bitmapShowCenter = pixels[i][sourceCol].isOn
                    }
                }
                
                if hidePhase {
                    if isWithinNewGrid && (j < leftColPos || j > rightColPos) {
                        bitmapShowOut = pixels[i][sourceCol].isOn
                    }
                }
                
                displayBuffer.set(j, i, lineShow || bitmapShowOut || bitmapShowCenter)
            }
        }
    }
}
