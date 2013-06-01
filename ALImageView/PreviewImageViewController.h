//
//  PreviewImageViewController.h
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//
//  Contact:jiachunke@gmail.com
//

#import <UIKit/UIKit.h>
#import "ALContainerView.h"

@interface PreviewImageViewController : UIViewController<UIScrollViewDelegate, ALContainerViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *pageNumLabel;

@end
