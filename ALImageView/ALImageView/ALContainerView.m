//
//  ALContainerView.m
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "ALContainerView.h"
#import "ALImageView.h"

UIKIT_STATIC_INLINE NSInteger RowCount(NSInteger count, NSInteger column) {
    return (count%column ? (count/column+1) : count/column);
}

@interface ALContainerView ()
{
    NSMutableArray *_imageViews;
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
    if (imageURLs == _imageURLs) {
        return;
    }
    
    if (nil != _imageURLs) {
        int i = 0;
        for (NSString *u in _imageURLs) {
            ALImageView *view = [_imageViews objectAtIndex:i];
            view.imageURL = nil;
            i++;
        }
        [_imageURLs release];
        _imageURLs = nil;
    }
    
    if (nil != imageURLs) {
        _imageURLs = [imageURLs retain];
        if (nil != _imageURLs) {
            int i = 0;
            for (NSString *u in _imageURLs) {
                if (0 < [u length]) {
                    ALImageView *view = [_imageViews objectAtIndex:i];
                    view.imageURL = u;
                }
                i++;
            }
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
    [self setIsCorner:YES];
    _groupTag = -UINT_MAX;
    _imageCount = 0;
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
    CGFloat xL = _edgeInsets.left;
    CGFloat xR = _edgeInsets.right;
    CGFloat yU = _edgeInsets.top;
    CGFloat yD = _edgeInsets.bottom;
    NSInteger column = _composition.column;
    NSInteger row = _composition.row>=RowCount(self.imageCount, _composition.column) ? _composition.row : RowCount(self.imageCount, _composition.column);
    CGFloat xGap = _composition.gap.x;
    CGFloat yGap = _composition.gap.y;
    CGFloat width = (self.bounds.size.width-xL-xR-(column-1)*xGap)/column;
    CGFloat height = (self.bounds.size.height-yU-yD-(row-1)*yGap)/row;
    NSLog(@"width:%f height:%f", width, height);
    if (nil == _imageViews) {
        _imageViews = [[NSMutableArray alloc] init];
    }
    int tempCount = [_imageViews count];
    for (int j=0; j<row; j++) {
        if (_imageCount <= column*j) {  // out of the loop when typesetting to the last
            break;
        }
        for (int i=0; i<column; i++) {
            NSLog(@"_imageCount:%d i+column*j:%d", _imageCount, i+column*j);
            if (_imageCount <= i+column*j) {  // out of the loop when typesetting to the last
                break;
            }
            ALImageView *alImageView = nil;
            if (tempCount > i+column*j) {
                alImageView = [[_imageViews objectAtIndex:i+column*j] retain];
            } else {
                alImageView = [[ALImageView alloc] initWithFrame:CGRectMake(xL+(xGap+width)*i, yU+(yGap+height)*j, width, height)];
                alImageView.placeholderImage = [UIImage imageNamed:@"img_pld"];
                alImageView.contentEdgeInsets = UIEdgeInsetsMake(3.f, 4.f, 3.f, 4.f);
                alImageView.index = i+j*column;
                alImageView.isCorner = YES;
                [alImageView addTarget:self action:@selector(didPressImageViewAction:)];
                [_imageViews addObject:alImageView];
                [self addSubview:alImageView];
            }
            [alImageView release];
        }
    }
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

- (void)setImageCount:(NSUInteger)count groupTag:(NSInteger)tag
{
    self.groupTag = tag;
    self.imageCount = count;
    
    if (_imageCount > 0) {
        [self layoutIfNeeded];
    }
    
    for (int i=0; i<[_imageViews count]; i++) {
        ALImageView *alImageView = [_imageViews objectAtIndex:i];
        if (_imageCount > i) {
            alImageView.hidden = NO;
        } else {
            alImageView.hidden = YES;
        }
    }
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
