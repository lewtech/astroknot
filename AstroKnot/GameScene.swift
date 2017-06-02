//llewellyn flauta csc 491 hw3
//obstacles from from top downward...but blocking them off, don't need

import SpriteKit
//import CoreMotion

class GameScene: SKScene {
    var nextIcon = SKSpriteNode(imageNamed: "next")
    var hero = SKSpriteNode(imageNamed: "Spaceship")
    let obstacle = SKSpriteNode(imageNamed: "obstacle")
    let astronaut = SKSpriteNode(imageNamed: "astronaut")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let heroMovePointsPerSec: CGFloat = 250.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var astronautCount = 0
    var astronautsSaved = 0
    var gameOver = false

    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width * maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        super.init(size: size)
    }



    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }




    override func didMove(to view: SKView) {

        //initialize objects, and start looping actions. References are weak so that when the child objects are removed the memory is freed
        backgroundColor = SKColor.black
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //setupCoreMotion()
        nextIcon.setScale(0.5)
        nextIcon.position = CGPoint(x:(size.width - 100 ), y:(size.height - 100))
        addChild(nextIcon)

        spawnHero()
    //introAstronautSprite()
        // spawnObstacle()
         spawnAstronaut()

/*        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnObstacle()
                },
                               SKAction.wait(forDuration: 2.0)])))

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnAstronaut()
                },
                               SKAction.wait(forDuration: 4.3)])))
 */


    }


    override func update(_ currentTime: TimeInterval){
        //this function smoothes out the movment updates
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime



        //move the ship
        move(sprite: hero, velocity: velocity)
        boundsCheckHero()
        //rotate the ship in direction of the move on touches
        rotate(sprite: hero, direction: velocity)
        checkCollisions()
        //print (hero.position)
    }



    //MARK: MOVEMENT

    func move (sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))

        sprite.position += amountToMove
    }

    func MoveHeroToward(location: CGPoint) {
        let offset = location - hero.position
        let direction = offset.normalized()
        velocity = direction * heroMovePointsPerSec
        //physicsWorld.gravity =  CGVector (dx: 0, dy: 0)
        //use some type of friction here
    }

    //MARK: TOUCH EVENTS

    
    func sceneTouched (touchLocation:CGPoint){
        MoveHeroToward(location: touchLocation)

    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hero.physicsBody?.affectedByGravity = false
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation:
            touchLocation)

        if nextIcon.contains(touch.location(in: self)){
            let transition = SKTransition.reveal(with: .left, duration:1.0)
            let nextScene = GameScene1(size: size)
            nextScene.scaleMode = scaleMode
            view?.presentScene(nextScene, transition: transition)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        hero.physicsBody?.affectedByGravity = true
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation:
            touchLocation)
    }

    func boundsCheckHero() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)

        //reverses the velocity of the hero when a bound is hit

        if hero.position.x <= bottomLeft.x {
            hero.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if hero.position.x >= topRight.x {
            hero.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if hero.position.y <= bottomLeft.y {
            hero.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if hero.position.y >= topRight.y {
            hero.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }

    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = direction.angle
        //print (sprite.zRotation)
    }

    //MARK: COREMOTION
    //    func setupCoreMotion() {
    //        motionManager.accelerometerUpdateInterval = 0.2
    //        let queue = OperationQueue()
    //        motionManager.startAccelerometerUpdates(to: queue, withHandler:
    //            {
    //                accelerometerData, error in
    //                guard let accelerometerData = accelerometerData else{
    //                    return
    //                }
    //                let acceleration = accelerometerData.acceleration
    //                self.xAcceleration = (CGFloat(acceleration.x) * 0.75) +
    //                    (self.xAcceleration * 0.25)
    //                self.yAcceleration = (CGFloat(acceleration.y) * 0.75) +
    //                    (self.yAcceleration * 0.25)
    //        })
    //    }

    //MARK: SPAWN-CREATE

    func spawnHero(){
        //create spaceship, give spaceship a physicsBody
        hero = SKSpriteNode(imageNamed: "Spaceship")

        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.width / 2)
        hero.physicsBody!.allowsRotation = true
        hero.physicsBody!.linearDamping = 5.0
        hero.position = CGPoint (x: 150, y: 150)
//        hero.position = CGPoint(x: 96, y: 0)
        hero.setScale(0.33)
        hero.name = "hero"
        addChild(hero)

        //let wait = SKAction.wait(forDuration: 0.25)
//        let moveRandom = SKAction.moveBy(x: CGFloat.random(
//            min: playableRect.minX + obstacle.size.height/2,
//            max: playableRect.maxX - obstacle.size.height/2), y:CGFloat.random(min: playableRect.minY + obstacle.size.height/2,
//                                                                             max: playableRect.maxY - obstacle.size.height/2), duration: 0.25)
        //let sequence = SKAction.sequence([moveRandom,wait])
        //hero.run(sequence)


    }

    func introAstronautSprite() {
        let astronaut = SKSpriteNode(imageNamed: "astronaut")
        astronaut.name = "astronaut"
        astronaut.position = CGPoint(
            x: CGFloat.random(
                min: playableRect.minY + obstacle.size.height/2,
                max: playableRect.maxY - obstacle.size.height/2),
            y: CGFloat.random(
                min: playableRect.minY + obstacle.size.height/2,
                max: playableRect.maxY - obstacle.size.height/2))
        //astronaut.setScale(2.0)
        addChild(astronaut)

        let actionMove = SKAction.moveBy(x: CGFloat.random(
            min: playableRect.minX + obstacle.size.height/2,
            max: playableRect.maxX - obstacle.size.height/2), y:CGFloat.random(min: playableRect.minY + obstacle.size.height/2,
                                                                               max: playableRect.maxY - obstacle.size.height/2), duration: 2.0)
        let wait = SKAction.wait(forDuration: 5.0)
        let actionRotate = SKAction.rotate(byAngle: 1.0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        astronaut.run(SKAction.sequence([actionRotate, actionRemove]))

    }

    func spawnObstacle() {
/*        let obstacle = SKSpriteNode(imageNamed: "obstacle")
        obstacle.name = "obstacle"
        //obstacle.setScale(3.0)
        obstacle.position = CGPoint(
            x: size.width + obstacle.size.width/2,
            y: CGFloat.random(
                min: playableRect.minY + obstacle.size.height/2,
                max: playableRect.maxY - obstacle.size.height/2))
        addChild(obstacle)

        let actionMove =
            SKAction.moveTo(x: -obstacle.size.width/2, duration: 2.0)
        let moveRandom = SKAction.moveBy(x: CGFloat.random(
            min: playableRect.minX + obstacle.size.height/2,
            max: playableRect.maxX - obstacle.size.height/2), y:CGFloat.random(min: playableRect.minY + obstacle.size.height/2,
                                                                               max: playableRect.maxY - obstacle.size.height/2), duration: 0.25)

        let actionRemove = SKAction.removeFromParent()*/
        //let sequence = SKAction.sequence([moveRandom])
        //obstacle.run(sequence)
        //
        let obstacle = SKSpriteNode(imageNamed: "obstacle")
        obstacle.name = "obstacle"
        //obstacle.setScale(3.0)
        obstacle.position = CGPoint(
            x: CGFloat.random(
                min: playableRect.minX + obstacle.size.width/2,
                max: playableRect.maxX - obstacle.size.width/2),
            y: size.height + obstacle.size.height/2)
        addChild(obstacle)

        let actionMove =
            SKAction.moveTo(y: -obstacle.size.height/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([actionMove, actionRemove]))
        //
    }

    func spawnAstronaut() {
        let astronaut = SKSpriteNode(imageNamed: "astronaut")
        astronaut.name = "astronaut"
        astronaut.position = CGPoint(x:800,y:800)
        //astronaut.setScale(2.0)
        addChild(astronaut)

        let actionMove = SKAction.moveBy(x: CGFloat.random(
            min: playableRect.minX + obstacle.size.height/2,
            max: playableRect.maxX - obstacle.size.height/2), y:CGFloat.random(min: playableRect.minY + obstacle.size.height/2,
                                                                               max: playableRect.maxY - obstacle.size.height/2), duration: 0.5)

        let actionRotate = SKAction.rotate(byAngle: 1.0, duration: 5.0)
        let actionReverseRotate = actionRotate.reversed()
        let rotate = SKAction.sequence([actionRotate,actionReverseRotate])
        let actionRemove = SKAction.removeFromParent()
        let wait = SKAction.wait(forDuration: 1.0)
        let scaleBig = SKAction.scale(to: 5.0, duration: 3.0)
        let scaleSmall = SKAction.scale(to: 2.0, duration: 3.0)

        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let fadeInOut = SKAction.sequence([fadeIn,fadeOut])
        let fadeInOutRepeat5 = SKAction.repeat(fadeInOut,count: 10)
        
        astronaut.run(SKAction.sequence([rotate, scaleBig, fadeInOutRepeat5, fadeIn, scaleSmall]))

    }
    //MARK: COLLISION DETECTION

    func heroHit(obstacle: SKSpriteNode){
        obstacle.removeFromParent()
    }

    func heroHitAstronaut(){
        //print (astronautsSaved)
        /*        astronautsSaved = astronautsSaved + 1
         if (astronautsSaved > 7) {
         gameOver = true
         print ("you win!")
         let gameOverScene = GameOver(size: size, won: true)
         gameOverScene.scaleMode = scaleMode
         let reveal = SKTransition.flipHorizontal(withDuration: 1.5)
         view?.presentScene(gameOverScene, transition: reveal)

         }*/
        astronaut.removeFromParent()
    }

    func heroHitObstacle(){
        //print ("you lose!")
        //let gameOverScene = GameOver(size: size, won: false)
        //gameOverScene.scaleMode = scaleMode
        //let reveal = SKTransition.flipHorizontal(withDuration: 1.5)
        //view?.presentScene(gameOverScene, transition: reveal)
    }

    func checkCollisions(){
        var hitObstacles: [SKSpriteNode] = []
        var hitAstronaut: [SKSpriteNode] = []

        enumerateChildNodes(withName: "obstacle"){node, _ in
            let obstacle = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 30).intersects(self.hero.frame){
                hitObstacles.append(obstacle)
            }
        }

        for obstacle in hitObstacles {
            heroHitObstacle()


        }
        
        enumerateChildNodes(withName: "astronaut"){node, _ in
            let astronaut = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 30).intersects(self.hero.frame){
                hitAstronaut.append(astronaut)
            }
        }
        
        for astronaut in hitAstronaut {
            heroHitAstronaut()
        }
    }
}
