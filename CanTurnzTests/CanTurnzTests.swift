
import UIKit
import CanTurnz
import XCTest
import Quick
import Nimble

class CanTurnzSpec: QuickSpec {
    override func spec() {
        
        let vc = ViewController()
        beforeEach { () -> () in
            vc.viewDidLoad()
        }
        
        describe("a View Controller") {
            it("should have an imageview") {
                expect(vc.imageView).toNot(beNil())
                expect(vc.imageView).to(beAnInstanceOf(UIImageView))
            }
            
            it("should be the same width as the screen") {
                expect(vc.imageView.bounds.size.width).to(equal(UIScreen.mainScreen().bounds.size.width))
            }
            
            it("should display the image view") {
                expect(vc.view.subviews).to(contain(vc.imageView))
            }
            
            describe("the main image") {
                it("should not be nil") {
                    expect(vc.imageView.image).toNot(beNil())
                }
                
                it("should be centered"){
                    let expectedCenter = vc.view.center
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
                        vc.tapped()
                        
                        expect(vc.zoomedIn).to(beTrue())
                        expect(vc.imageView.bounds.size.height).toEventually(equal(UIScreen.mainScreen().bounds.size.height), timeout: 1.0, pollInterval: 0.1)
                    }
                }
                
                context("when the image is zoomed in"){
                    it("should change the width to the width of the phone"){
                        vc.zoomedIn = true
                        vc.imageView.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
                        vc.tapped()
                        
                        expect(vc.zoomedIn).to(beFalse())
                        expect(vc.imageView.bounds.size.width).toEventually(equal(UIScreen.mainScreen().bounds.size.width), timeout: 1.0, pollInterval: 0.1)
                    }
                }
            }
        }
    }
}
