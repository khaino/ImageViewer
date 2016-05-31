//
//  IVPageContentViewController.m
//  ImageViewer
//
//  Created by user on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVPageContentViewController.h"
#import "IVImageDownload.h"

@interface IVPageContentViewController ()

@end

@implementation IVPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Display spinner while image is downloading
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.activityIndicatorView startAnimating];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSURL *imageURL = [NSURL URLWithString:self.imageFile];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//        
//        // Completion handler
//        dispatch_sync(dispatch_get_main_queue(), ^{
//
//            [self.activityIndicatorView stopAnimating];
//            self.image = [UIImage imageWithData:imageData];
//            
//            // This needs to be set here now that the image is downloaded and you are back on the main thread
//            self.imageView.image = self.image;
//            
//        });
//    });
    
    IVImageDownload *imageDownloader = [[IVImageDownload alloc]init];
    [imageDownloader downloadImage:[NSURL URLWithString:self.podcast.largeImage]
                           trackId:self.podcast.trackID
                         imageType:k600
                 completionHandler:^(NSURL *url){
                     [self.activityIndicatorView stopAnimating];
//                     [self.overlayImageView setHidden:YES];
                     self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                 }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
