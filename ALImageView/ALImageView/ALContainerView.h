//
//  ALContainerView.h
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//
//  Contact:jiachunke@gmail.com
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

/**
 If image count not equal to zero,the container view will layout image views with the patameter.
 */
@property (nonatomic, assign) ALContainerEdgeInsets edgeInsets;

/**
 If image count not equal to zero,the container view will layout image views with the patameter.
 */
@property (nonatomic, assign) ALContainerComposition composition;

/**
 Set the property to YES,the image view have four symmetric corner,corner radius equal to '10.0f'.
 */
@property (nonatomic, assign) BOOL isCorner;

/**
 Set a tag for image group in the container view.
 */
@property (nonatomic, assign) NSInteger groupTag;

/**
 Set a placeholder for image group in the container view.
 */
@property (nonatomic, retain) UIImage *groupPlaceholder;

/**
 The image views in the container view.
 */
@property (nonatomic, retain, readonly) NSMutableArray *imageViews;

/**
 Set image uri for images in the container view,and images will be loaded at once.
 */
@property (nonatomic, retain) NSArray *imageURLs;

/**
 Set delegate.
 */
@property (nonatomic, assign) id<NSObject, ALContainerViewDelegate> delegate;

/**
 Set block for callback.
 
 @param block
 */
- (void)setSelectIndexBlock:(CSelectIndexBlock)block;

/**
 Set image count for layout image views with group tag.
 
 @param count
 @param tag
 */
- (void)setImageCount:(NSUInteger)count groupTag:(NSInteger)tag;

@end
