//
//  WorkspacesViewController.swift
//  PodioMobile
//
//  Created by Bruno Philipe on 11/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

import UIKit

class WorkspacesViewController: UITableViewController {
	private var organizations: [[String : AnyObject]]?
	private var didLoadOrganizations = false, noOrganizations = false, preparingAnimations = false
	private var elapsedAnimationsTime = 0.0
	private var refreshButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

		if ServerManager.sharedManager.isAuthenticated()
		{
			self.updateOrganizations()
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		if !ServerManager.sharedManager.isAuthenticated()
		{
			self.performSegueWithIdentifier("login", sender: nil)
		}
		else
		{
			self.updateOrganizations()
		}
	}

	@IBAction func didTapReloadButton(sender: AnyObject) {
		if let barButton = sender as? UIBarButtonItem
		{
			var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
			indicator.startAnimating()

			barButton.customView = indicator
			barButton.enabled = false

			self.refreshButton = barButton
		}

		let sectionsCount = self.numberOfSectionsInTableView(self.tableView)

		self.didLoadOrganizations = false

		self.tableView.beginUpdates()
		self.tableView.deleteSections(NSIndexSet(indexesInRange: NSMakeRange(0, sectionsCount)), withRowAnimation: UITableViewRowAnimation.Fade)
		self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
		self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)!], withRowAnimation: UITableViewRowAnimation.Top)
		self.tableView.endUpdates()

		self.updateOrganizations()
	}

	func updateOrganizations()
	{
		ServerManager.sharedManager.retreiveUserOrganizations({ (result: AnyObject?, error) -> Void in
			var fail: Bool = false
			if !error {
				if var typedResult = result! as? [[String : AnyObject]] {

					// Sorts organizations by name
					typedResult.sort({ (elementA: [String : AnyObject], elementB: [String : AnyObject]) -> Bool in
						elementB["name"] as? String > elementA["name"] as? String
					})

					// Sorts workspaces inside each organization by name
					for (var organization: [String : AnyObject]) in typedResult
					{
						let sortedSpaces: [[String : AnyObject]] = (organization["spaces"] as [[String : AnyObject]]).sorted({
							(elementA: [String : AnyObject], elementB: [String : AnyObject]) -> Bool in
								elementB["name"] as? String > elementA["name"] as? String
							}
						)

						organization["spaces"] = sortedSpaces
					}

					self.didLoadOrganizations = true
					self.organizations = typedResult

					if !self.preparingAnimations
					{
						self.preparingAnimations = true
						self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
					}

					self.animateTableViewUpdate()
				} else {
					fail = true
				}
			} else {
				fail = true
			}

			if fail {
				var alert = UIAlertController(title: "Error", message: "There was an error retreiving the organizations. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
			}

			self.refreshButton?.customView = nil
			self.refreshButton?.enabled = true
		})
	}

	func animateTableViewUpdate()
	{
		self.preparingAnimations = false

		self.tableView.beginUpdates()

		let sectionsCount = self.numberOfSectionsInTableView(self.tableView)
		self.tableView.insertSections(NSIndexSet(indexesInRange: NSMakeRange(0, sectionsCount)), withRowAnimation: UITableViewRowAnimation.None)

		for (var section=0; section<sectionsCount; section++)
		{
			let rowsCount = self.tableView(self.tableView, numberOfRowsInSection: section)
			var indexPaths = [NSIndexPath]()

			for (var row=0; row<rowsCount; row++)
			{
				indexPaths.append(NSIndexPath(forItem: row, inSection: section))
			}

			self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Right)
		}

		self.tableView.endUpdates()
	}
}

extension WorkspacesViewController : UITableViewDelegate, UITableViewDataSource
{
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if self.preparingAnimations
		{
			return 0
		}
		else if self.didLoadOrganizations
		{
			var count = self.organizations!.count
			self.noOrganizations = count == 0

			return max(count, 1)
		}
		else
		{
			return 1
		}
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.preparingAnimations
		{
			return 0
		}
		else if self.didLoadOrganizations && !self.noOrganizations
		{
			let organization = self.organizations![section] as [String : AnyObject]
			var count = (organization["spaces"] as [AnyObject]).count
			return max(count, 1)
		}
		else
		{
			return 1
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier_workspace = "cell_workspace_plain"
		let identifier_loading = "cell_loading"
		let identifier_empty = "cell_empty"

		var cell: UITableViewCell!

		if self.didLoadOrganizations && !self.noOrganizations
		{
			cell = tableView.dequeueReusableCellWithIdentifier(identifier_workspace, forIndexPath: indexPath) as UITableViewCell

			let organization = self.organizations![indexPath.section] as [String : AnyObject]
			let space = (organization["spaces"] as [AnyObject])[indexPath.row] as [String : AnyObject]

			cell.textLabel.text = space["name"] as? String
		}
		else if self.noOrganizations
		{
			cell = tableView.dequeueReusableCellWithIdentifier(identifier_empty, forIndexPath: indexPath) as UITableViewCell
		}
		else
		{
			cell = tableView.dequeueReusableCellWithIdentifier(identifier_loading, forIndexPath: indexPath) as UITableViewCell
		}

		return cell
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if self.didLoadOrganizations && !self.noOrganizations
		{
			let organization = self.organizations![section] as [String : AnyObject]
			return organization["name"] as? String
		}
		return nil
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44.0
	}
}
