//
//  ALContainerView.h
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AL_CONTAINER_VIEW_COLUMN_COUNT     2
#define AL_CONTAINER_VIEW_ROW_COUNT     3

#define AL_CONTAINER_VIEW_MARGIN_LR    20.f     // left margin and right margin
#define AL_CONTAINER_VIEW_MARGIN_UP     20.f    // up margin
#define AL_CONTAINER_VIEW_MARGIN_DOWN   40.f    // down margin
#define AL_CONTAINER_VIEW_GAP_X    20.f         // gap in the horizontal direction
#define AL_CONTAINER_VIEW_GAP_Y    16.f         // gap in the vertical direction

@class ALContainerView;
typedef void (^CSelectIndexBlock)(ALContainerView *cView, NSInteger index);

@protocol ALContainerViewDelegate <NSObject>

@optional
- (void)containerView:(ALContainerView *)cView didSelectIndex:(NSInteger)index;

@end

@interface ALContainerView : UIView

@property (nonatomic, readwrite) NSInteger fromIndex;
@property (nonatomic, readwrite) NSUInteger imageCount;
@property (nonatomic, retain) NSArray *imageURLs;

@property (nonatomic, assign) id<NSObject, ALContainerViewDelegate> delegate;

- (void)setImageCount:(NSUInteger)count fromIndex:(NSInteger)index;

- (void)setSelectIndexBlock:(CSelectIndexBlock)block;

@end
