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

@interface IVScrollView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
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
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.pageControl.numberOfPages = numberPages;
    self.pageControl.currentPage = self.currentImage;
    self.collectionView.delegate = self;
    
    [self gotoPage:YES];
    
    // Add single touch gesture to image view
    UITapGestureRecognizer *singleTapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.scrollView addGestureRecognizer:singleTapImage];
    self.collectionView.hidden = YES;

}

// Action for single touch on image
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
    NSLog(@"Image Touched!");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
    }
}

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
        CGRect frame = self.scrollView.frame;
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

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    });
    
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoPage:(BOOL)animated {
    
    NSInteger page = self.pageControl.currentPage;
    
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contentList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Podcast *podcast = [self.contentList objectAtIndex:indexPath.row];
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:podcast.smallImage]
                           trackId:podcast.trackID
                         imageType:k60
                 completionHandler:^(NSURL *url){
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIImage *image= [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                         UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                         cell.backgroundView = imageView;
                     });
                 }];
    return cell;
}

// Action for selecting a thumbnail on collection slider
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Click at index %ld",(long)indexPath.row);
    self.pageControl.currentPage = indexPath.row;
    [self gotoPage:YES];
}

@end