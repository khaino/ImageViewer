//
//  IVSearchViewController.m
//  ImageViewer
//
//  Created by user on 6/10/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVSearchViewController.h"
#import "IVTableViewCell.h"
#import "Podcast.h"
#import "IVImageDownload.h"
#import "PodcastDBManager.h"

@interface IVSearchViewController ()
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSMutableArray *podcasts;
@property (strong, nonatomic) UIImage *thumbnail;
@end

@implementation IVSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Show Keyboard
    [self.searchBar becomeFirstResponder];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.podcasts ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.podcasts ? self.podcasts.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Podcast *podcast = [self.podcasts objectAtIndex:(indexPath.row)];
    self.thumbnail = [UIImage animatedImageNamed:@"spinner_" duration:1.0f];
    cell.smallImageView.image = self.thumbnail;
    
//    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
//    [imageDownloader downloadImage:[NSURL URLWithString:podcast.largeImage]
//                           trackId:podcast.trackID
//                         imageType:k600
//                 completionHandler:^(NSURL *url){
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         self.thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
//                         cell.smallImageView.image = self.thumbnail;
//                     });
//                 }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *imageURL = [NSURL URLWithString:podcast.largeImage];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
        // Completion handler
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.thumbnail = [UIImage imageWithData:imageData];
            cell.smallImageView.image = self.thumbnail;
        });
    });
    
    cell.titleLabel.text = podcast.collectionName;
    cell.subtitleLabel.text = podcast.artistName;
    cell.smallImageView.layer.cornerRadius = 20;
    cell.smallImageView.clipsToBounds = YES;
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (!searchText) return;
    if (searchText.length <= 3) {
        [self resetSearch];
    } else {
        [self performSearch];
    }
}

- (void)resetSearch {
    // Update Data Source
    [self.podcasts removeAllObjects];
    
    // Update Table View
    [self.tableView reloadData];
}

- (void)performSearch {
    NSString *query = self.searchBar.text;
    
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    self.dataTask = [self.session dataTaskWithURL:[self urlForQuery:query] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (error.code != -999) {
                NSLog(@"%@", error);
            }
            
        } else {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = [result objectForKey:@"results"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (results) {
                    [self processResults:results];
                }
            });
        }
    }];
    
    if (self.dataTask) {
        [self.dataTask resume];
    }
}

- (NSURL *)urlForQuery:(NSString *)query {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?media=podcast&entity=podcast&term=%@", query]];
}

- (void)processResults:(NSArray *)results {
    if (!self.podcasts) {
        self.podcasts = [NSMutableArray array];
    }
    
    // Update Data Source
    [self.podcasts removeAllObjects];
//    [self.podcasts addObjectsFromArray:results];
    
    for (NSDictionary *dict in results) {
        Podcast *podcast = [[Podcast alloc]init];
        [podcast setTrackID:[dict objectForKey:@"trackId"]];
        [podcast setCollectionName:[dict objectForKey:@"collectionName"]];
        [podcast setArtistName:[dict objectForKey:@"artistName"]];
        [podcast setSmallImage:[dict objectForKey:@"artworkUrl60"]];
        [podcast setLargeImage:[dict objectForKey:@"artworkUrl600"]];
        [self.podcasts addObject:podcast];
//        [[PodcastDBManager defaultManager] insertPodcast:podcast];
    }
    
    
    // Update Table View
    [self.tableView reloadData];
}

- (NSURLSession *)session {
    if (!_session) {
        // Initialize Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // Configure Session Configuration
        [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
        
        // Initialize Session
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return _session;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveAction:(id)sender {
    for (Podcast *podcast in self.podcasts) {
        [[PodcastDBManager defaultManager] insertPodcast:podcast];
    }
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
