//
//  HomePageViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/22/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class HomePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
  
  // MARK: Props
  //
  lazy var orderedViewControllers: [UIViewController] = {
    return [
      getViewControllerByID(viewController: "GreenID"),
      getViewControllerByID(viewController: "RedID")
    ]
  }()
  var pageControl = UIPageControl()
  
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    delegate = self
    
    // This sets up the first view that will show up on our page control
    if let firstViewController = orderedViewControllers.first {
      setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
    
    configurePageControl()
  }
  
  // MARK: Data source methods
  //
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    // User is on the first view controller and swiped left to loop to
    // the last view controller.
    guard previousIndex >= 0 else {
      return orderedViewControllers.last
      // Uncommment the line below, remove the line above if you don't want the page control to loop.
      // return nil
    }
    
    guard orderedViewControllers.count > previousIndex else {
      return nil
    }
    
    return orderedViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = orderedViewControllers.count
    
    // User is on the last view controller and swiped right to loop to
    // the first view controller.
    guard orderedViewControllersCount != nextIndex else {
      return orderedViewControllers.first
      // Uncommment the line below, remove the line above if you don't want the page control to loop.
      // return nil
    }
    
    guard orderedViewControllersCount > nextIndex else {
      return nil
    }
    
    return orderedViewControllers[nextIndex]
  }
  
  // MARK: Delegate methods
  //
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    let pageContentViewController = pageViewController.viewControllers![0]
    pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
  }
  
  // MARK: Private methods
  //
  private func getViewControllerByID(viewController: String) -> UIViewController {
    return AppStoryboard.Main.instance.instantiateViewController(withIdentifier: viewController)
  }
  
  private func configurePageControl() {
    // The total number of pages that are available is based on how many available colors we have.
    pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
    pageControl.numberOfPages = orderedViewControllers.count
    pageControl.currentPage = 0
    pageControl.tintColor = UIColor.black
    pageControl.pageIndicatorTintColor = UIColor.white
    pageControl.currentPageIndicatorTintColor = UIColor.black
    view.addSubview(pageControl)
  }
}
