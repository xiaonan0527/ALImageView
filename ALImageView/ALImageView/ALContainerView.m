//
//  ALContainerView.m
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//
//  Contact:jiachunke@gmail.com
//

#import "ALContainerView.h"
#import "ALImageView.h"

UIKIT_STATIC_INLINE NSInteger RowCount(NSInteger count, NSInteger column) {
    return (count%column ? (count/column+1) : count/column);
}

@interface ALContainerView ()
{
    CSelectIndexBlock _selectIndexBlock;
}

@end

@implementation ALContainerView

- (void)setEdgeInsets:(ALContainerEdgeInsets)edgeInsets
{
    _edgeInsets = edgeInsets;
    [self setNeedsLayout];
}

- (void)setComposition:(ALContainerComposition)composition
{
    _composition = composition;
    [self setNeedsLayout];
}

- (void)setIsCorner:(BOOL)isCorner
{
    _isCorner = isCorner;
    if (_isCorner) {
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;
    } else {
        self.layer.cornerRadius = 0.0f;
        self.clipsToBounds = NO;
    }
}

- (void)setImageURLs:(NSArray *)imageURLs
{
    if (_imageURLs != imageURLs) {
        if (nil != _imageURLs) {
            NSUInteger viewCount = [_imageViews count];
            NSUInteger urlCount = [_imageURLs count];
            int i = 0;
            while (viewCount > i && urlCount > i) {
                ALImageView *view = [_imageViews objectAtIndex:i];
                view.imageURL = nil;
                i++;
            }
            [_imageURLs release];
            _imageURLs = nil;
        }
        
        if (nil != imageURLs) {
            _imageURLs = [imageURLs retain];
            
        }
    }
    
    if (nil != _imageURLs) {
        NSUInteger tempCount = [_imageViews count];
        int i = 0;
        for (NSString *u in _imageURLs) {
            if (tempCount == i) {
                break;
            }
            if (0 < [u length]) {
                ALImageView *view = [_imageViews objectAtIndex:i];
                view.imageURL = u;
            }
            i++;
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _edgeInsets = ALContainerEdgeInsetsMake(20.f, 20.f, 20.f, 20.f);
    _composition = ALContainerCompositionMake(2, 3, 20.f, 16.f);
    _groupTag = -UINT_MAX;
}

- (void)dealloc
{
    self.imageURLs = nil;
    if (nil != _imageViews) {
        [_imageViews release];
        _imageViews = nil;
    }
    if (nil != _selectIndexBlock) {
        [_selectIndexBlock release];
        _selectIndexBlock = nil;
    }
    [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)layoutSubviews
{
    [self layoutImageViews];
}

- (void)setSelectIndexBlock:(CSelectIndexBlock)block
{
    if (_selectIndexBlock == block) {
        return;
    }
    
    if (nil != _selectIndexBlock) {
        [_selectIndexBlock release];
        _selectIndexBlock = nil;
    }
    
    if (nil != block) {
        _selectIndexBlock = [block copy];
    }
}

- (void)layoutImageViews
{
    NSUInteger tempCount = [_imageViews count];
    
    CGFloat xL = _edgeInsets.left;
    CGFloat xR = _edgeInsets.right;
    CGFloat yU = _edgeInsets.top;
    CGFloat yD = _edgeInsets.bottom;
    NSInteger column = _composition.column;
    NSInteger row = _composition.row>=RowCount(tempCount, _composition.column) ? _composition.row : RowCount(tempCount, _composition.column);
    CGFloat xGap = _composition.gap.x;
    CGFloat yGap = _composition.gap.y;
    CGFloat width = (self.bounds.size.width-xL-xR-(column-1)*xGap)/column;
    CGFloat height = (self.bounds.size.height-yU-yD-(row-1)*yGap)/row;
    NSLog(@"width:%f height:%f", width, height);
    for (int j=0; j<row; j++) {
        if (tempCount <= column*j) {  // out of the loop when typesetting to the last
            break;
        }
        for (int i=0; i<column; i++) {
            NSLog(@"_imageCount:%d i+column*j:%d", tempCount, i+column*j);
            if (tempCount <= i+column*j) {  // out of the loop when typesetting to the last
                break;
            }
            ALImageView *alImageView = [_imageViews objectAtIndex:i+column*j];
            alImageView.frame = CGRectMake(xL+(xGap+width)*i, yU+(yGap+height)*j, width, height);
            alImageView.index = i+j*column;
            [self addSubview:alImageView];
        }
    }
}

- (void)setImageCount:(NSUInteger)count groupTag:(NSInteger)tag
{
    self.groupTag = tag;
    
    if (nil == _imageViews) {
        _imageViews = [[NSMutableArray alloc] init];
    }
    
    if (count <= [_imageViews count]) {
        while (count < [_imageViews count]) {
            ALImageView *alImageView = [_imageViews lastObject];
            [alImageView removeFromSuperview];
            [_imageViews removeObject:alImageView];
        }
        return;
    }
    
    while (count > [_imageViews count]) {
        ALImageView *alImageView = [[ALImageView alloc] initWithFrame:CGRectZero];
        alImageView.placeholderImage = self.groupPlaceholder;
        alImageView.contentEdgeInsets = UIEdgeInsetsMake(3.f, 4.f, 3.f, 4.f);
        alImageView.isCorner = YES;
        [alImageView addTarget:self action:@selector(didPressImageViewAction:)];
        [_imageViews addObject:alImageView];
    }
    
    [self layoutImageViews];
}

- (void)didPressImageViewAction:(id)sender
{
    ALImageView *alImageView = (ALImageView *)sender;
    NSLog(@"didPressImageViewAction:%d", alImageView.index);
    if ([_delegate respondsToSelector:@selector(containerView:didSelectIndex:)]) {
        [_delegate containerView:self didSelectIndex:alImageView.index];
    }
    if (_selectIndexBlock) {
		_selectIndexBlock(self, alImageView.index);
	}
}


@end
