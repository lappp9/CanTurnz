
import UIKit
import CoreMotion

public class MotionPanningViewController: UIViewController, UIScrollViewDelegate, POPAnimationDelegate {
    var fullSizeImageSize = CGSizeZero
    var smallImageSize = CGSizeZero
    
    public let imageView = UIImageView()
    public var zoomedIn = false
    public let scrollView = UIScrollView()
    public var image = UIImage()
    public let motionManager = CMMotionManager()
    public var zoomScale: CGFloat = 0.0
    public var leftXBounds: CGPoint = CGPoint()
    public var rightXBounds: CGPoint = CGPoint()

    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    public convenience init(image: UIImage){
        self.init()
        self.image = image
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        fullSizeImageSize = CGSize(width: proportionateWidthForImageAtScreenHeight(image), height: self.view.bounds.size.height)
        
        zoomScale = (screenHeight/screenWidth) * (proportionateWidthForImageAtScreenHeight(image)/screenHeight)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.imageView.image = image
        
        leftXBounds  = CGPoint(x: -(proportionateWidthForImageAtScreenHeight(image))/2.0, y: 0)
        rightXBounds = CGPoint(x: (proportionateWidthForImageAtScreenHeight(image))/2.0 - screenWidth, y: 0)

        scrollView.frame = self.view.bounds
        
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.scrollEnabled = false
        
        self.imageView.bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: proportionateHeightForImageAtScreenWidth(image))
        self.imageView.center =  CGPoint(x: scrollView.contentSize.width/2.0 + (self.imageView.bounds.size.width/2.0), y: self.view.bounds.size.height/2.0)
        self.imageView.userInteractionEnabled = true
        smallImageSize = self.imageView.bounds.size
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        self.imageView.addGestureRecognizer(tap)
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        scrollView.center = self.view.center
        
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{ deviceManager, error in
            let xRotationRate = CGFloat(deviceManager.rotationRate.x)
            let yRotationRate = CGFloat(deviceManager.rotationRate.y)
            let zRotationRate = CGFloat(deviceManager.rotationRate.z)
            
            println("y \(yRotationRate) and x \(xRotationRate) and z\(zRotationRate)")
            
            if abs(yRotationRate) > (abs(xRotationRate) + abs(zRotationRate)) {
                self.panImageWithYRotation(yRotationRate)
            }
        })
    }
    
    func panImageWithYRotation(yRotation: CGFloat) {
        if self.zoomedIn && imageView.bounds.size.height == self.view.bounds.size.height {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.CurveEaseOut, animations: {
                self.scrollView.contentOffset = self.newContentOffset(yRotation)
                }, completion: nil)
        }
    }
    
    func newContentOffset(yRotation: CGFloat) -> CGPoint {
        let lowerLimit = leftXBounds.x
        let upperLimit = rightXBounds.x
        let rotationMult: CGFloat = 5.0
        
        var possibleXOffset = scrollView.contentOffset.x + ((yRotation * -1) * rotationMult * zoomScale)
        
        possibleXOffset = (possibleXOffset < lowerLimit) ? lowerLimit : possibleXOffset
        possibleXOffset = (possibleXOffset > upperLimit) ? upperLimit : possibleXOffset
        
        var contentOffset: CGPoint = CGPoint(x: possibleXOffset, y: 0)
        
        return contentOffset
    }
    
    public func tapped(tap: UITapGestureRecognizer) {
        if self.zoomedIn {
            self.animateImageViewToFullyVisible()
        } else {
            self.animateImageViewToFullHeight(tap.locationInView(self.view))
        }
    }
    
    func animateImageViewToFullHeight(tapLocation: CGPoint) {
        let sizeAnim = POPSpringAnimation(propertyNamed: kPOPLayerSize)
        sizeAnim.springBounciness = 2
        sizeAnim.springSpeed = 10
        sizeAnim.toValue = NSValue(CGSize: fullSizeImageSize)
        
        let contentOffsetAnim = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
        contentOffsetAnim.toValue = NSValue(CGPoint: startingContentOffset(tapLocation.x))
        
        let imageCenter = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        imageCenter.toValue = NSValue(CGPoint: CGPoint(x: scrollView.contentSize.width/2.0, y: UIScreen.mainScreen().bounds.height/2.0))
        
        sizeAnim.delegate = self
        contentOffsetAnim.delegate = self
        imageCenter.delegate = self
        
        self.imageView.pop_addAnimation(sizeAnim, forKey: nil)
        self.scrollView.pop_addAnimation(contentOffsetAnim, forKey: nil)
        self.imageView.pop_addAnimation(imageCenter, forKey: nil)
        
        self.scrollView.scrollEnabled = false
        self.zoomedIn = true
    }
    
    func startingContentOffset(tapXPosition: CGFloat) -> CGPoint {
        
        let percentage = tapXPosition/UIScreen.mainScreen().bounds.width
        let absoluteDistance = abs(leftXBounds.x) + rightXBounds.x

        return CGPoint(x: leftXBounds.x + (absoluteDistance * percentage), y: 0)
    }
    
    func animateImageViewToFullyVisible() {
        let size = POPSpringAnimation(propertyNamed: kPOPViewSize)
        size.springBounciness = 1
        size.springSpeed = 25
        size.toValue = NSValue(CGSize: CGSize(width: UIScreen.mainScreen().bounds.size.width, height: proportionateHeightForImageAtScreenWidth(image)))
        
        let center = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        center.toValue = NSValue(CGPoint: CGPoint(x: scrollView.contentSize.width/2.0 + (smallImageSize.width/2.0), y: self.view.bounds.size.height/2.0))
        
        let contentOffsetAnim = POPSpringAnimation(propertyNamed: kPOPScrollViewContentOffset)
        contentOffsetAnim.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
        contentOffsetAnim.springBounciness = 1.0
        contentOffsetAnim.springSpeed = 20
        
        self.imageView.pop_addAnimation(size, forKey: nil)
        self.imageView.pop_addAnimation(center, forKey: nil)
        self.scrollView.pop_addAnimation(contentOffsetAnim, forKey: nil)
        
        self.scrollView.scrollEnabled = false
        
        self.zoomedIn = false
    }
    
    func proportionateHeightForImageAtScreenWidth(image: UIImage) -> CGFloat {
        return (UIScreen.mainScreen().bounds.size.width * image.size.height)/image.size.width
    }
    
    func proportionateWidthForImageAtScreenHeight(image: UIImage) -> CGFloat {
        return (UIScreen.mainScreen().bounds.size.height * image.size.width)/image.size.height
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
}