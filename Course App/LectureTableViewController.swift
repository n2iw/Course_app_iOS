//
//  LectureTableViewController.swift
//  Course App
//
//  Created by Ming Ying on 8/31/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit
import CoreData

class LectureTableViewController: CoreDataTableViewController {
    
    private let context = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    var course: CDCourse! {
        didSet {
            guard let course = self.course
                else {
                    return
            }
            
            self.navigationItem.title = course.name
            let request = NSFetchRequest(entityName: "CDLecture")
            request.sortDescriptors = [NSSortDescriptor(
                key: "serial_number",
                ascending: true,
                selector: nil
                )]
            request.predicate = NSPredicate(format: "course == %@", course)
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            CDLecture.fetchLectures(self.course, context: self.context)
        }
    }
    
    //MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("lectureCell", forIndexPath: indexPath)
        if let lecture = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? CDLecture {
            cell.textLabel?.text = lecture.name
        }

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.lecture = self.fetchedResultsController!.objectAtIndexPath(indexPath) as? CDLecture
            } else if let videoVC = segue.destinationViewController as? VideoViewController {
                videoVC.lecture = self.fetchedResultsController!.objectAtIndexPath(indexPath) as? CDLecture
            }
        }
    }

}
