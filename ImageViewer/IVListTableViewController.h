//
//  LVListTableViewController.h
//  ImageViewer
//
//  Created by NCAung on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVListTableViewController : UITableViewController

/*
 * @brief Change to grid view.
 * @param sender
 * @return none
 */
- (IBAction)chageGridView:(id)sender;

/*
 * @brief Go to search controller.
 * @param sender
 * @return none
 */
- (IBAction)searchAction:(id)sender;
@end
