//
//  IVSearchView.m
//  ImageViewer
//
//  Created by NCAung on 6/15/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVSearchView.h"
#import "IVTableViewCell.h"
#import "Podcast.h"
#import "IVImageDownload.h"
#import "PodcastDBManager.h"
#import "Reachability.h"

@interface IVSearchView ()
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSMutableArray *podcasts;
@property (strong, nonatomic) UIImage *thumbnail;
@end

@implementation IVSearchView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Search Podcast";
    
    // Test internet connection
    [self testConnection];
    
    // Show Keyboard
    [self.searchBar becomeFirstResponder];
    
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private method

/*
 * @brief Test internet connection
 * @return none
 */
- (void)testConnection{
    
    // Create alert view
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection"
                                                                   message:@"Please check your network connection"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Action for alert
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){}];
    [alert addAction:defaultAction];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self presentViewController:alert animated:YES completion:nil];
        DDLogDebug(@"Please check your network connection");
    } else {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        if(status == NotReachable){
            
            //No internet
            [self presentViewController:alert animated:YES completion:nil];
            DDLogDebug(@"Please check your network connection");
        } else if (status == ReachableViaWiFi) {
            
            //Connected to WiFi
            DDLogDebug(@"WiFi connection");
        } else if (status == ReachableViaWWAN) {
            
            //Connected to 3G
            DDLogDebug(@"3G connection");
        }
    }
}

/*
 * @brief When scroll, keyboard is hidden.
 * @param scrollView
 * @return none
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

/*
 * @brief Change table row height with respect to screen size
 * @param tableView
 * @param indexPath
 * @return Return calculated size of table row
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.width/5;
}

#pragma mark - Table view data source

/*
 * @brief Set number of section based on podcast array
 * @param tableView
 * @return Return 1 if podcast data is available, 0 otherwise.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.podcasts ? 1 : 0;
}

/*
 * @brief Set number of row on a section based on podcast array
 * @param tableView
 * @param section
 * @return Return total number of podcast if podcast data is available, 0 otherwise.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.podcasts ? self.podcasts.count : 0;
}

/*
 * @brief Get current table row and configure cell
 * @param tableView
 * @param indexPath
 * @return Return configured cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Podcast *podcast = [self.podcasts objectAtIndex:(indexPath.row)];
    self.thumbnail = [UIImage animatedImageNamed:@"spinner_" duration:1.0f];
    cell.smallImageView.image = self.thumbnail;
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:podcast.largeImage]
                           trackId:podcast.trackID
                         imageType:k600
                 completionHandler:^(NSURL *url){
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                         cell.smallImageView.image = self.thumbnail;
                     });
                 }];
    cell.titleLabel.text = podcast.collectionName;
    cell.subtitleLabel.text = podcast.artistName;
    cell.smallImageView.layer.cornerRadius = 20;
    cell.smallImageView.clipsToBounds = YES;
    return cell;
}

#pragma mark - Session connection

/*
 * @brief When typing text is greater than 3 character, search is working
 * @param searchBar
 * @param searchText
 * @return none
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (!searchText) return;
    if (searchText.length <= 3) {
        [self resetSearch];
    } else {
        [self performSearch];
    }
}

/*
 * @brief Clear search results
 * @return none
 */
- (void)resetSearch {
    [self.podcasts removeAllObjects];
    [self.tableView reloadData];
}

/*
 * @brief Search start
 * @return none
 */
- (void)performSearch {
    [self testConnection];
    NSString *query = self.searchBar.text;
    
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    self.dataTask = [self.session dataTaskWithURL:[self urlForQuery:query]
                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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

/*
 * @brief Url link to search
 * @param query
 * @return Return NSURL with search query
 */
- (NSURL *)urlForQuery:(NSString *)query {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?media=podcast&entity=podcast&term=%@", query]];
}

/*
 * @brief Insert search results to array
 * @param results
 * @return none
 */
- (void)processResults:(NSArray *)results {
    if (!self.podcasts) {
        self.podcasts = [NSMutableArray array];
    }
    [self.podcasts removeAllObjects];
    
    // Date format with respect to SQLite DATETIME
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for (NSDictionary *dict in results) {
        Podcast *podcast = [[Podcast alloc]init];
        [podcast setTrackID:[dict objectForKey:@"trackId"]];
        [podcast setCollectionName:[dict objectForKey:@"collectionName"]];
        [podcast setArtistName:[dict objectForKey:@"artistName"]];
        [podcast setSmallImage:[dict objectForKey:@"artworkUrl60"]];
        [podcast setLargeImage:[dict objectForKey:@"artworkUrl600"]];
        
        // Set current datetime to podcast insert date.
        NSString *dateString=[dateFormat stringFromDate:[NSDate date]];
        [podcast setInsertDate:dateString];
        
        // Add podcast to array
        [self.podcasts addObject:podcast];
    }
    [self.tableView reloadData];
}

/*
 * @brief Configure session
 * @return Return configured session
 */
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

#pragma mark - ActionMethods 

/*
 * @brief When save button is pressed, data is save to database.
 * @param sender
 * @return none
 */
- (IBAction)saveAction:(id)sender {
    if (self.podcasts || self.podcasts.count) {
        [[PodcastDBManager defaultManager] insertPodcast:self.podcasts];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 * @brief When back button is pressed, go back to previous controller.
 * @param sender
 * @return none
 */
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
