//
//  IVSearchViewController.h
//  ImageViewer
//
//  Created by user on 6/10/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVSearchViewController : UITableViewController <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)saveAction:(id)sender;
@end
