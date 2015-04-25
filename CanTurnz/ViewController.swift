
import UIKit

public class ViewController: UIViewController {
    
    public let imageView = UIImageView()
    public var zoomedIn = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = UIImage(named: "ginkakuji")
        self.imageView.bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: self.proportionateHeightForImageAtScreenWidth(UIImage(named: "ginkakuji")!))
        self.imageView.center = self.view.center
        self.imageView.userInteractionEnabled = true

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        self.imageView.addGestureRecognizer(tap)
        
        self.view.addSubview(imageView)
    }
    
    public func tapped() {
        if self.zoomedIn {
            self.animateImageViewToFullyVisible()
        } else {
            self.animateImageViewToFullHeight()
        }
    }
    
    func animateImageViewToFullHeight() {
        let spring = POPSpringAnimation(propertyNamed: kPOPViewSize)
        
        spring.toValue = NSValue(CGSize: CGSize(width: self.proportionateWidthForImageAtScreenHeight(self.imageView.image!), height: UIScreen.mainScreen().bounds.size.height))
        
        self.imageView.pop_addAnimation(spring, forKey: nil)
        self.zoomedIn = true
    }
    
    func animateImageViewToFullyVisible() {
        let spring = POPSpringAnimation(propertyNamed: kPOPViewSize)
        
        spring.toValue = NSValue(CGSize: CGSize(width: UIScreen.mainScreen().bounds.size.width, height: self.proportionateHeightForImageAtScreenWidth(self.imageView.image!)))
        
        self.imageView.pop_addAnimation(spring, forKey: nil)
        self.zoomedIn = false
    }

    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func proportionateHeightForImageAtScreenWidth(image: UIImage) -> CGFloat {
        return (UIScreen.mainScreen().bounds.size.width * image.size.height)/image.size.width
    }
    
    func proportionateWidthForImageAtScreenHeight(image: UIImage) -> CGFloat {
        return (UIScreen.mainScreen().bounds.size.height * image.size.width)/image.size.height
    }
}