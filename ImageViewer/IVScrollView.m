//
//  IVScrollView.m
//  NewPageControl
//
//  Created by Khaino on 5/25/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVScrollView.h"
#import "MyViewController.h"
#import "Podcast.h"
#import "IVImageDownload.h"
#import "IVCollectionViewCell.h"

@interface IVScrollView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (strong, nonnull) UIBarButtonItem *actionButton;
@end

@implementation IVScrollView

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUInteger numberPages = self.contentList.count;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++){
        [controllers addObject:[NSNull null]];
    }
    
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * numberPages, CGRectGetHeight(self.view.bounds));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.pageControl.numberOfPages = numberPages;
    self.pageControl.currentPage = self.currentImage;
    self.collectionView.delegate = self;
    
    [self gotoPage:NO];
    
    // Single touch gesture to image view
    UITapGestureRecognizer *singleTapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.scrollView addGestureRecognizer:singleTapImage];
    self.collectionView.hidden = YES;
    
    // Share button to navigation
    self.actionButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                     target:self
                                                                     action:@selector(shareButton:)];
    self.navigationItem.rightBarButtonItem = self.actionButton;
}

/*
 Go to view controller based on user select
 */
- (void)gotoPage:(BOOL)animated {
    
    NSInteger page = self.pageControl.currentPage;
    
    // Set navigation title to artist name
    Podcast *podcast = [self.contentList objectAtIndex:page];
    self.navigationItem.title = podcast.artistName;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (page >= self.contentList.count) {
            return;
        }
        if (page == 0) {
            [self loadScrollViewWithPage:page];
            [self loadScrollViewWithPage:page + 1];
        }
        if (page == self.contentList.count - 1) {
            [self loadScrollViewWithPage:page - 1];
            [self loadScrollViewWithPage:page];
        }
        if (page > 0 && page < self.contentList.count - 1){
            // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
            [self loadScrollViewWithPage:page - 1];
            [self loadScrollViewWithPage:page];
            [self loadScrollViewWithPage:page + 1];
        }
        
        // update the scroll view to the appropriate page
        CGRect bounds = self.scrollView.bounds;
        bounds.origin.x = CGRectGetWidth(bounds) * page;
        bounds.origin.y = 0;
        [self.scrollView scrollRectToVisible:bounds animated:animated];
        [UIView transitionWithView:self.collectionView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void){
                            self.collectionView.hidden = NO;
                        }
                        completion:nil];
        self.collectionView.hidden = YES;
        
    });
    
}

/*
 Create view controller with scrollview and imageview
 */
- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= self.contentList.count) {
        return;
    }
    // replace the placeholder if necessary
    MyViewController *controller = [self.viewControllers objectAtIndex:page];
    
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[MyViewController alloc] init];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addChildViewController:controller];
            [self.scrollView addSubview:controller.view];
            [controller didMoveToParentViewController:self];
        });
        
        Podcast *podcast = [self.contentList objectAtIndex:page];
        
        IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
        [imageDownloader downloadImage:[NSURL URLWithString:podcast.largeImage]
                               trackId:podcast.trackID
                             imageType:k600
                     completionHandler:^(NSURL *url){
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [controller.activityIndicator stopAnimating];
                             controller.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                         });
                     }];
    }
}


/*
 Gesture handler for single touch on image
 */
- (void)singleTap:(UITapGestureRecognizer *)gesture {
    if (self.collectionView.hidden) {
        [UIView transitionWithView:self.collectionView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void){
                            self.collectionView.hidden = NO;
                        }
                        completion:nil];
    } else {
        [UIView transitionWithView:self.collectionView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void){
                            self.collectionView.hidden = YES;
                        }
                        completion:nil];
    }
}

/*
 Action handler for share button
 */
- (IBAction)shareButton:(UIBarButtonItem *)sender {

    Podcast *podcast = [self.contentList objectAtIndex:self.pageControl.currentPage];
    
    __block UIImage *image = [[UIImage alloc]init];
    
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:podcast.largeImage]
                           trackId:podcast.trackID
                         imageType:k600
                 completionHandler:^(NSURL *url){
                     image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                     NSArray *array = @[image];
                     UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
                     
                         // Only for iPad
                         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                             
                             // If possible, display as model popup (such as on iPad).
                             activityVC.modalPresentationStyle = UIModalPresentationPopover;
                             
                             // Configure the Popover presentation controller
                             UIPopoverPresentationController *popController = [activityVC popoverPresentationController];
                             popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                             popController.barButtonItem = self.actionButton;
                         }
                         [self presentViewController:activityVC animated:YES completion:nil];
                 }];
}

/*
 Prevent vertical scrolling
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
    }
}

/*
 Create smooth scrolling
 at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.bounds);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // Zoom out the image when scroll to another image
    if (self.pageControl.currentPage != page){
        
        // replace the placeholder if necessary
        MyViewController *controller = [self.viewControllers objectAtIndex:self.pageControl.currentPage];
        [controller zoomOut];
        self.pageControl.currentPage = page;
    }
    
    // Set navigation title to artist name
    Podcast *podcast = [self.contentList objectAtIndex:page];
    self.navigationItem.title = podcast.artistName;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    });
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contentList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    Podcast *podcast = [self.contentList objectAtIndex:indexPath.row];
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:podcast.largeImage]
                           trackId:podcast.trackID
                         imageType:k600
                 completionHandler:^(NSURL *url){
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIImage *image= [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                         cell.imageView.image = image;
                     });
                 }];
    cell.imageView.layer.cornerRadius = 20;
    return cell;
}

/*
 Action for selecting a thumbnail on collection slider
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.pageControl.currentPage = indexPath.row;
    [self gotoPage:YES];
}

/*
 Handling rotation
 When rotate create new array
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSUInteger numberPages = self.contentList.count;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++){
        [controllers addObject:[NSNull null]];
    }
    
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * numberPages, CGRectGetHeight(self.view.bounds));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.pageControl.numberOfPages = numberPages;
    self.collectionView.delegate = self;
    
    [self gotoPage:NO];
}

@end
