//
//  MailboxViewController.swift
//  mailbox
//
//  Created by Nicholas Wallen on 6/2/16.
//  Copyright © 2016 Nicholas Wallen. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

class MailboxViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    
    @IBOutlet weak var laterIcon: UIImageView!
    @IBOutlet weak var archiveIcon: UIImageView!
    
    @IBOutlet weak var listView: UIImageView!
    @IBOutlet weak var rescheduleView: UIImageView!
    
    var refreshControl: UIRefreshControl!
    
    var messageOriginalCenter: CGPoint!
    var archiveIconOriginalCenter: CGPoint!
    var laterIconOriginalCenter: CGPoint!
    var mainViewOriginalCenter: CGPoint!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    let panThreshold: CGFloat = 60
    let panIconSwitchThreshold: CGFloat = 260
    
    var red: UIColor!
    var brown: UIColor!
    var gray: UIColor!
    var green: UIColor!
    var yellow: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = contentView.frame.size
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPanMessage:")
        messageView.addGestureRecognizer(panGestureRecognizer)
        
        panGestureRecognizer.delegate = self
        
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        edgeGesture.edges = UIRectEdge.Left
        mainView.addGestureRecognizer(edgeGesture)
        
        red = UIColor.init(red: 219, green: 65, blue: 35)
        brown = UIColor.init(red: 174, green: 135, blue: 97)
        gray = UIColor.init(red: 233, green: 235, blue: 238)
        green = UIColor.init(red: 163, green: 206, blue: 113)
        yellow = UIColor.init(red: 245, green: 195, blue: 59)
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.init(red:68, green:170, blue:210)
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        scrollView.insertSubview(refreshControl, atIndex: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didPanMessage(sender: AnyObject) {
        let point = sender.locationInView(view)
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        
        if sender.state == UIGestureRecognizerState.Began {
            messageOriginalCenter = messageImage.center
            archiveIconOriginalCenter = archiveIcon.center
            laterIconOriginalCenter = laterIcon.center
            archiveIcon.alpha = 0.2
            laterIcon.alpha = 0.2
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            messageImage.center = CGPoint(x: messageOriginalCenter.x + translation.x, y:messageOriginalCenter.y)
            
            archiveIcon.alpha = convertValue(translation.x, r1Min: 0, r1Max: 60, r2Min: 0.2, r2Max: 1)
            laterIcon.alpha = convertValue(translation.x, r1Min: 0, r1Max: -60, r2Min: 0.2, r2Max: 1)
            
            messageView.backgroundColor = gray
            
            if translation.x > panThreshold {
                archiveIcon.center = CGPoint(x: archiveIconOriginalCenter.x + translation.x - 60, y:archiveIconOriginalCenter.y)
                if translation.x > panIconSwitchThreshold{
                    archiveIcon.image = UIImage(named:"delete_icon")
                    messageView.backgroundColor = red
                }
                else {
                    archiveIcon.image = UIImage(named:"archive_icon")
                    messageView.backgroundColor = green
                }
            }
            else if translation.x < -panThreshold{
                laterIcon.center = CGPoint(x: laterIconOriginalCenter.x + translation.x + 60, y:laterIconOriginalCenter.y)
               
                if translation.x < -panIconSwitchThreshold{
                    laterIcon.image = UIImage(named:"list_icon")
                    messageView.backgroundColor = brown
                }
                else {
                    laterIcon.image = UIImage(named:"later_icon")
                    messageView.backgroundColor = yellow
                }
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
        
            if translation.x > panThreshold {
                if translation.x > panIconSwitchThreshold{
                    //print("delete!")
                    animateMessageRightAndHide()
                }
                else {
                    //print("archive!")
                    animateMessageRightAndHide()
                    
                }
            }
            else if translation.x < -panThreshold{
                if translation.x < -panIconSwitchThreshold{
                    //print("list!")
                    showListOptions()
                }
                else {
                    //print("schedule!")
                    showScheduleOptions()
                }
            }
            else {
                resetMessageView()
            }
    
        }
    
    }
    
    func onRefresh() {
        delay(0.4){
            self.refreshControl.endRefreshing()
            delay(0.4){
                self.showMessageView()
            }
        }
    }
    
    func onEdgePan(sender: UIScreenEdgePanGestureRecognizer){
        let point = sender.locationInView(view)
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            mainViewOriginalCenter = mainView.center
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            mainView.center = CGPoint(x: mainViewOriginalCenter.x + translation.x, y: mainViewOriginalCenter.y)
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.x > 0{
                 showMenu()
            }
            else {
                hideMenu()
            }
        }
    }
    
    @IBAction func didTapMainView(sender: AnyObject) {
        hideMenu()
    }
    
    @IBAction func didTapView(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.2){
             sender.view!.alpha = 0
        }
        delay(0.2){
           self.hideMessageView()
        }
    }
    
    @IBAction func didTapFeed(sender: AnyObject) {
        
    }
    
    func showMenu() {
        UIView.animateWithDuration(0.2){
            self.mainView.frame.origin.x = 300.0
        }
    }
    
    func hideMenu(){
        UIView.animateWithDuration(0.2){
            self.mainView.frame.origin.x = 0
        }
    }
    
    func showScheduleOptions() {
        animateMessageLeft(0.2)
        delay(0.2){
            UIView.animateWithDuration(0.2){
                self.rescheduleView.alpha = 1
            }
        }
    }
    
    func showListOptions() {
        animateMessageLeft(0.2)
        delay(0.2){
            UIView.animateWithDuration(0.2){
                self.listView.alpha = 1
            }
        }
    }
    
    func animateMessageRightAndHide(){
        UIView.animateWithDuration(0.2){
            self.messageImage.center = CGPoint( x:self.messageOriginalCenter.x + self.messageView.frame.width, y: self.messageOriginalCenter.y)
            self.archiveIcon.center = CGPoint( x:self.archiveIconOriginalCenter.x + self.messageView.frame.width - self.panThreshold, y: self.archiveIconOriginalCenter.y)
        }
        delay(0.2){
            self.hideMessageView()
        }
    }
    
    func animateMessageLeft(animationTime: Double) {
        UIView.animateWithDuration(animationTime){
            self.messageImage.center = CGPoint( x:self.messageOriginalCenter.x - self.messageView.frame.width, y: self.messageOriginalCenter.y)
            self.laterIcon.center = CGPoint( x:self.laterIconOriginalCenter.x - self.messageView.frame.width + self.panThreshold, y: self.laterIconOriginalCenter.y)
        }
    }
    
    func showMessageView(){
        UIView.animateWithDuration(0.3){
            if(self.messageView.alpha == 0){
                self.messageView.alpha = 1
                self.feedImageView.frame.origin.y += self.messageView.frame.height
            }
        }
    }
    
    func hideMessageView(){
        UIView.animateWithDuration(0.3){
            self.messageView.alpha = 0
        }
        delay(0.3){
            UIView.animateWithDuration(0.3){
                self.feedImageView.frame.origin.y -= self.messageView.frame.height
            }
        }
        delay(0.6){
            self.resetMessageView()
        }
    }
    
    func resetMessageView(){
        UIView.animateWithDuration(0.2){
            self.laterIcon.center = self.laterIconOriginalCenter
            self.archiveIcon.center = self.archiveIconOriginalCenter
            self.messageImage.center = self.messageOriginalCenter
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }


}
