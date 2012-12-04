//
//  ALImageView.h
//  ALImageView
//
//  Created by SpringOx on 12-8-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALImageViewQueuePriorityDefault  0
#define ALImageViewQueuePriorityHigh  1


@interface ALImageView : UIImageView

@property (nonatomic, retain) UIImage *bgImage;
@property (nonatomic, readwrite) NSInteger index;
@property (nonatomic, retain) NSString *thumbnailPath;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *remotePath;
@property (nonatomic, retain) NSString *cacheDirectory;
@property (nonatomic, readwrite) BOOL asyncLoadImageFinished;
@property (nonatomic, readwrite) NSInteger queuePriority;

- (void)asyncLoadImageWithURL:(NSURL *)url;

- (void)addTarget:(id)target action:(SEL)action;

@end
