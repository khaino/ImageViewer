//
//  IVCollectionView.m
//  ImageViewer
//
//  Created by user on 5/23/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVCollectionView.h"
#import "Podcast.h"
#import "IVImageDownload.h"

@interface IVCollectionView ()

@end

@implementation IVCollectionView

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView setHidden:YES];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        Podcast *podcast = [self.podcasts objectAtIndex:self.currentImage];
//        NSURL *imageURL = [NSURL URLWithString:podcast.largeImage];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self.activityIndicator stopAnimating];
//            [self.overlayImageView setHidden:YES];
//            self.imageView.image = [UIImage imageWithData:imageData];
//        });
//    });
    Podcast *podcast = [self.podcasts objectAtIndex:self.currentImage];
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:podcast.largeImage]
                           trackId:podcast.trackID
                         imageType:k600
                 completionHandler:^(NSURL *url){
                     [self.activityIndicator stopAnimating];
                     [self.overlayImageView setHidden:YES];
                     self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                 }];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Add single touch gesture to image view
    UITapGestureRecognizer *singleTapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TouchImage:)];
    [self.imageView addGestureRecognizer:singleTapImage];
}

// Action for single touch on image
- (void)TouchImage:(UITapGestureRecognizer *)gesture {
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.podcasts ? 1 : 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.podcasts ? self.podcasts.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
     
//    // Configure the cell
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            Podcast *podcast = [self.podcasts objectAtIndex:indexPath.row];
//            NSURL *imageURL = [NSURL URLWithString:podcast.smallImage];
//            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//            
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                UIImage *image= [UIImage imageWithData:imageData];
//                UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
//                cell.backgroundView = imageView;
//            });
//        });
    Podcast *podcast = [self.podcasts objectAtIndex:indexPath.row];
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:podcast.smallImage]
                           trackId:podcast.trackID
                         imageType:k60
                 completionHandler:^(NSURL *url){
                     UIImage *image= [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                     UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                     cell.backgroundView = imageView;
                 }];
    
    return cell;
}

// Action for selecting a thumbnail on collection slider
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator setHidden:NO];
    [self.overlayImageView setHidden:NO];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        Podcast *podcast = [self.podcasts objectAtIndex:indexPath.row];
//        NSURL *imageURL = [NSURL URLWithString:podcast.largeImage];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//        
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self.activityIndicator stopAnimating];
//            [self.overlayImageView setHidden:YES];
//            self.imageView.image = [UIImage imageWithData:imageData];
//            NSLog(@"Photo %d is touched!", indexPath.row);
//        });
//    });
    
    Podcast *podcast = [self.podcasts objectAtIndex:indexPath.row];
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:podcast.largeImage]
                           trackId:podcast.trackID
                         imageType:k600
                 completionHandler:^(NSURL *url){
                     [self.activityIndicator stopAnimating];
                     [self.overlayImageView setHidden:YES];
                     self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                 }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
