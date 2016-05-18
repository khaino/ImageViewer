//
//  LVListTableViewController.m
//  ImageViewer
//
//  Created by user on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVListTableViewController.h"
#import "Podcast.h"
#import "PodcastDBManager.h"
#import "DownloadJSON.h"
#import "IVLargeViewController.h"
#import "RootViewController.h"

@interface IVListTableViewController ()
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSMutableArray *podcasts;
@property (strong, nonatomic) UIImage *thumbnail;
@end

@implementation IVListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.podcasts = [[NSMutableArray alloc]initWithArray:[[PodcastDBManager defaultManager] getAllPodcast]];
    DownloadJSON *downloader = [[DownloadJSON alloc]init];
    [downloader performSearch:@"pop culture"];
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Create page view controller
    
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

-(void) updateTable {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.podcasts ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.podcasts ? self.podcasts.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Podcast *podcast = [self.podcasts objectAtIndex:(indexPath.row)];
    self.thumbnail = [UIImage animatedImageNamed:@"spinner_" duration:1.0f];
    [cell.imageView setImage:self.thumbnail];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *imageURL = [NSURL URLWithString:podcast.smallImage];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        // Completion handler
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            // If self.image is atomic (not declared with nonatomic)
            // you could have set it directly above
            self.thumbnail = [UIImage imageWithData:imageData];
            
            // This needs to be set here now that the image is downloaded and you are back on the main thread
            cell.imageView.image = self.thumbnail;
        });
    });
    cell.textLabel.text = podcast.collectionName;
    cell.detailTextLabel.text = podcast.artistName;
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get current table row
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    // Get current object from table row
    Podcast *touchedPodcast = [self.podcasts objectAtIndex:indexPath.row];
    
    // Add current image to first item of array
    NSMutableArray * imageList = [[NSMutableArray alloc]init];
    [imageList addObject:touchedPodcast.largeImage];
    
    // Add next images from array to end
    for (int i=indexPath.row+1; i<self.podcasts.count; i++) {
        [imageList addObject:[[self.podcasts objectAtIndex:i]largeImage]];
    }
    
    // Add first image to current indexpath
    if (indexPath.row!=0) {
        for (int i=0; i<indexPath.row; i++) {
            [imageList addObject:[[self.podcasts objectAtIndex:i]largeImage]];
        }
    }
    

    // Get the new view controller using [segue destinationViewController].
    RootViewController *rvc = [segue destinationViewController];
    // Pass the selected object to the new view controller.
    rvc.pageImages = imageList;
}


@end
