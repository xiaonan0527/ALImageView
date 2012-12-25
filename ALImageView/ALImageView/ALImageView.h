//
//  ALImageView.h
//  ALImageView
//
//  Created by SpringOx on 12-8-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define ALImageViewQueuePriorityDefault  0
#define ALImageViewQueuePriorityHigh  1

@class ALImageView;
@protocol ALImageViewDelegate <NSObject>

@optional
- (void)imageView:(ALImageView *)imgView didAsynchronousLoadImage:(UIImage *)img;

@end


@interface ALImageView : UIImageView

@property (nonatomic, retain) UIImage *bgImage;
@property (nonatomic, readwrite) NSInteger index;
@property (nonatomic, retain) NSString *thumbnailPath;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *remotePath;
@property (nonatomic, retain) NSString *cacheDirectory;
@property (nonatomic, readwrite) BOOL asyncLoadImageFinished;
@property (nonatomic, readwrite) NSInteger queuePriority;
@property (nonatomic, readwrite) BOOL isCorner;

@property (nonatomic, assign) id<NSObject, ALImageViewDelegate> delegate;

- (void)asyncLoadImageWithURL:(NSURL *)url;

- (void)addTarget:(id)target action:(SEL)action;

@end
