//
//  IVGridLayout.h
//  ImageViewer
//
//  Created by Khaino on 5/26/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IVGridLayoutDelegate

- (CGFloat)collectionView:(UICollectionView*)collectionView heightForPhotoAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width;
- (CGFloat)collectionView:(UICollectionView*)collectionView heightForAnnotationAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width;

@end

@interface IVGridLayout : UICollectionViewLayout

@property(weak, nonatomic)id<IVGridLayoutDelegate> delegate;

@end


