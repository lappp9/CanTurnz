
import UIKit
import CoreMotion

public class ViewController: UIViewController, UIScrollViewDelegate {
    var fullSizeImageSize = CGSizeZero
    var smallImageSize = CGSizeZero

    public let imageView = UIImageView()
    public var zoomedIn = false
    public let scrollView = UIScrollView()
    public var image = UIImage(named: "ginkakuji")!
    public let motionManager = CMMotionManager()
    public var zoomScale: Double = 0.0

    public override func viewDidLoad() {
        super.viewDidLoad()

        fullSizeImageSize = CGSize(width: proportionateWidthForImageAtScreenHeight(image), height: self.view.bounds.size.height)
        
        zoomScale = Double((UIScreen.mainScreen().bounds.size.height/UIScreen.mainScreen().bounds.size.width) * (proportionateWidthForImageAtScreenHeight(image)/UIScreen.mainScreen().bounds.size.height))
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.imageView.image = image
        
        scrollView.frame = self.view.bounds

        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.scrollEnabled = false
        scrollView.contentSize = fullSizeImageSize
        scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width/2.0, y: 0), animated: false)
        
        self.imageView.bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: proportionateHeightForImageAtScreenWidth(image))
        self.imageView.center =  CGPoint(x: scrollView.contentSize.width/2.0 + (self.imageView.bounds.size.width/2.0), y: self.view.bounds.size.height/2.0)
        self.imageView.userInteractionEnabled = true
        smallImageSize = self.imageView.bounds.size

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        self.imageView.addGestureRecognizer(tap)
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        scrollView.center = self.view.center
        
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{ deviceManager, error in
            let xRotationRate = deviceManager.rotationRate.x
            let yRotationRate = deviceManager.rotationRate.y
            let zRotationRate = deviceManager.rotationRate.z
            
            if abs(yRotationRate) > (abs(xRotationRate) + abs(zRotationRate)) {
                self.panImageWithYRotation(yRotationRate)
            }            
        })
    }
    
    func panImageWithYRotation(yRotation: Double) {
        if self.zoomedIn {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.CurveEaseOut, animations: {
                self.scrollView.contentOffset = self.newContentOffset(yRotation)
            }, completion: nil)
        }
    }
    
//    static CGFloat kMovementSmoothing = 0.3f;
//    [UIView animateWithDuration:kMovementSmoothing delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState| UIViewAnimationOptionAllowUserInteraction| UIViewAnimationOptionCurveEaseOut 
//  animations:^{
//    [self.panningScrollView setContentOffset:contentOffset animated:NO];
//   } 
//   completion:NULL];
    
    func newContentOffset(yRotation: Double) -> CGPoint {
        let lowerLimit = Double(0.0)
        let upperLimit = Double(proportionateWidthForImageAtScreenHeight(image) - UIScreen.mainScreen().bounds.size.width)
        let rotationMult = Double(3)
        
        var possibleXOffset = Double(scrollView.contentOffset.x) + ((yRotation * -1) * rotationMult * zoomScale)
        
        if possibleXOffset < lowerLimit {
            possibleXOffset = 0
        } else if possibleXOffset > upperLimit {
            possibleXOffset = upperLimit
        }
        
        var contentOffset: CGPoint = CGPoint(x: possibleXOffset, y: 0)
        
        return contentOffset
    }
    
    public func tapped() {
        if self.zoomedIn {
            self.animateImageViewToFullyVisible()
        } else {
            self.animateImageViewToFullHeight()
        }
    }
    
    func animateImageViewToFullHeight() {
        let sizeAnim = POPSpringAnimation(propertyNamed: kPOPLayerSize)
        sizeAnim.springBounciness = 2
        sizeAnim.springSpeed = 10
        sizeAnim.toValue = NSValue(CGSize: fullSizeImageSize)
        
        let contentOffsetAnim = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
        contentOffsetAnim.toValue = NSValue(CGPoint: CGPoint(x: proportionateWidthForImageAtScreenHeight(image)/2.0, y: 0))

        let imageCenter = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        imageCenter.toValue = NSValue(CGPoint: CGPoint(x: scrollView.contentSize.width/2.0, y: UIScreen.mainScreen().bounds.height/2.0))
        
        self.imageView.pop_addAnimation(sizeAnim, forKey: nil)
        self.scrollView.pop_addAnimation(contentOffsetAnim, forKey: nil)
        self.imageView.pop_addAnimation(imageCenter, forKey: nil)
        
        self.scrollView.scrollEnabled = false
        self.zoomedIn = true
    }
    
    func animateImageViewToFullyVisible() {
        let size = POPSpringAnimation(propertyNamed: kPOPViewSize)
        size.springBounciness = 1
        size.springSpeed = 10
        size.toValue = NSValue(CGSize: CGSize(width: UIScreen.mainScreen().bounds.size.width, height: proportionateHeightForImageAtScreenWidth(image)))

        let center = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        let contentOffsetAnim = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)

        center.toValue = NSValue(CGPoint: CGPoint(x: scrollView.contentSize.width/2.0 + (smallImageSize.width/2.0), y: self.view.bounds.size.height/2.0))
        contentOffsetAnim.toValue = NSValue(CGPoint: CGPoint(x: proportionateWidthForImageAtScreenHeight(image)/2.0, y: 0))

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
}