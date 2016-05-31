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
static int count = 0;

+(void)initialize {
    initializeClassVars();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.clearsSelectionOnViewWillAppear = NO;
    
    IVGridLayout *layout = (IVGridLayout*)self.collectionView.collectionViewLayout;
    self.collectionView.contentInset = UIEdgeInsetsMake(23, 5, 10, 5);

    layout.delegate = self;
    
    self.indexSet = [NSMutableSet set];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.podcasts = [[NSMutableArray alloc]initWithArray:[[PodcastDBManager defaultManager] getAllPodcast]];
//    NSLog(@"Podcoast count : %lu", (unsigned long)[self.podcasts count]);
    self.collectionView.backgroundColor = [UIColor grayColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Register cell classes
//    [self.collectionView registerClass:[GridCell class] forCellWithReuseIdentifier:reuseIdentifier];
//    [self.collectionView reloadData];

}


#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    
    return self.podcasts.count;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"indexPath : %@", indexPath);
    NSLog(@"item : %ld", (long)indexPath.item);
//    NSLog(@"Count : %d",count++);
    
    
    GridCell *cell = (GridCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    //    cell.backgroundColor = [UIColor greenColor];
    Podcast *podcast = [self.podcasts objectAtIndex:indexPath.row];
    NSNumber *index = [NSNumber numberWithInteger:indexPath.row];
    [self.indexSet addObject:index];
    
//    NSLog(@"collection : %@", podcast.collectionName);
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:10];
    [cell.collectionName setFont:font];
    
    // cell.collectionName.lineBreakMode = NSLineBreakByWordWrapping;
    cell.collectionName.numberOfLines = 0;
//    cell.collectionName.text = podcast.collectionName;
    cell.collectionName.text = @"This is just test";
    if (cell == nil) {
        NSLog(@"Cell is nil");
    }
    
    if (cell.collectionName.text == nil) {
        NSLog(@"Cell collection name is nil");
    }
    
    [[[IVImageDownload alloc]init] downloadImage:[NSURL URLWithString:podcast.smallImage]  trackId:podcast.trackID imageType:k60 completionHandler:^(NSURL *url) {
        
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        if (cell.imageView.image == nil) {
            NSLog(@"Image view is nill");
        }
       
    }];
    
    return cell;

}



// Implementation of IVGridLayoutDelegate


- (CGFloat)collectionView:(UICollectionView*)collectionView heightForPhotoAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width{
    
    Podcast *podcast = [self.podcasts objectAtIndex:indexPath.row];
    CGRect boundingRect = CGRectMake(0, 0, width, MAXFLOAT);

    CGFloat height = 0.0;
    CGSize size = CGSizeMake(60, 60);
    __block CGRect rect;
    [[[IVImageDownload alloc]init] downloadImage:[NSURL URLWithString:podcast.smallImage]  trackId:podcast.trackID imageType:k60 completionHandler:^(NSURL *url) {
        
        
       UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
       rect = AVMakeRectWithAspectRatioInsideRect(image.size, boundingRect);
        
    }];

    if (height == 0.0) {
        height = 2 * width;
    }
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
//    NSLog(@"Comment text : %@ | Height : %f",podcast.collectionName, height);
    
    return height;
}

// UICollectionViewDataSource end -- UICollectionViewDelegateFlowLayout start ----------------------

//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//   
//    
//    CGSize returnSize;
//    //    if(flickrPhoto.thumbnail == nil) {
//    
//    //    }else {
//    ////        returnSize = flickrPhoto.thumbnail.size;
//            returnSize = CGSizeMake(60, 60);
//    //    }
//
////    returnSize.width += 10;
////    returnSize.height += 10;
////    
////    Podcast *podcast = [self.podcasts objectAtIndex:indexPath.row];
////    BOOL isCached = [[IVCacheManager defaultManager]isImageCached:podcast.trackID imageType:k60];
////    
////    if (isCached) {
////        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[IVCacheManager defaultManager] imageDirForTrackId:podcast.trackID imageType:k60]]];
////        
//////        let boundingRect =  CGRect(x: 0, y: 0, width: 60, height: CGFloat( ))
////        
//////        CGRect boundingRect = CGRectMake(0, 0, 60, 60);
//////        CGRect rect  = AVMakeRectWithAspectRatioInsideRect(image.size, boundingRect);
////        return rect.size;
////        
//////        returnSize = image.size;
////    }else {
////        returnSize = CGSizeMake(40, 40);
////    }
////    
//    return returnSize;
//}
//
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return sectionInsets;
//}
//


#pragma mark <UICollectionViewDelegate>



/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
- (IBAction)toList:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"IVList" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyBoard instantiateInitialViewController];
    [self presentViewController:navigationController animated:YES completion:nil];

}

@end
