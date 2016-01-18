
import UIKit
import CanTurnz
import XCTest
import Quick
import Nimble
import CoreMotion

class CanTurnzSpec: QuickSpec {
    override func spec() {
        
        let vc = MotionPanningViewController(image: UIImage(named: "ginkakuji")!)
        let image = UIImage(named: "ginkakuji")
        let tap = UITapGestureRecognizer(target: vc, action: "tapped:")
        let touchPoint = CGPoint(x: 100, y: 0)
        
        beforeEach { () -> () in
            vc.viewDidLoad()
        }
        
        describe("a View Controller that can pan with motion when full screen") {
            
            describe("the motion manager") {
                it("should have a motion manager"){
                    expect(vc.motionManager).toNot(beNil())
                    expect(vc.motionManager).to(beAnInstanceOf(CMMotionManager))
                }
                
                it("should have a motion update inteveral of 0.01"){
                    expect(vc.motionManager.deviceMotionUpdateInterval).to(equal(0.01))
                }
            }
            
            it("should have an imageview") {
                expect(vc.imageView).toNot(beNil())
                expect(vc.imageView).to(beAnInstanceOf(UIImageView))
            }
            
            it("should display the image view") {
                expect(vc.scrollView.subviews).to(contain(vc.imageView))
            }
            
            describe("the scrollview", {
                it("should have a be in the view"){
                    expect(vc.view.subviews).to(contain(vc.scrollView))
                }
                
                it("should be "){
                    expect(vc.scrollView.frame).to(equal(vc.view.bounds))
                }
            })
            
            it("should be the same width as the screen") {
                expect(vc.imageView.bounds.size.width).to(equal(UIScreen.mainScreen().bounds.size.width))
            }
            
            describe("the main image") {
                it("should not be nil") {
                    expect(vc.imageView.image).toNot(beNil())
                }
                
                it("should be centered inside the scrollview"){
                    let expectedCenter = CGPoint(x: vc.scrollView.contentSize.width/2.0 + (vc.imageView.bounds.size.width/2.0), y: vc.view.bounds.size.height/2.0)
                    expect(vc.imageView.center).to(equal(expectedCenter))
                }
            }
            
            context("when the image is tapped") {
                it("should have user interaction enabled"){
                    expect(vc.imageView.userInteractionEnabled).to(beTrue())
                }
                
                it("should have a tap gesture recognizer"){
                    expect(vc.imageView.gestureRecognizers).toNot(beEmpty())
                }
                
                context("when the image is not zoomed in"){
                    it("should change the height to the height of the phone"){
                        vc.zoomedIn = false
                        vc.tapped(tap)
                        
                        expect(vc.zoomedIn).to(beTrue())
                        expect(vc.imageView.bounds.size.height).toEventually(equal(UIScreen.mainScreen().bounds.size.height), timeout: 1.0, pollInterval: 0.1)
                    }
                    it("should make the scroll"){
                        
                    }
                }
                
                context("when the image is zoomed in"){
                    it("should change the width to the width of the phone"){
                        vc.zoomedIn = true
                        vc.imageView.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
                        vc.tapped(tap)
                        
                        expect(vc.zoomedIn).to(beFalse())
                        expect(vc.imageView.bounds.size.width).toEventually(equal(UIScreen.mainScreen().bounds.size.width), timeout: 1.0, pollInterval: 0.1)
                    }
                }
            }
        }
    }
}
