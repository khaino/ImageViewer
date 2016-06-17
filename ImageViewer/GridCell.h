//
//  GridCell.h
//  ImageViewer
//
//  Created by Khaino on 5/19/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedConerView.h"

/** This class is for custom collection view cell */
@interface GridCell : UICollectionViewCell
/** Rounded coner view */
@property (weak, nonatomic) IBOutlet RoundedConerView *roundedCorner;
/** Image view in collection view cell */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/** Name of collection */
@property (weak, nonatomic) IBOutlet UILabel *collectionName
;

@end
