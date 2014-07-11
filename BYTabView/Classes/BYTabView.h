//
//  BYTabView.h
//  BYTabView
//
//  Created by booy on 14/7/9.
//  Copyright (c) 2014年 BYOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYTabCell.h"

@protocol BYTabViewDelegate;

@protocol BYTabViewDataSource;

@interface BYTabView : UIView<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign, readonly) NSInteger tabs;

@property (nonatomic, assign) id<BYTabViewDataSource> dataSource;

@property (nonatomic, assign) id<BYTabViewDelegate> delegate;

@property (nonatomic) CGRect titleFrame;

@property (nonatomic, readwrite) UIEdgeInsets edgeInsets;

/*
                --- Optional Setting ---
*/

// Default YES
@property (nonatomic) BOOL needRespondTapGesture;

// Default YES
@property (nonatomic) BOOL titleInteractionEnabled;

// Default 0
@property (nonatomic) NSInteger playInterval;

// Default {10, 10}
@property (nonatomic) CGSize titleCellSize;


- (id)initWithFrame:(CGRect)frame titleViewFrame:(CGRect)titleFrame edgeInsets:(UIEdgeInsets)edgeInsets;

- (BYTabCell *)dequeueReusableContentCellWithIdentifier:(NSString *)identifier;

- (BYTabCell *)contentCellOfTab:(NSInteger)index;

- (BYTabCell *)titleCellOfTab:(NSInteger)index;

- (void)reloadData;

@end

/*
 * This protocol
 */

@protocol BYTabViewDelegate <NSObject>

@optional

// Handle Select Event
- (void)tabView:(BYTabView *)tabView didSelectTabAtIndex:(NSInteger)index;

// After Select
- (void)tabView:(BYTabView *)tabView afterSelectedTabAtIndex:(NSInteger)index;

@end


@protocol BYTabViewDataSource <NSObject>

@required

- (NSInteger)numberOfTabsInTabView:(BYTabView *)tabView;

- (BYTabCell *)tabView:(BYTabView *)tabView contentCellForIndex:(NSInteger)index;

@optional

- (BYTabCell *)tabView:(BYTabView *)tabView titleCellForIndex:(NSInteger)index;

- (float)gapOfTitleCellsInTabView:(BYTabView *)tabView;

@end
