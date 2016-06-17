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


@interface IVGridViewController ()<IVGridLayoutDelegate>
/** Podcast array */
@property (strong, nonatomic) NSMutableArray *podcasts;

@end

// Constant values
const CGFloat HORIZONTAL_PADDING = 10;
const CGFloat VERTICAL_PADDING = 15;
const CGFloat INDICATOR_WIDTH = 4;
const CGFloat ANNOTATION_PADDING = 2;

@implementation IVGridViewController

// Constant values
static NSString * const reuseIdentifier = @"gridCell";

/*
 * @brief viewDidLoad.
 * @return none.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.title = NSLocalizedString(@"GRID_TITLE", nil);
    
    IVGridLayout *layout = (IVGridLayout*)self.collectionView.collectionViewLayout;
    self.collectionView.contentInset = UIEdgeInsetsMake(VERTICAL_PADDING, HORIZONTAL_PADDING, VERTICAL_PADDING, HORIZONTAL_PADDING - INDICATOR_WIDTH);
    layout.delegate = self;    
}

/*
 * @brief viewWillAppear.
 * @param animated animation.
 * @return none.
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.podcasts = [[NSMutableArray alloc]initWithArray:[[PodcastDBManager defaultManager] getAllPodcast]];
    
}

/*
 * @brief viewWillTransitionToSize.
 * @param size size.
 * @param coordinator coordinateor.
 * @return none.
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    IVGridLayout *layout = (IVGridLayout*)self.collectionView.collectionViewLayout;
    [layout invalidateLayout];
    layout.isRotate = YES;
}



#pragma mark- Collection Datasource methods

/*
 * @brief Get number of sections.
 * @param collectionView collection view.
 * @return number of section.
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

/*
 * @brief Get number of items in the given section.
 * @param collectionView collection view.
 * @param section current section.
 * @return number of section.
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.podcasts.count;
}

/*
 * @brief Get collection cell for the given index path
 * @param collectionView collection view.
 * @param indexPath index path.
 * @return collection view cell.
 */
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

#pragma mark- Collection Delegate methods
/*
 * @brief Handle when collecition cell is selected
 * @param collectionView collection view.
 * @param indexPath index path.
 * @return none.
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *pageControlStoryboard = [UIStoryboard storyboardWithName:@"IVScroll" bundle:nil];
    IVScrollView *vc = [pageControlStoryboard instantiateInitialViewController];
    vc.contentList = self.podcasts;
    vc.currentImage = (int)indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
    
}



#pragma mark- GridLayout Delegate methods
/*
 * @brief Get the aspect ratio height of photo
 * @param collectionView collection view.
 * @param width width of cell.
 * @return none.
 */
- (CGFloat)collectionView:(UICollectionView*)collectionView heightForPhotoAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width{
    
    CGRect boundingRect = CGRectMake(0, 0, width, MAXFLOAT);
    CGSize size = CGSizeMake(60, 60);
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(size, boundingRect);

    return rect.size.height;
}

/*
 * @brief Get height of annotation
 * @param collectionView collection view.
 * @param width width of cell.
 * @return none.
 */
- (CGFloat)collectionView:(UICollectionView*)collectionView heightForAnnotationAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width{
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    Podcast *podcast = [self.podcasts objectAtIndex:(indexPath.row)];
    CGRect rect = [podcast.collectionName boundingRectWithSize:CGSizeMake(width - 8, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    CGFloat commentHeight = rect.size.height;
    CGFloat height = ANNOTATION_PADDING + commentHeight + ANNOTATION_PADDING;
    
    return height;
}

#pragma mark- Action methods

/*
 * @brief Go to list view table
 * @param sender list button.
 * @return none.
 */
- (IBAction)toList:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 * @brief Go to search view controller
 * @param sender list button.
 * @return none.
 */
- (IBAction)searchAction:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"IVSearch" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyBoard instantiateInitialViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
@end
