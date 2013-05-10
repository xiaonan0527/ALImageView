//
//  ALContainerView.h
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIEdgeInsets ALContainerEdgeInsets;

typedef struct
{
    CGFloat x;
    CGFloat y;
} ALContainerGap;

typedef struct
{
    NSInteger column;
    NSInteger row;
    ALContainerGap gap;
} ALContainerComposition;

UIKIT_STATIC_INLINE ALContainerEdgeInsets ALContainerEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    ALContainerEdgeInsets insets = {top, left, bottom, right};
    return insets;
}

UIKIT_STATIC_INLINE ALContainerGap ALContainerGapMake(CGFloat x, CGFloat y) {
    ALContainerGap gap = {x, y};
    return gap;
}

UIKIT_STATIC_INLINE ALContainerComposition ALContainerCompositionMake(CGFloat column, CGFloat row, CGFloat x, CGFloat y) {
    ALContainerGap gap = ALContainerGapMake(x, y);
    ALContainerComposition composition = {column, row, gap};
    return composition;
}

@class ALContainerView;
typedef void (^CSelectIndexBlock)(ALContainerView *cView, NSInteger index);

@protocol ALContainerViewDelegate <NSObject>

@optional
- (void)containerView:(ALContainerView *)cView didSelectIndex:(NSInteger)index;

@end

@interface ALContainerView : UIView

@property (nonatomic, assign) ALContainerEdgeInsets edgeInsets;
@property (nonatomic, assign) ALContainerComposition composition;
@property (nonatomic, assign) BOOL isCorner;
@property (nonatomic, assign) NSInteger imageTag;
@property (nonatomic, assign) NSUInteger imageCount;
@property (nonatomic, retain) NSArray *imageURLs;

@property (nonatomic, assign) id<NSObject, ALContainerViewDelegate> delegate;

- (void)setImageCount:(NSUInteger)count imageTag:(NSInteger)tag;

- (void)setSelectIndexBlock:(CSelectIndexBlock)block;

@end
