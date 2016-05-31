//
//  RootViewController2.m
//  ImageViewer
//
//  Created by user on 5/23/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "RootViewController2.h"
#import "Podcast.h"
#import "IVImageDownload.h"
#import "IVPageContentViewController.h"

@interface RootViewController2 ()

@end

@implementation RootViewController2

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    IVPageContentViewController *startingViewController = [self viewControllerAtIndex:self.currentImage];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60);
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    
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
    [self objectInPageViewControllerAtIndex:indexPath.row];
    NSLog(@"Collection id %d is touched!", indexPath.row);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((IVPageContentViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((IVPageContentViewController*) viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.podcasts count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)objectInPageViewControllerAtIndex:(NSUInteger)index {
    return [self viewControllerAtIndex:index];
}

- (IVPageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (([self.podcasts count] == 0) || (index >= [self.podcasts count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    IVPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.podcast = [self.podcasts objectAtIndex:index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}


@end
