//
//  IVSearchView.h
//  ImageViewer
//
//  Created by user on 6/15/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVSearchView : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/*
 * @brief When save button is pressed, data is save to database.
 * @param sender
 * @return none
 */
- (IBAction)saveAction:(id)sender;

/*
 * @brief When back button is pressed, go back to previous controller.
 * @param sender
 * @return none
 */
- (IBAction)backAction:(id)sender;
@end
