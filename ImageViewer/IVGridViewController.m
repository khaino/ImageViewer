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


@interface IVGridViewController ()<IVGridLayoutDelegate>

@property (strong, nonatomic) NSMutableArray *podcasts;
@property (strong, nonatomic) NSMutableSet *indexSet;

@end
static BOOL classVarsInitialized = NO;
static UIEdgeInsets sectionInsets;

static void initializeClassVars() {
    if(classVarsInitialized) {
        return;
    }
    
    sectionInsets = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    classVarsInitialized = YES;
}

@implementation IVGridViewController

static NSString * const reuseIdentifier = @"gridCell";

+(void)initialize {
    initializeClassVars();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    IVGridLayout *layout = (IVGridLayout*)self.collectionView.collectionViewLayout;
    self.collectionView.contentInset = UIEdgeInsetsMake(23, 5, 10, 5);

    layout.delegate = self;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.podcasts = [[NSMutableArray alloc]initWithArray:[[PodcastDBManager defaultManager] getAllPodcast]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
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
    NSNumber *index = [NSNumber numberWithInteger:indexPath.row];
    [self.indexSet addObject:index];
    
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:10];
    [cell.collectionName setFont:font];
    
    cell.collectionName.numberOfLines = 0;
    cell.collectionName.text = podcast.collectionName;
 
    [[[IVImageDownload alloc]init] downloadImage:[NSURL URLWithString:podcast.smallImage]  trackId:podcast.trackID imageType:k60 completionHandler:^(NSURL *url) {
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }];
    
    return cell;
}



// Implementation of IVGridLayoutDelegate

- (CGFloat)collectionView:(UICollectionView*)collectionView heightForPhotoAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width{
    
    CGRect boundingRect = CGRectMake(0, 0, width, MAXFLOAT);
    CGSize size = CGSizeMake(60, 60);
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(size, boundingRect);

    return rect.size.height;
}


- (CGFloat)collectionView:(UICollectionView*)collectionView heightForAnnotationAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width{
    
    CGFloat annotationPadding = 2;
    CGFloat annotationHeaderHeight =  0;//17;
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:10];
    Podcast *podcast = [self.podcasts objectAtIndex:(indexPath.row)];
    CGRect rect = [podcast.collectionName boundingRectWithSize:CGSizeMake(width - 8, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    CGFloat commentHeight = rect.size.height;
    CGFloat height = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding;
    
    return height;
}

- (IBAction)toList:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"IVList" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyBoard instantiateInitialViewController];
    [self presentViewController:navigationController animated:YES completion:nil];

}

@end
