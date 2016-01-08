//
//  BallAnimation.swift
//  BallConflict
//
//  Created by user on 15/7/2.
//  Copyright © 2015年 stackJolin. All rights reserved.
//

import UIKit

class BallAnimation: UIView {
    var balls: NSMutableArray
    var anchors: NSMutableArray
    let ballCount: Int
    var animator:UIDynamicAnimator = UIDynamicAnimator()
    var userDragBehavior:UIPushBehavior?
    var userSnapBehavior:UISnapBehavior?
    override init(frame: CGRect) {
        self.ballCount = 5
        self.balls = NSMutableArray()
        self.anchors = NSMutableArray()

        super.init(frame: frame)
        animator = UIDynamicAnimator(referenceView: self)
        self.createBallsAndAnchors()
        self.addDynamicBehaviors()
    }
    
    //初始化球和锚点
    func createBallsAndAnchors(){
        var animator:UIDynamicAnimator = UIDynamicAnimator(referenceView: self)
        
        let ballArray: NSMutableArray = NSMutableArray()
        let anchorArray: NSMutableArray = NSMutableArray()
        let ballEdgeLength: CGFloat = self.bounds.width / (3.0 * CGFloat(self.ballCount))
        for i in 0..<self.ballCount{
            let ballView:BallView = BallView(frame: CGRectMake(0, 0, ballEdgeLength - 1, ballEdgeLength - 1))
            //计算小球的中心
            let ballX:CGFloat = CGRectGetWidth(self.bounds) / 3.0 + (CGFloat(i) * ballEdgeLength)
            let ballY:CGFloat = CGRectGetHeight(self.bounds) / 1.5
            ballView.center = CGPointMake(ballX, ballY)
            
            //为小球添加手势
            let ballViewPanGuesture:UIPanGestureRecognizer = UIPanGestureRecognizer()
            let ballViewTapGuesture:UITapGestureRecognizer = UITapGestureRecognizer()
            ballViewTapGuesture.addTarget(self, action: "tapBallView:")
            ballViewPanGuesture.addTarget(self, action: "panBallView:")
            ballView.addGestureRecognizer(ballViewPanGuesture)
            ballView.addGestureRecognizer(ballViewTapGuesture)

            //监听小球的移动------枚举的时候用“.”
            ballView.addObserver(self, forKeyPath: "center", options: NSKeyValueObservingOptions.New, context: nil)
            
            //小球添加到数组
            ballArray.addObject(ballView)
            //小球添加到视图
            self.addSubview(ballView)
            
            //创建锚点
            let anchorView:UIView = self.anchorView(ballView)
            anchorArray.addObject(anchorView)
            self.addSubview(anchorView)
        }
        self.balls = ballArray
        self.anchors = anchorArray
    }
    func tapBallView(pangesure:UITapGestureRecognizer){
        print("dddddd");
    }
    func panBallView(pangesure:UIPanGestureRecognizer){
        //用户开始拖动时,创建一个新的UIPushBehavior,并添加到animator中
        if pangesure.state == UIGestureRecognizerState.Began{
            userSnapBehavior = UISnapBehavior(item: pangesure.view!, snapToPoint: (pangesure.view?.center)!)
            if let behavior = userDragBehavior {
                animator.removeBehavior(behavior)
                return
            }
            userDragBehavior = UIPushBehavior(items: [pangesure.view!], mode: UIPushBehaviorMode.Continuous)
            animator.addBehavior(userDragBehavior!)
        }
        if pangesure.state == UIGestureRecognizerState.Changed{
        }
        //设置拖动的方向
        if let behavior = userDragBehavior{
            behavior.pushDirection = CGVectorMake(pangesure.translationInView(self).x/300.0, 0)
            //当用户停止拖动的时候,移除pushbehavior
            if pangesure.state == UIGestureRecognizerState.Ended{
                animator.removeBehavior(behavior)
                userDragBehavior = nil
            }

        }
    }
    func anchorView(ballView:BallView) -> UIView{
        var anchorPoint:CGPoint = ballView.center
        anchorPoint.y -= CGRectGetHeight(self.bounds) / 4.0
        let anchorView:UIView = UIView(frame: CGRectMake(0, 0, 10, 10))
        anchorView.backgroundColor = UIColor.redColor()
        anchorView.center = anchorPoint
        return anchorView
    }
    //添加动力行为
    func addDynamicBehaviors(){
        //添加动力行为,将多个力的行为,组合成一个复杂的行为
        let behavior:UIDynamicBehavior = UIDynamicBehavior()
        
        self.addAttachBehacior(behavior)
        behavior.addChildBehavior(self.createGrivity(balls))
        behavior.addChildBehavior(self.createCollsion(balls))
        behavior.addChildBehavior(self.createCommenBehavior(balls))
        animator.addBehavior(behavior)
    }
    //为每个小球添加一个吸附行为(attachmentbehavior)
    func addAttachBehacior(behavior:UIDynamicBehavior) {
        for var i = 0; i < self.ballCount; i++ {
            let attachBehavior:UIAttachmentBehavior = self.createAttachmentBehaviorForBallBearing(ball: balls.objectAtIndex(i) as! UIDynamicItem, anchor: anchors.objectAtIndex(i) as! UIDynamicItem)
            behavior.addChildBehavior(attachBehavior)
        }
    }
    //吸附行为
    func createAttachmentBehaviorForBallBearing(ball ballBearing:UIDynamicItem, anchor:UIDynamicItem) -> UIAttachmentBehavior {
        let behavior:UIAttachmentBehavior = UIAttachmentBehavior(item: ballBearing, attachedToAnchor: anchor.center)
        return behavior
    }
    //碰撞行为
    func createCollsion(balls:NSArray) ->UICollisionBehavior {
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: balls as! [UIDynamicItem])
        return collisionBehavior
    }
    //重力行为
    func createGrivity(balls:NSArray) -> UIGravityBehavior {
        let grivityBehavior:UIGravityBehavior = UIGravityBehavior(items: balls as! [UIDynamicItem])
        return grivityBehavior
    }
    //为所有的动力行为创建共有的一些属性(空气阻力、摩擦力、弹性密度)
    func createCommenBehavior(balls:NSArray) ->UIDynamicItemBehavior {
        let itemBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: balls as! [UIDynamicItem])
        //弹性
        itemBehavior.elasticity = 1
        itemBehavior.allowsRotation = true
        //阻力
        itemBehavior.resistance = 0.5
        //摩擦
        itemBehavior.friction = 0.5;
        //空气密度
        itemBehavior.density = 0.1;
        //转动阻力
        itemBehavior.angularResistance = 0;
        return itemBehavior
    }

    //观察者方法
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //当ball的center属性发生变化时,调用该方法
        self.setNeedsDisplay()
    }

    //画线
    override func drawRect(rect: CGRect) {
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        for item in balls{
            let ballpoint:CGPoint = balls.objectAtIndex(balls.indexOfObject(item)).center
            let anchorpoint:CGPoint = anchors.objectAtIndex(balls.indexOfObject(item)).center
            CGContextMoveToPoint(context, ballpoint.x, ballpoint.y)
            CGContextAddLineToPoint(context, anchorpoint.x, anchorpoint.y)
            CGContextSetLineWidth(context, 1.0)
            UIColor.redColor().setStroke()
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        }
        /**
          * 重绘的时候必须制定背景色,将原来的线去掉,苹果的设计中,必须背景色,不指定背景色的时候,是很耗费性能的一件事情,所以在UITableView的时候,调用的时候如果不指定背景色是特别耗费性能的事情
        */
        self.backgroundColor = UIColor.whiteColor()
    }
    
    deinit{
        for item in balls{
            item.removeObserver(self, forKeyPath: "center")
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
