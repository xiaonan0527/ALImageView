//
//  ALContainerView.h
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALContainerViewColumnCount     2
#define ALContainerViewRowCount     2

@class ALContainerView;
typedef void (^CSelectIndexBlock)(ALContainerView *cView, NSInteger index);

@protocol ALContainerViewDelegate <NSObject>

@optional
- (void)containerView:(ALContainerView *)cView didSelectIndex:(NSInteger)index;

@end

@interface ALContainerView : UIView

@property (nonatomic, readwrite) NSInteger fromIndex;
@property (nonatomic, readwrite) NSUInteger imageCount;
@property (nonatomic, retain) NSString *imageCacheDirectory;
@property (nonatomic, retain) NSArray *localPaths;
@property (nonatomic, retain) NSArray *remotePaths;
@property (nonatomic, assign) id<NSObject, ALContainerViewDelegate> delegate;


- (void)setImageCount:(NSUInteger)count fromIndex:(NSInteger)index;
- (void)setSelectIndexBlock:(CSelectIndexBlock)block;

@end
