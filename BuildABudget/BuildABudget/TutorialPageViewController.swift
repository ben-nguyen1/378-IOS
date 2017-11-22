//
//  TutorialViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 11/3/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {
    // fileprivate(set) means - this property is readable throughout the module/app
    // that contains this code, but only writeable from within this file.
    // lazy means - lazy evaluation - the code isn't executed until it's referenced.
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newImageViewController(_image: "1"),
                self.newImageViewController(_image: "2"),
                self.newImageViewController(_image: "3"),
                self.newImageViewController(_image: "4"),
                self.newImageViewController(_image: "5"),
                self.newImageViewController(_image: "6")]
    }()
    
    // Include this method to be able to programmatically choose the transition style.
    // Choose between:  .scroll (default) and .pageCurl
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    fileprivate func newImageViewController(_image: String) -> UIViewController {
        // Instantiate a view controller that is in the storyboard, using the
        // associated storyboard id - which can be set in the Identity Inspector.
        // "Main" here is the name of the storyboard file.
        let viewController = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: "imageTutorialVC") as? TutorialImageViewController
        viewController!.fileName = _image
        return viewController!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tutorial"
        
        dataSource = self
        
        // Get the first view controller from the array of view controllers,
        // and use it to establish the initial array of view controllers
        // that will be managed by the page view controller.
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        // Set colors for the page control.
        // We're setting the global page control appearance object.
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.currentPageIndicatorTintColor = UIColor.green
        pageControl.backgroundColor = UIColor.gray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TutorialPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        // if we're at the first image and swipe left, go to the last image
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return orderedViewControllers[5]
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        // swipe to the image to the right
        // if we are at the last image, go to the 1st image
        var nextIndex = viewControllerIndex + 1
        if (viewControllerIndex == 5) {
            nextIndex = 0
        }
        
        guard orderedViewControllers.count != nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
    // A page indicator will be visible if both of the following methods are implemented, transition
    // style is 'scroll' and navigation orientation is 'horizontal'.
    //
    // Both methods are called in response to a 'setViewControllers' call, but the presentation index
    // is updated automatically in the case of gesture-driven navigation.
    // Return the number of items reflected in the page indicator.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    // Returns the selected item reflected in the page indicator.
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
}

// The tab bar controller blocks the UIPageControl
// temp fix until we move the tutorials to settings in Final phase
extension UIPageViewController {
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for subV in self.view.subviews {
            if type(of: subV).description() == "UIPageControl" {
                let pos = CGPoint(x: subV.frame.origin.x, y: subV.frame.origin.y - 55)
                subV.frame = CGRect(origin: pos, size: subV.frame.size)
            }
        }
    }
}

