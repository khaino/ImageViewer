//
//  LVListTableViewController.m
//  ImageViewer
//
//  Created by NCAung on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVListTableViewController.h"
#import "Podcast.h"
#import "PodcastDBManager.h"
#import "IVImageDownload.h"
#import "IVScrollView.h"
#import "IVTableViewCell.h"

@interface IVListTableViewController ()
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSMutableArray *podcasts;
@property (strong, nonatomic) UIImage *thumbnail;
@end

@implementation IVListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load data from database when application start
    self.podcasts = [[NSMutableArray alloc]initWithArray:[[PodcastDBManager defaultManager] getAllPodcast]];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Load data everytime before view is displayed
    self.podcasts = [[NSMutableArray alloc]initWithArray:[[PodcastDBManager defaultManager] getAllPodcast]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

/*
 * @brief Set number of section based on podcast array.
 * @param tableView
 * @return Return 1 if podcast is not null, 0 otherwise.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.podcasts ? 1 : 0;
}

/*
 * @brief Set number of rows based on podcast array count.
 * @param tableView
 * @param section
 * @return Return total count of podcast array.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.podcasts ? self.podcasts.count : 0;
}

/*
 * @brief Set table cell to be configure
 * @param tableView
 * @param indexPath
 * @return Return configured cell
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

#pragma mark - UITableViewDataDelegate

/*
 * @brief Set table row editable or not.
 * @param tableView
 * @param indexPath
 * @return Return NO, table row cannot edit.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

/*
 * @brief Set table row movable or not.
 * @param tableView
 * @param indexPath
 * @return Return NO, table row cannot move.
 */
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

/*
 * @brief If select a row, go to scroll view with larger image.
 * @param tableView
 * @param indexPath
 * @return none
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *pageControlStoryboard = [UIStoryboard storyboardWithName:@"IVScroll" bundle:nil];
    IVScrollView *vc = [pageControlStoryboard instantiateInitialViewController];
    vc.contentList = self.podcasts;
    vc.currentImage = (int)indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
 * @brief Change table row height with respect to screen size.
 * @param tableView
 * @param indexPath
 * @return Return calculated table row height.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.width/5;
}

#pragma mark - Action methods

- (IBAction)chageGridView:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"IVGrid" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyBoard instantiateInitialViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)searchAction:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"IVSearch" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyBoard instantiateInitialViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
