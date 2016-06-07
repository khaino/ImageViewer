//
//  IVGridViewController.m
//  ImageViewer
//
//  Created by Khaino on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVGridViewController.h"
#import "DownloadJSON.h"
#import "Podcast.h"
#import "GridCell.h"
#import "IVImageDownload.h"
#import "IVCacheManager.h"
#import "IVGridLayout.h"
#import "AVFoundation/AVFoundation.h"
#import "IVScrollView.h"
#import "AnimatedViewController.h"


@interface IVGridViewController ()<IVGridLayoutDelegate>

@property (strong, nonatomic) NSMutableArray *podcasts;
@property (nonatomic)CGPoint scrollPositionBeforeRotation;

@end

const CGFloat HORIZONTAL_PADDING = 10;
const CGFloat VERTICAL_PADDING = 15;
const CGFloat INDICATOR_WIDTH = 4;
const CGFloat ANNOTATION_PADDING = 2;

@implementation IVGridViewController

static NSString * const reuseIdentifier = @"gridCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.title = @"Podcasts Collection";
    
    IVGridLayout *layout = (IVGridLayout*)self.collectionView.collectionViewLayout;
    self.collectionView.contentInset = UIEdgeInsetsMake(VERTICAL_PADDING, HORIZONTAL_PADDING, VERTICAL_PADDING, HORIZONTAL_PADDING - INDICATOR_WIDTH);
    layout.delegate = self;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.podcasts = [[NSMutableArray alloc]initWithArray:[[PodcastDBManager defaultManager] getAllPodcast]];
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.podcasts.count;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GridCell *cell = (GridCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Podcast *podcast = [self.podcasts objectAtIndex:indexPath.row];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [cell.collectionName setFont:font];
    
    cell.collectionName.numberOfLines = 0;
    cell.collectionName.text = podcast.collectionName;
 
    [[[IVImageDownload alloc]init] downloadImage:[NSURL URLWithString:podcast.smallImage]  trackId:podcast.trackID imageType:k60 completionHandler:^(NSURL *url) {
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *pageControlStoryboard = [UIStoryboard storyboardWithName:@"IVScroll" bundle:nil];
    IVScrollView *vc = [pageControlStoryboard instantiateInitialViewController];
    vc.contentList = self.podcasts;
    vc.currentImage = (int)indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    IVGridLayout *layout = (IVGridLayout*)self.collectionView.collectionViewLayout;
    [layout invalidateLayout];
    layout.isRotate = YES;
}


// Implementation of IVGridLayoutDelegate

- (CGFloat)collectionView:(UICollectionView*)collectionView heightForPhotoAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width{
    
    CGRect boundingRect = CGRectMake(0, 0, width, MAXFLOAT);
    CGSize size = CGSizeMake(60, 60);
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(size, boundingRect);

    return rect.size.height;
}


- (CGFloat)collectionView:(UICollectionView*)collectionView heightForAnnotationAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width{
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    Podcast *podcast = [self.podcasts objectAtIndex:(indexPath.row)];
    CGRect rect = [podcast.collectionName boundingRectWithSize:CGSizeMake(width - 8, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    CGFloat commentHeight = rect.size.height;
    CGFloat height = ANNOTATION_PADDING + commentHeight + ANNOTATION_PADDING;
    
    return height;
}

#pragma private method


- (IBAction)toList:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
