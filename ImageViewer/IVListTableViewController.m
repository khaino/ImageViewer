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
#import "RootViewController.h"
#import "IVImageDownload.h"

@interface IVListTableViewController ()
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSMutableArray *podcasts;
@property (strong, nonatomic) UIImage *thumbnail;
@end

@implementation IVListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Create page view controller
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    DownloadJSON *downloader = [[DownloadJSON alloc]init];
    [downloader performSearch:@"learning"];
    self.podcasts = [[NSMutableArray alloc]initWithArray:[[PodcastDBManager defaultManager] getAllPodcast]];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
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
    
    // Image downloading using IVImageDownload class
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:podcast.smallImage]
                           trackId:podcast.trackID
                         imageType:k60
                 completionHandler:^(NSURL *url){
                     cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                 }];
    cell.textLabel.text = podcast.collectionName;
    cell.detailTextLabel.text = podcast.artistName;
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSURL *imageURL = [NSURL URLWithString:podcast.smallImage];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//        
//        // Completion handler
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            self.thumbnail = [UIImage imageWithData:imageData];
//            cell.imageView.image = self.thumbnail;
//        });
//    });
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Add current image to first item of array
    NSMutableArray * imageList = [[NSMutableArray alloc]initWithCapacity:self.podcasts.count];
    for (Podcast *p in self.podcasts) {
        [imageList addObject:p.largeImage];
    }
    
    // Get the storyboard named secondStoryBoard from the main bundle:
    UIStoryboard *pageControlStoryboard = [UIStoryboard storyboardWithName:@"IVPageControl" bundle:nil];
    RootViewController *rvc = [pageControlStoryboard instantiateInitialViewController];
    rvc.pageImages = imageList;
    rvc.currentImage = (int)indexPath.row;
    [self.navigationController pushViewController:rvc animated:YES];
}

- (IBAction)chageGridView:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"IVGrid" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyBoard instantiateInitialViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
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


#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    // Get current table row
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    
//    // Add current image to first item of array
//    NSMutableArray * imageList = [[NSMutableArray alloc]initWithCapacity:self.podcasts.count];
//    for (Podcast *p in self.podcasts) {
//        [imageList addObject:p.largeImage];
//    }
//    
//    // Get the new view controller using [segue destinationViewController].
//    RootViewController *rvc = [segue destinationViewController];
//    
//    // Pass the selected object to the new view controller.
//    rvc.pageImages = imageList;
//    rvc.currentImage = (int)indexPath.row;
//}

//- (UIImage *)imageForIndexPath:(NSIndexPath *)indexPath {
//    
//    NSDictionary *dic = [self.podcasts objectAtIndex:indexPath.row];
//    UIImage *image = [dic valueForKey:@"cached_image"];
//    
//    if (!image) {
//        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@.jpg", [dic objectForKey:@"trackId"]]];
//        NSMutableDictionary *updatedDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
//        [updatedDictionary setValue:image forKey:@"cached_image"];
//        NSMutableArray *updatedIssues = [NSMutableArray arrayWithArray:self.podcasts];
//        [updatedIssues replaceObjectAtIndex:indexPath.row withObject:[NSDictionary dictionaryWithDictionary:updatedDictionary]];
//        self.podcasts = updatedIssues;
//    }
//    return image;
//}

@end
