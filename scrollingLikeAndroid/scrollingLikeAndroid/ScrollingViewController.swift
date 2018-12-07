//
//  ScrollingViewController.swift
//  scrollingLikeAndroid
//
//  Created by Emiliano Hualpa on 12/6/18.
//  Copyright © 2018 Emilius Legrand. All rights reserved.
//

import UIKit

class ScrollingViewController: UIViewController {

    @IBOutlet weak var theTable: UITableView!
    @IBOutlet weak var stickyHeader: UIView!
    @IBOutlet weak var dissapearingHeader: UIView!
    @IBOutlet weak var dissapearingHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var stickyHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    private var previousScrollOffset: CGFloat = 0
    
    private var maxHeaderViewHeight: CGFloat = 200
    private let minHeaderViewHeight: CGFloat = 50
    
    private var maxDissapearingHeaderHeight: CGFloat = 150
    private let minDissapearingHeaderHeight: CGFloat = 0
    
    private var didScroll = false
    private var scrollFix = false
    private var headerIsCollapsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theTable.separatorStyle = .none
        title = "Scrolling"
    }
}

extension ScrollingViewController: UITableViewDelegate {
    
}

extension ScrollingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")
        cell?.textLabel?.text = String(indexPath.row) + " Milo"
        cell?.backgroundColor = UIColor.random()
        cell?.textLabel?.textColor = .white
        return cell!
    }
    
    
}

extension ScrollingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        
        if (scrollView == theTable) {
            print(scrollView.contentOffset.y)
            
            let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
            
            let absoluteTop: CGFloat = 0;
            let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
            
            let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
            let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
            
            var newHeaderViewHeight = self.headerViewHeightConstraint.constant
            if isScrollingDown {
                newHeaderViewHeight = max(self.minHeaderViewHeight, self.headerViewHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeaderViewHeight = min(self.maxHeaderViewHeight, self.headerViewHeightConstraint.constant + abs(scrollDiff))
            }
            
            if newHeaderViewHeight != self.headerViewHeightConstraint.constant {
                self.headerViewHeightConstraint.constant = newHeaderViewHeight
                if !scrollFix {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.layoutIfNeeded()
                        self.scrollFix = true
                    })
                }
            }
            
            var newHeigthDissapearing = self.dissapearingHeaderHeight.constant
            if isScrollingDown {
                newHeigthDissapearing = max(self.minDissapearingHeaderHeight, self.dissapearingHeaderHeight.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeigthDissapearing = min(self.maxDissapearingHeaderHeight, self.dissapearingHeaderHeight.constant + abs(scrollDiff))
            }
            
            if newHeigthDissapearing != self.dissapearingHeaderHeight.constant {
                self.dissapearingHeaderHeight.constant = newHeigthDissapearing
                self.dissapearingHeader.layer.opacity = Float(newHeigthDissapearing * maxDissapearingHeaderHeight/10000)

            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
        
        if scrollView.contentOffset.y < 0 && headerIsCollapsed {
            expandHeader()
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderViewHeight - self.minHeaderViewHeight
        let midPoint = self.minHeaderViewHeight + (range / 2)
        
        if self.headerViewHeightConstraint.constant > midPoint {
            // Expand
            expandHeader()
        } else {
            // Collapse
            collapseHeader()
        }
    }
    
    func expandHeader(){
        headerIsCollapsed = false
        self.headerViewHeightConstraint.constant = maxHeaderViewHeight
        self.dissapearingHeaderHeight.constant = maxDissapearingHeaderHeight
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func collapseHeader(){
        headerIsCollapsed = true
        self.headerViewHeightConstraint.constant = minHeaderViewHeight
        self.dissapearingHeaderHeight.constant = minDissapearingHeaderHeight
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return (CGFloat(arc4random()) / CGFloat(UInt32.max))/3.75
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
