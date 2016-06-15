//
//  IVSearchViewController.m
//  ImageViewer
//
//  Created by NCAung on 6/10/16.
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
}

/*
 When scroll, keyboard is hidden.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

/*
 When typing text is greater than 3 character, search is working
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (!searchText) return;
    if (searchText.length <= 3) {
        [self resetSearch];
    } else {
        [self performSearch];
    }
}

- (void)resetSearch {
    [self.podcasts removeAllObjects];
    [self.tableView reloadData];
}

- (void)performSearch {
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

- (NSURL *)urlForQuery:(NSString *)query {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?media=podcast&entity=podcast&term=%@", query]];
}

- (void)processResults:(NSArray *)results {
    if (!self.podcasts) {
        self.podcasts = [NSMutableArray array];
    }
    [self.podcasts removeAllObjects];
    for (NSDictionary *dict in results) {
        Podcast *podcast = [[Podcast alloc]init];
        [podcast setTrackID:[dict objectForKey:@"trackId"]];
        [podcast setCollectionName:[dict objectForKey:@"collectionName"]];
        [podcast setArtistName:[dict objectForKey:@"artistName"]];
        [podcast setSmallImage:[dict objectForKey:@"artworkUrl60"]];
        [podcast setLargeImage:[dict objectForKey:@"artworkUrl600"]];
        [self.podcasts addObject:podcast];
    }
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

- (IBAction)saveAction:(id)sender {
    for (Podcast *podcast in self.podcasts) {
        [[PodcastDBManager defaultManager] insertPodcast:podcast];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
