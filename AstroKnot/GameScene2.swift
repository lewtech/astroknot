//llewellyn flauta csc 491 hw3


import SpriteKit
import CoreMotion

class GameScene2: SKScene {
    var hero = SKSpriteNode(imageNamed: "Spaceship")
    let obstacle = SKSpriteNode(imageNamed: "obstacle")
    let astronaut = SKSpriteNode(imageNamed: "astronaut")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let heroMovePointsPerSec: CGFloat = 600.0
    let movePointsPerSecond: CGFloat = 400.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    let motionManager = CMMotionManager()
    //var xAcceleration = CGFloat(0)
    //var yAcceleration = CGFloat(0)
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {

        //initialize objects, and start looping actions. References are weak so that when the child objects are removed the memory is freed
        backgroundColor = SKColor.black
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //setupCoreMotion()

        spawnHero()
//        spawnEnemy(type: "razor", x: 1000, y: 1700)
//        spawnEnemy(type: "razor", x: 1200, y: 1700)
//        spawnEnemy(type: "razor", x: 1000, y: 1700)
//        spawnEnemy(type: "razor", x: 800, y: 1700)
//        spawnEnemy(type: "razor", x: 600, y: 1700)
//        spawnEnemy(type: "razor", x: 400, y: 1700)
//        spawnEnemy(type: "spike", x: 500, y: 1900)
//        spawnEnemy(type: "spike", x: 1100, y: 1900)
        //introAstronautSprite()
        // spawnObstacle()
        //spawnAstronaut()

        /*        run(SKAction.repeatForever(
         SKAction.sequence([SKAction.run() { [weak self] in
         self?.spawnObstacle()
         },
         SKAction.wait(forDuration: 2.0)])))
         */
        let actionSpawnEnemy = SKAction.sequence([SKAction.run() { [weak self] in
            self?.spawnEnemy(type: "razor", x: 1200, y: 1700)
            },SKAction.wait(forDuration: 0.5)])
        run(SKAction.repeat(actionSpawnEnemy, count: 6))

        let actionSpawnSpike = SKAction.sequence([SKAction.run() { [weak self] in
            self?.spawnEnemy(type: "spike", x: 400, y: 1900)
            },SKAction.wait(forDuration: 1.5)])
        run(SKAction.repeat(actionSpawnSpike, count: 2))

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
        moveConga()
    }



    //MARK: MOVEMENT

