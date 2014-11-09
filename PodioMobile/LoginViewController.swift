//
//  LoginViewController.swift
//  PodioMobile
//
//  Created by Bruno Philipe on 11/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController
{
	@IBOutlet weak var constraint_topSpace: NSLayoutConstraint!
	@IBOutlet weak var constraint_trailingSpace: NSLayoutConstraint!

	@IBOutlet weak var imageView_logo: UIImageView!
	@IBOutlet weak var label_podioMobile: UILabel!
	@IBOutlet weak var textField_email: UITextField!
	@IBOutlet weak var textField_password: UITextField!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var button_login: UIButton!

	@IBOutlet var animatableViews: [UIView]!

	private var animationTimer: NSTimer?
	private var constraint_topSpace_defaultValue: CGFloat = 0.0
	private var constraint_trailingSpace_defaultValue: CGFloat = 0.0
	private var isDisplayingKeyboard: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.view.addKeyboardPanningWithActionHandler(nil)

		self.navigationController?.navigationBarHidden = true
    }

	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

		if (self.isDisplayingKeyboard)
		{
			dispatch_after(UInt64(500 * NSEC_PER_MSEC), dispatch_get_main_queue(), { () -> Void in
				self.prepareForInput()
			})
		}
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
}

extension LoginViewController
{
	@IBAction func didTapLoginButton(sender: AnyObject) {
		self.activityIndicator.startAnimating()
		self.button_login.enabled = false

		let username = self.textField_email.text
		let password = self.textField_password.text

		self.textField_password.resignFirstResponder()
		self.textField_email.resignFirstResponder()

		ServerManager.sharedManager.loginWithUsernamePassword(username, password: password, completion: { (result, error) -> Void in
			if (error)
			{
				var alert: UIAlertController!

				if result != nil && result!["reason"] as? String == "timeout"
				{
					alert = UIAlertController(title: "Error", message: "The connection timed-out. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.Alert)
				}
				else
				{
					alert = UIAlertController(title: "Error", message: "Please check your credentials and try again.", preferredStyle: UIAlertControllerStyle.Alert)
				}
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
				self.presentViewController(alert, animated: true, completion: { () -> Void in
					self.button_login.enabled = true
				})
				self.activityIndicator.stopAnimating()
			}
			else if (result != nil)
			{
				if let resultDict = result! as? [String : AnyObject]
				{
					ServerManager.sharedManager.setAuthorization(resultDict["access_token"] as? String)
					self.performSegueWithIdentifier("proceed", sender: nil)
				}
			}
		})
	}
}

extension LoginViewController : UITextFieldDelegate
{
	func textFieldDidBeginEditing(textField: UITextField) {
		self.prepareForInput()
	}

	func textFieldDidEndEditing(textField: UITextField) {
		self.undoInputPreparation()
	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField == self.textField_email
		{
			self.textField_password.becomeFirstResponder()
		}
		else
		{
			textField.resignFirstResponder()
			self.didTapLoginButton(textField)
		}
		return true
	}

	func prepareForInput()
	{
		self.isDisplayingKeyboard = true

		if (self.animationTimer == nil) {
			self.constraint_topSpace_defaultValue = self.constraint_topSpace.constant
			self.constraint_trailingSpace_defaultValue = self.constraint_trailingSpace.constant
		} else {
			self.animationTimer!.invalidate()
			self.animationTimer = nil
		}

		if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone)
		{
			UIView.beginAnimations("prepareForInput", context: nil)
			self.imageView_logo.layer.opacity = 0.0
			self.label_podioMobile.layer.opacity = 0.0
			UIView.commitAnimations()

			self.constraint_topSpace.constant = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) ? 15.0 : 30.0
			self.constraint_trailingSpace.constant = (self.view.bounds.size.width/2.0) - 150.0
		}
		else if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation))
		{
			self.constraint_topSpace.constant = self.constraint_topSpace_defaultValue - 140.0
		}

		self.animatableViews.map { $0.setNeedsUpdateConstraints() }

		UIView.animateWithDuration(0.25, animations: { () -> Void in
			self.animatableViews.map { $0.layoutIfNeeded() }
			return
		})
	}

	func undoInputPreparation()
	{
		self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: Selector("animationTimerDidFire"), userInfo: nil, repeats: false)
	}

	func animationTimerDidFire()
	{
		if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone)
		{
			UIView.beginAnimations("undoInputPreparation", context:nil)
			self.imageView_logo.layer.opacity = 1.0
			self.label_podioMobile.layer.opacity = 1.0
			UIView.commitAnimations()
		}

		self.constraint_topSpace.constant = self.constraint_topSpace_defaultValue
		self.constraint_trailingSpace.constant = self.constraint_trailingSpace_defaultValue

		self.animatableViews.map { $0.setNeedsUpdateConstraints() }

		UIView.animateWithDuration(0.25, animations: { () -> Void in
			self.animatableViews.map { $0.layoutIfNeeded() }
			return
		})

		self.animationTimer = nil
		self.isDisplayingKeyboard = false
	}
}
