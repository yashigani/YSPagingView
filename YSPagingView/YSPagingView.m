//
//  YSPagingView.m
//  DemoApp
//
//  Created by taiki on 1/23/14.
//  Copyright (c) 2014 taiki. All rights reserved.
//

#import "YSPagingView.h"

typedef NS_ENUM (NSUInteger, YSPagingDirection) {
    YSPagingDirectionIdentity,
    YSPagingDirectionLeft,
    YSPagingDirectionRight
};

@interface YSPagingView () <UIScrollViewDelegate>
@property (nonatomic) UIScrollView *pagingScrollView;
@property (assign, nonatomic) NSUInteger numOfPages;
@property (strong, nonatomic) NSArray *pageViews;
@end

@implementation YSPagingView

- (void)dealloc
{
    [self.pagingScrollView removeObserver:self forKeyPath:@"pagingScrollView.contentOffset"];
}

- (void)prepare
{
    [self addObserver:self
           forKeyPath:@"pagingScrollView.contentOffset"
              options:NSKeyValueObservingOptionOld
              context:NULL];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)setPagingSpace:(CGFloat)pagingSpace
{
    _pagingSpace = pagingSpace;
    [self setNeedsLayout];
}

- (void)setPageViews:(NSArray *)pageViews
{
    [_pageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _pageViews = pageViews;
}

- (UIScrollView *)pagingScrollView
{
    if (!_pagingScrollView) {
        _pagingScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _pagingScrollView.delegate = self;
        _pagingScrollView.pagingEnabled = YES;
        _pagingScrollView.alwaysBounceVertical = NO;
        _pagingScrollView.clipsToBounds = NO;
        [self addSubview:_pagingScrollView];
    }
    return _pagingScrollView;
}

- (void)layoutSubviews
{
    CGRect frame = CGRectMake(-self.pagingSpace / 2.0 + self.leftInset,
                              0,
                              self.visibleWidth + self.pagingSpace,
                              CGRectGetHeight(self.bounds));
    if (!CGRectEqualToRect(frame, self.pagingScrollView.frame)) {
        BOOL needsReload = CGRectEqualToRect(CGRectZero, self.pagingScrollView.frame);
        self.pagingScrollView.frame = frame;
        self.numOfPages = [self.dataSource numberOfPagesInPagingView:self];
        self.pagingScrollView.contentSize = (CGSize){
            CGRectGetWidth(self.pagingScrollView.bounds) * 3,
            CGRectGetHeight(self.pagingScrollView.bounds)
        };
        self.pagingScrollView.contentOffset = (CGPoint){
            CGRectGetWidth(self.pagingScrollView.bounds), 0
        };
        if (needsReload) [self reloadData];
    }
}

- (void)reloadData
{
    self.page = 0;
    UIView *left = [self.dataSource pagingView:self pageViewOfIndex:self.numOfPages - 1];
    UIView *center = [self.dataSource pagingView:self pageViewOfIndex:0];
    UIView *right = [self.dataSource pagingView:self pageViewOfIndex:1];
    self.pageViews = [NSArray arrayWithObjects:left, center, right, nil];

    [self layoutPageViews];
    CGFloat width = CGRectGetWidth(self.pagingScrollView.bounds);
    CGPoint offset = self.pagingScrollView.contentOffset;
    self.pagingScrollView.contentOffset = (CGPoint){
        width, offset.y
    };
}

- (CGFloat)visibleWidth
{
    return CGRectGetWidth(self.bounds) - self.leftInset - self.rightInset;
}

- (void)layoutPageViews
{
    __weak __typeof(self) wself = self;
    [self.pageViews enumerateObjectsUsingBlock:^(UIView *v, NSUInteger index, BOOL *s) {
        v.frame = ({
            CGRect frame = v.frame;
            frame.origin.x = wself.pagingSpace / 2.0 + (wself.visibleWidth + wself.pagingSpace) * index;
            frame;
        });
        [wself.pagingScrollView addSubview:v];
    }];
    self.pagingScrollView.contentOffset = (CGPoint){
        CGRectGetWidth(self.pagingScrollView.bounds), self.pagingScrollView.contentOffset.y
    };
}

- (void)loadPreviousPageViews
{
    if (!self.pageViews) return;
    self.page = (0 < self.page) ? self.page - 1 : self.numOfPages - 1;
    NSInteger next = (0 < self.page) ? self.page - 1 : self.numOfPages - 1;
    self.pageViews = @[
        [self.dataSource pagingView:self pageViewOfIndex:next],
        self.pageViews[0],
        self.pageViews[1],
    ];
    [self layoutPageViews];
}

- (void)loadNextPageViews
{
    if (!self.pageViews) return;
    self.page = (self.page < self.numOfPages - 1) ? self.page + 1 : 0;
    NSInteger next = (self.page < self.numOfPages - 1) ? self.page + 1 : 0;
    self.pageViews = @[
        self.pageViews[1],
        self.pageViews[2],
        [self.dataSource pagingView:self pageViewOfIndex:next],
    ];
    [self layoutPageViews];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGPoint offset = self.pagingScrollView.contentOffset;
    CGFloat space = self.pagingSpace / 2.0;
    if (offset.x < space + self.leftInset) {
        [self loadPreviousPageViews];
    }
    else if (self.visibleWidth * 2 + space * 3 < offset.x) {
        [self loadNextPageViews];
    }
}

@end
