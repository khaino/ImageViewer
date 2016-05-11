//
//  ViewController.m
//  ImageViewer
//
//  Created by Khaino on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IVList" bundle:nil];
    UINavigationController *nc = (UINavigationController *)[storyboard instantiateInitialViewController];
    [self presentViewController:nc animated:YES completion:NULL];
}
@end
