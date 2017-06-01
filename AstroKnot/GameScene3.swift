//
//  File.swift
//  AstroKnot
//
//  Created by Lew Flauta on 5/31/17.
//  Copyright © 2017 Lew Flauta. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene3: SKScene {

    let playableRect: CGRect
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0




    

    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width * maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {



    }

    override func update(_ currentTime: TimeInterval){
        //this function smoothes out the movment updates
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
  
    }

    func spawn(character: SKNode, x: CGFloat, y: CGFloat) {

    }
    
}
