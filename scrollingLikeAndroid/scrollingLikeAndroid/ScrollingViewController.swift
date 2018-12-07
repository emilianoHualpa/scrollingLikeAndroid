//
//  ScrollingViewController.swift
//  scrollingLikeAndroid
//
//  Created by Emiliano Hualpa on 12/6/18.
//  Copyright © 2018 Emilius Legrand. All rights reserved.
//

import UIKit

class ScrollingViewController: UIViewController {

    @IBOutlet private weak var theTable: UITableView!
    @IBOutlet private weak var stickyHeader: UIView!
    @IBOutlet private weak var dissapearingHeader: UIView!
    @IBOutlet private weak var dissapearingHeaderHeight: NSLayoutConstraint!
    @IBOutlet private weak var stickyHeaderHeight: NSLayoutConstraint!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var previousScrollOffset: CGFloat = 0
    
    private let maxHeaderViewHeight: CGFloat = 200
    private let minHeaderViewHeight: CGFloat = 50
    
    private let maxDissapearingHeaderHeight: CGFloat = 150
    private let minDissapearingHeaderHeight: CGFloat = 0
    private var pageTitle = "Titulo"
    private var scrollPercent: Float = 0
    
    private var didScroll = false
    private var scrollFix = false
    private var headerIsCollapsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theTable.separatorStyle = .none
    }
}

extension ScrollingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")
        cell?.textLabel?.text = String(indexPath.row) + " Lorem ipsum"
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
            
            var newHeaderViewHeight = headerViewHeightConstraint.constant
            if isScrollingDown {
                newHeaderViewHeight = max(minHeaderViewHeight, headerViewHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeaderViewHeight = min(maxHeaderViewHeight, headerViewHeightConstraint.constant + abs(scrollDiff))
            }
            
            if newHeaderViewHeight != headerViewHeightConstraint.constant {
                headerViewHeightConstraint.constant = newHeaderViewHeight
                if !scrollFix {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.layoutIfNeeded()
                        self.scrollFix = true
                    })
                }
            }
            
            var newHeigthDissapearing = dissapearingHeaderHeight.constant
            if isScrollingDown {
                newHeigthDissapearing = max(minDissapearingHeaderHeight, dissapearingHeaderHeight.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeigthDissapearing = min(maxDissapearingHeaderHeight, dissapearingHeaderHeight.constant + abs(scrollDiff))
            }
            
            if newHeigthDissapearing != dissapearingHeaderHeight.constant {
                dissapearingHeaderHeight.constant = newHeigthDissapearing
                scrollPercent = Float(newHeigthDissapearing * maxDissapearingHeaderHeight/100)
                pageTitle = scrollPercent.description
            }
            
            previousScrollOffset = scrollView.contentOffset.y
            
            if (scrollPercent < 50){
                title = pageTitle
            } else {
                title = ""
            }
            
            titleLabel.text = scrollView.contentOffset.y.description

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
        let range = maxHeaderViewHeight - minHeaderViewHeight
        let midPoint = minHeaderViewHeight + (range / 2)
        
        if headerViewHeightConstraint.constant > midPoint {
            // Expand
            expandHeader()
        } else {
            // Collapse
            collapseHeader()
        }
    }
    
    func expandHeader(){
        headerIsCollapsed = false
        headerViewHeightConstraint.constant = maxHeaderViewHeight
        dissapearingHeaderHeight.constant = maxDissapearingHeaderHeight
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func collapseHeader(){
        headerIsCollapsed = true
        headerViewHeightConstraint.constant = minHeaderViewHeight
        dissapearingHeaderHeight.constant = minDissapearingHeaderHeight
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
