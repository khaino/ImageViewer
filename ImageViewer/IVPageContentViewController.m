//
//  IVPageContentViewController.m
//  ImageViewer
//
//  Created by user on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVPageContentViewController.h"

@interface IVPageContentViewController ()

@end

@implementation IVPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    // Display spinner while image is downloading
    self.image = [UIImage animatedImageNamed:@"spinner_" duration:1.0f];
    self.spinnerImageView.image = self.image;

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *imageURL = [NSURL URLWithString:self.imageFile];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                       
        // Completion handler
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            
           // If self.image is atomic (not declared with nonatomic)
           // you could have set it directly above
            self.spinnerImageView.image = nil;
            self.image = [UIImage imageWithData:imageData];
                           
           // This needs to be set here now that the image is downloaded and you are back on the main thread
            self.imageView.image = self.image;
            
       });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
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