    func move (sprite: SKSpriteNode, velocity: CGPoint) {
        //1
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))
        //print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }

    func MoveHeroToward(location: CGPoint) {
        let offset = location - hero.position
        let direction = offset.normalized()
        velocity = direction * heroMovePointsPerSec
        //physicsWorld.gravity =  CGVector (dx: 0, dy: 0)
        //use some type of friction here
    }

    func moveConga(){
        var targetPosition = hero.position

        enumerateChildNodes(withName: "conga") { node, stop in
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.movePointsPerSecond
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
    }


    //MARK: TOUCH EVENTS
    func sceneTouched (touchLocation:CGPoint){
        MoveHeroToward(location: touchLocation)
        spawnEnergyBolt(touchLocation: touchLocation)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hero.physicsBody?.affectedByGravity = false
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation:
            touchLocation)
        //print (touchLocation)
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        MoveHeroToward(location: hero.position)
    }

    func boundsCheckHero() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: 500)

        //zeroes the velocity of the hero when a bound is hit

        if hero.position.x <= bottomLeft.x {
            hero.position.x = bottomLeft.x
            velocity.x = 0.0
        }
        if hero.position.x >= topRight.x {
            hero.position.x = topRight.x
            velocity.x = 0.0
        }
        if hero.position.y <= bottomLeft.y {
            hero.position.y = bottomLeft.y
            velocity.y = 0.0
        }
        if hero.position.y >= topRight.y {
            hero.position.y = topRight.y
            velocity.y = 0.0
        }
    }

    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        //sprite.zRotation = direction.angle
        //print (sprite.zRotation)
    }




    //MARK: SPAWN OBJECTS


    func spawnHero(){
        //create spaceship, give spaceship a physicsBody
        hero = SKSpriteNode(imageNamed: "Spaceship")

        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.width / 2)
        hero.physicsBody!.allowsRotation = true
        hero.physicsBody!.linearDamping = 5.0
        hero.position = CGPoint (x: 150, y: 150)
        //        hero.position = CGPoint(x: 96, y: 0)
        hero.setScale(0.33)
        hero.zRotation = CGFloat(M_PI/Double(2.0))
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

    func spawnEnemy(type: String,x: CGFloat, y: CGFloat) {
        print ("spawn enemies")
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
        var enemy = SKSpriteNode(imageNamed: type)
        enemy.name = type
        enemy.setScale(0.25)
        enemy.position = CGPoint(x: x,y: y)
        if type == "spike" {
            enemy.position = CGPoint(x:400,y:y)
        }
        addChild(enemy)

//        let spike = SKSpriteNode(imageNamed: "spike2")
//        spike.name = "spike2"
//        spike.setScale(0.25)
//        spike.position = CGPoint(
//            x: CGFloat.random(
//                min: playableRect.minX + obstacle.size.width/2,
//                max: playableRect.maxX - obstacle.size.width/2),
//            y: 1900)
//        addChild(spike)
//        let actionMoveLeft = SKAction.move(by: CGVector(1.0), duration: 2.0)

        let actionMoveLeft =
            SKAction.moveTo(x: (400), duration: 2.0)
        let actionMoveRight =
            SKAction.moveTo(x:  1200, duration: 2.0)
        let actionMoveLeftRight = SKAction.sequence([actionMoveLeft, actionMoveRight])
        let actionRemove = SKAction.removeFromParent()
        if type == "razor" {
            enemy.run(SKAction.repeatForever(actionMoveLeftRight))}
        if type == "spike" {
            enemy.run(SKAction.repeatForever(actionMoveLeftRight))}
        //
    }

    func spawnAstronaut() {
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

        let actionRotate = SKAction.rotate(byAngle: 1.0, duration: 5.0)
        let actionReverseRotate = SKAction.rotate(byAngle: -1.0, duration: 5.0)
        let actionRemove = SKAction.removeFromParent()
        let wait = SKAction.wait(forDuration: 1.0)

        astronaut.run(SKAction.sequence([actionRotate, wait,actionReverseRotate, actionRemove]))

    }

    func spawnEnergyBolt (touchLocation: CGPoint){
        let energyBolt = SKSpriteNode(imageNamed: "energyBolt")
        energyBolt.position = hero.position
        let offset = touchLocation - energyBolt.position
        addChild(energyBolt)
        let direction = offset.normalized()
        let shootAmount = direction * 2000
        let realDest = shootAmount + energyBolt.position
        let actionMove = SKAction.move(to:realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        energyBolt.run(SKAction.sequence([actionMove,actionMoveDone]))
    }
    //MARK: COLLISION DETECTION

    func heroHit(obstacle: SKSpriteNode){
        obstacle.removeFromParent()
    }

    func heroHitAstronaut(astronaut: SKSpriteNode){
        //print ("hero hit astronaut")
        astronaut.name = "conga"
        astronaut.removeAllActions()
        astronaut.zRotation = 0

        /*        astronautsSaved = astronautsSaved + 1
         if (astronautsSaved > 7) {
         gameOver = true
         print ("you win!")
         let gameOverScene = GameOver(size: size, won: true)
         gameOverScene.scaleMode = scaleMode
         let reveal = SKTransition.flipHorizontal(withDuration: 1.5)
         view?.presentScene(gameOverScene, transition: reveal)

         }*/
        //astronaut.removeFromParent()
    }

    func heroHitObstacle(){
        //print ("you lose!")
        //let gameOverScene = GameOver(size: size, won: false)
        //gameOverScene.scaleMode = scaleMode
        //let reveal = SKTransition.flipHorizontal(withDuration: 1.5)
        //view?.presentScene(gameOverScene, transition: reveal)
    }

    func checkCollisions(){
        //var hitObstacles: [SKSpriteNode] = []
        var hitAstronaut: [SKSpriteNode] = []

        /*enumerateChildNodes(withName: "obstacle"){node, _ in
         let obstacle = node as! SKSpriteNode
         if node.frame.insetBy(dx: 20, dy: 30).intersects(self.hero.frame){
         hitObstacles.append(obstacle)
         }
         }

         for obstacle in hitObstacles {
         heroHitObstacle()


         } */

        enumerateChildNodes(withName: "astronaut"){node, _ in
            let astronaut = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 30).intersects(self.hero.frame){
                hitAstronaut.append(astronaut)
            }
        }
        
        for astronaut in hitAstronaut {
            //print ("hit astronaut")
            heroHitAstronaut(astronaut: astronaut)
        }
    }
}

