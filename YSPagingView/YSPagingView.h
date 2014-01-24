//
//  YSPagingView.h
//  DemoApp
//
//  Created by taiki on 1/23/14.
//  Copyright (c) 2014 taiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YSPagingViewDataSource;

@interface YSPagingView : UIView
@property (weak) id<YSPagingViewDataSource>dataSource;
@property (nonatomic) CGFloat pagingSpace;
@property (nonatomic) CGFloat leftInset;
@property (nonatomic) CGFloat rightInset;
@property (nonatomic) NSUInteger page;

- (void)reloadData;

@end

@protocol YSPagingViewDataSource
@required
- (NSUInteger)numberOfPagesInPagingView:(YSPagingView *)pagingView;
- (UIView *)pagingView:(YSPagingView *)pagingView pageViewOfIndex:(NSUInteger)index;
@end
