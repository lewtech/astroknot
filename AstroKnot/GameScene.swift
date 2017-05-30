//llewellyn flauta csc 491 hw3

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    var hero = SKSpriteNode(imageNamed: "Spaceship")
    let obstacle = SKSpriteNode(imageNamed: "obstacle")
    let astronaut = SKSpriteNode(imageNamed: "astronaut")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let heroMovePointsPerSec: CGFloat = 250.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    let motionManager = CMMotionManager()
    var xAcceleration = CGFloat(0)
    var yAcceleration = CGFloat(0)
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

    func createHero(){
        //create spaceship, give spaceship a physicsBody
        hero = SKSpriteNode(imageNamed: "Spaceship")

        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.width / 2)
        hero.physicsBody!.allowsRotation = true
        hero.physicsBody!.linearDamping = 5.0
        hero.position = CGPoint (x: size.width/2, y: size.height/2)
        hero.position = CGPoint(x: 96, y: 0)
        hero.setScale(0.33)
        hero.name = "hero"
        addChild(hero)
    }


    override func didMove(to view: SKView) {

        //initialize objects, and start looping actions. References are weak so that when the child objects are removed the memory is freed
        backgroundColor = SKColor.black
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        setupCoreMotion()

        createHero()
        // spawnObstacle()
        // spawnAstronaut()

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnObstacle()
                },
                               SKAction.wait(forDuration: 2.0)])))

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnAstronaut()
                },
                               SKAction.wait(forDuration: 4.3)])))


    }


    override func update(_ currentTime: TimeInterval){
        //this function smoothes out the movment updates
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime

        //accelerometer changes the gravity point so the ship moves toward the gravity source depending on tilt of device
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * -25, dy: accelerometerData.acceleration.y * 25)
        }

        //move the ship
        move(sprite: hero, velocity: velocity)
        boundsCheckHero()
        //rotate the ship in direction of the move on touches
        rotate(sprite: hero, direction: velocity)
        checkCollisions()
        print (hero.position)
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
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        let queue = OperationQueue()
        motionManager.startAccelerometerUpdates(to: queue, withHandler:
            {
                accelerometerData, error in
                guard let accelerometerData = accelerometerData else{
                    return
                }
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = (CGFloat(acceleration.x) * 0.75) +
                    (self.xAcceleration * 0.25)
                self.yAcceleration = (CGFloat(acceleration.y) * 0.75) +
                    (self.yAcceleration * 0.25)
        })
    }

    //MARK: SPAWN

    func spawnObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "obstacle")
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
        let actionRemove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([actionMove, actionRemove]))
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

        let actionMove =
            SKAction.rotate(byAngle: 1.0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        astronaut.run(SKAction.sequence([actionMove, actionRemove]))

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
