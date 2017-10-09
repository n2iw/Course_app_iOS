//
//  DemoLectureTableViewController.swift
//  Shaban
//
//  Created by Ming Ying on 10/8/17.
//  Copyright © 2017 University at Albany. All rights reserved.
//

import UIKit

class DemoWeekTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("lectureCell", forIndexPath: indexPath)
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = "Week 1"
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
            if indexPath.section == 0 && indexPath.row == 0 {
                if let dayVC = segue.destinationViewController as? DemoDayTableViewController {
                    print("Day \(indexPath.row) selected")
                }
            }
        }
    }
}