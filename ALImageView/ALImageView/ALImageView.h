//
//  ALImageView.h
//  ALImageView
//
//  Created by SpringOx on 12-8-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define AL_IMAGE_VIEW_REQUEST_RETRY_COUNT   2
#define AL_IMAGE_VIEW_LOCAL_CAHCE_DIRECTORY   @"ALImages"

typedef enum {
    ALImageQueuePriorityLow = 0,
    ALImageQueuePriorityNormal,
    ALImageQueuePriorityHigh,
} ALImageQueuePriority;

@class ALImageView;
@protocol ALImageViewDelegate <NSObject>

@optional
- (void)imageView:(ALImageView *)imgView didAsynchronousLoadImage:(UIImage *)img;

@end

@interface ALImageView : UIImageView

@property (nonatomic, retain) UIImage *placeholderImage;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, retain) NSString *remotePath;
@property (nonatomic, assign) BOOL asyncLoadImageFinished;
@property (nonatomic, assign) ALImageQueuePriority queuePriority;
@property (nonatomic, assign) BOOL indicatorEnabled;
@property (nonatomic, assign) BOOL localCacheEnabled;
@property (nonatomic, assign) BOOL isCorner;

@property (nonatomic, assign) id<NSObject, ALImageViewDelegate> delegate;

+ (NSString *)localCacheDirectory;

- (void)loadImage:(NSString *)remotePath placeholderImage:(UIImage *)placeholderImage;

- (void)addTarget:(id)target action:(SEL)action;

@end
