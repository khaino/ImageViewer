//
//  IVGridLayout.h
//  ImageViewer
//
//  Created by Khaino on 5/26/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

/** This protocol is to get height of cell */
@protocol IVGridLayoutDelegate

/*
 * @brief Get the aspect ratio height of photo
 * @param collectionView collection view.
 * @param width width of cell.
 * @return none.
 */
- (CGFloat)collectionView:(UICollectionView*)collectionView heightForPhotoAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width;

/*
 * @brief Get height of annotation
 * @param collectionView collection view.
 * @param width width of cell.
 * @return none.
 */
- (CGFloat)collectionView:(UICollectionView*)collectionView heightForAnnotationAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width;

@end

/** This classs is to define custom layout for collection view */
@interface IVGridLayout : UICollectionViewLayout

/** Grid layout delegate protocol */
@property(weak, nonatomic)id<IVGridLayoutDelegate> delegate;
/** Number of column in the collection view */
@property(nonatomic)NSInteger numberOfColumns;
/** Is the screen rotated*/
@property (nonatomic)BOOL isRotate;

@end


