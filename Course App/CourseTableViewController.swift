//
//  CourseTableViewController.swift
//  Course App
//
//  Created by Ming Ying on 8/31/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit
import CoreData

class CourseTableViewController: CoreDataTableViewController {
    
    private let context = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let phone = Settings.getPhone()
        where phone != ""
        else {
            self.tabBarController?.selectedIndex = Settings.SETTINGS_TAB_INDEX
            return
        }
        
        let request = NSFetchRequest(entityName: "CDCourse")
        request.sortDescriptors = [NSSortDescriptor(
            key: "id",
            ascending: true,
            selector: nil
            )]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: "MyCourseQueryCache"
        )
        context.performBlock() {
            CDCourse.fetchCourses(self.context)
            _ = try? self.context.save()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        context.performBlock() {
            CDCourse.fetchCourses(self.context)
            _ = try? self.context.save()
        }
    }
    
    // MARK: - Table view data source


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CouresCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.fetchedResultsController?.objectAtIndexPath(indexPath).name

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let lectureVC = segue.destinationViewController as? LectureTableViewController {
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            lectureVC.course = fetchedResultsController!.objectAtIndexPath(indexPath!) as! CDCourse
        }
    }

}
