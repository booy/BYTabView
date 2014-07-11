//
//  BYTabView.m
//  BYTabView
//
//  Created by booy on 14/7/9.
//  Copyright (c) 2014年 BYOS. All rights reserved.
//

#import "BYTabView.h"
#import "BYTabCell.h"

@interface BYTabView()
{
    UIScrollView *_contentView;
    
    UIView *_titleView;
    
    NSMutableSet *_reusableContentCells;
    
    BOOL _isTitleViewOrientationHorizontal;
    
    NSTimer *_timer;
}

- (void)initialization;

- (void)reframe;

- (void)loadRequredContentCells;

- (void)loadTitleCells;

- (void)loadContentCellAtIndex:(NSInteger)index;

- (NSArray *)contentCells;

- (void)cleanupUnseenContentCells;

- (void)updateIndex;

- (void)queueReusableCell:(BYTabCell *)cell;

- (void)didTapContentView:(UITapGestureRecognizer *)tapGesture;

- (void)didTapTitleView:(UITapGestureRecognizer *)tapGesture;

- (void)autoPlay;

@end

@implementation BYTabView

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize currentIndex = _currentIndex;
@synthesize tabs = _tabs;
@synthesize needRespondTapGesture = _needRespondTapGesture;
@synthesize playInterval = _playInterval;
@synthesize edgeInsets = _edgeInsets;
@synthesize titleFrame = _titleFrame;
@synthesize titleCellSize = _titleCellSize;
@synthesize titleInteractionEnabled = _titleInteractionEnabled;

- (void)initialization
{
    _currentIndex = 0;
    _tabs = 0;
    _titleCellSize = CGSizeMake(10, 10);
    _playInterval = 0;
    _reusableContentCells = [[NSMutableSet alloc] init];
    _needRespondTapGesture = YES;
    _titleInteractionEnabled = YES;
    _isTitleViewOrientationHorizontal = YES;
}

- (id)initWithFrame:(CGRect)frame titleViewFrame:(CGRect)titleFrame edgeInsets:(UIEdgeInsets)edgeInsets
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
        
        _contentView = [[UIScrollView alloc] init];
        _contentView.delegate = self;
        _contentView.pagingEnabled = YES;
        _contentView.scrollEnabled = YES;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_contentView];
        
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleView];
        
        self.titleFrame = titleFrame;
        self.edgeInsets = edgeInsets;
        
        [self reframe];
    }
    return self;
}

- (void)reframe
{
    _titleView.frame = _titleFrame;
    
    CGRect contentFrame = self.bounds;
    
    if (!UIEdgeInsetsEqualToEdgeInsets(_edgeInsets, UIEdgeInsetsZero))
    {
        CGFloat top = _edgeInsets.top;
        CGFloat left = _edgeInsets.left;
        CGFloat bottom = _edgeInsets.bottom;
        CGFloat right = _edgeInsets.right;
        
        if (top > 0) {
            contentFrame.origin.y += top;
            contentFrame.size.height -= top;
            _isTitleViewOrientationHorizontal = YES;
            _contentView.frame = contentFrame;
            return;
        }
        
        if (left > 0) {
            contentFrame.origin.x += left;
            contentFrame.size.width -= left;
            _isTitleViewOrientationHorizontal = NO;
            _contentView.frame = contentFrame;
            return;
        }
        
        if (bottom > 0) {
            contentFrame.size.height -= bottom;
            _isTitleViewOrientationHorizontal = YES;
            _contentView.frame = contentFrame;
            return;
        }
        
        if (right > 0) {
            contentFrame.size.width -= right;
            _isTitleViewOrientationHorizontal = NO;
            _contentView.frame = contentFrame;
            return;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self loadRequredContentCells];
    [self loadTitleCells];
}

#pragma mark - Setter

- (void)setTitleFrame:(CGRect)titleFrame
{
    if (!CGRectEqualToRect(titleFrame, _titleFrame))
    {
        _titleFrame = titleFrame;
        [self reframe];
    }
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(edgeInsets, _edgeInsets))
    {
        _edgeInsets = edgeInsets;
        [self reframe];
    }
}

- (void)setDataSource:(id<BYTabViewDataSource>)dataSource
{
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
}

-(void)setNeedRespondTapGesture:(BOOL)needRespondTapGesture
{
    if (_needRespondTapGesture != needRespondTapGesture) {
        _needRespondTapGesture = needRespondTapGesture;
    }
    
    if (needRespondTapGesture) {
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContentView:)];
        [_contentView addGestureRecognizer:singleTapGesture];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (_currentIndex == currentIndex) {
        return;
    }
    _currentIndex = currentIndex;
    
    if ([_delegate respondsToSelector:@selector(tabView:afterSelectedTabAtIndex:)]) {
        [_delegate tabView:self afterSelectedTabAtIndex:_currentIndex];
    }
    
    [self reloadData];
}

- (void)setPlayInterval:(NSInteger)playInterval
{
    if (_playInterval == playInterval) {
        return;
    }
    
    _playInterval = playInterval;
    
    if (_playInterval == 0) {
        return;
    }
    
    _timer = [[NSTimer alloc] initWithFireDate:[[NSDate new] dateByAddingTimeInterval:_playInterval] interval:_playInterval target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:_timer forMode:NSDefaultRunLoopMode];
}
#pragma mark - Upadte Views

- (void)reloadData
{
    _tabs = [_dataSource numberOfTabsInTabView:self];
    
    for (UIView *subView in [_contentView subviews]) {
        if ([subView isKindOfClass:[BYTabCell class]]) {
            [subView removeFromSuperview];
            [self queueReusableCell:(BYTabCell *)subView];
        }
    }
    CGFloat width = _contentView.frame.size.width;
    CGFloat height = _contentView.frame.size.height;
    CGPoint offset = CGPointMake(width * _currentIndex, 0);
    
    _contentView.contentSize = CGSizeMake(width  * _tabs, height);
    [_contentView setContentOffset:offset animated:YES];
    
    [self setNeedsLayout];
}

- (void)queueReusableCell:(BYTabCell *)cell
{
    if (cell)
    {
        [cell prepareForReuse];
        [_reusableContentCells addObject:cell];
    }
}

- (void)loadTitleCells
{
    [_titleView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
    
    float gap;
    if ([_dataSource respondsToSelector:@selector(gapOfTitleCellsInTabView:)]) {
        gap = [_dataSource gapOfTitleCellsInTabView:self];
    }else{
        gap = 10.f;
    }
    
    float totalWidth = _titleView.frame.size.width;
    float totalHeight = _titleView.frame.size.height;
    
    // if only one tab, hide the title view
    if ( _tabs < 2) {
        return;
    }
    
    for (int i = 0; i <= _tabs - 1; i++ ) {
        BYTabCell *titleCell = [self titleCellOfTab:i];
        float offsetX, offsetY;
        
        if (_isTitleViewOrientationHorizontal) {
            offsetX = totalWidth / 2 - (_tabs * _titleCellSize.width + (_tabs - 1) * gap) / 2 +  i * ( _titleCellSize.width + gap );
            offsetY = ( totalHeight - _titleCellSize.height) / 2;
        }else{
            offsetY = totalHeight / 2 - (_tabs * _titleCellSize.height + (_tabs - 1) * gap) / 2 +  i * ( _titleCellSize.height + gap );
            offsetX = ( totalWidth - _titleCellSize.width) / 2;
        }
        
        titleCell.frame = CGRectMake(offsetX, offsetY, _titleCellSize.width, _titleCellSize.height);
        [_titleView addSubview:titleCell];
    }
}

- (void)loadRequredContentCells
{
    NSInteger prev = MAX(0, _currentIndex - 1);
    NSInteger next = MIN(_currentIndex + 1, _tabs - 1);
    
    [self loadContentCellAtIndex:_currentIndex];
    
    if (prev != _currentIndex) {
        [self loadContentCellAtIndex:prev];
    }
    
    if (next != _currentIndex) {
        [self loadContentCellAtIndex:next];
    }
    [self cleanupUnseenContentCells];
}

- (void)loadContentCellAtIndex:(NSInteger)index
{
    BYTabCell *contentCell = [_dataSource tabView:self contentCellForIndex:index];
    if (contentCell != nil) {
        CGFloat width = _contentView.frame.size.width;
        CGFloat height = _contentView.frame.size.height;
        
        contentCell.tag = index + 1;
        contentCell.frame = CGRectMake(index * width, 0, width, height);
        [_contentView addSubview:contentCell];
    }
}

- (BYTabCell *)titleCellOfTab:(NSInteger)index;
{
    BYTabCell *cell;
    
    if ([_dataSource respondsToSelector:@selector(tabView:titleCellForIndex:)]) {
        cell = [_dataSource tabView:self titleCellForIndex:index];
    }
    
    if (!cell) {
        cell = [[BYTabCell alloc] initWithReuseIdentifier:@"BYTabTitleCellIdentifier"];
        if (_currentIndex == index) {
            cell.backgroundColor = [UIColor redColor];
        }else{
            cell.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    if (_titleInteractionEnabled) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTitleView:)];
        [cell addGestureRecognizer:tapGesture];
    }
   
    return cell;
}

- (BYTabCell *)contentCellOfTab:(NSInteger)index
{
    BYTabCell *cell = nil;
    for (BYTabCell *cell_ in [self contentCells])
    {
        if (cell_.tag == index + 1)
        {
            cell = cell_;
            break;
        }
    }
    
    return cell;
}

- (NSArray *)contentCells
{
    NSMutableArray *cells = [@[] mutableCopy];
    for (UIView *cell in [_contentView subviews]) {
        if ([cell isKindOfClass:[BYTabCell class]]) {
            [cells addObject:cell];
        }
    }
    
    return cells;
}

- (void)cleanupUnseenContentCells
{
    BYTabCell *cell;
    
    NSInteger prev = MAX(0, _currentIndex - 2);
    NSInteger next = MIN(_currentIndex + 2, _tabs);
    
    if (prev > 0) {
        for (int i = 0; i <= prev; i++) {
            cell = [self contentCellOfTab:i];
            if (cell) {
                [self queueReusableCell:cell];
                [cell removeFromSuperview];
            }
        }
    }
    
    if (next <= _tabs - 1) {
        for (int i = next; i <= _tabs - 1; i++) {
            cell = [self contentCellOfTab:i];
            if (cell) {
                [self queueReusableCell:cell];
                [cell removeFromSuperview];
            }
        }
    }
}

- (BYTabCell *)dequeueReusableContentCellWithIdentifier:(NSString *)identifier
{
    BYTabCell *cell = nil;
    for (BYTabCell *reusableCell in [_reusableContentCells allObjects])
    {
        if ([reusableCell.reuseIdentifier isEqualToString:identifier])
        {
            cell = reusableCell;
            break;
        }
    }
    
    if (cell)
    {
        [_reusableContentCells removeObject:cell];
    }
    return cell;
}

#pragma mark - Actions

- (void)didTapTitleView:(UITapGestureRecognizer *)tapGesture
{
    self.currentIndex = [_titleView.subviews indexOfObject:tapGesture.view];
}

- (void)didTapContentView:(UITapGestureRecognizer *)tapGesture
{
    if ([_delegate respondsToSelector:@selector(tabView:didSelectTabAtIndex:)]) {
        [_delegate tabView:self didSelectTabAtIndex:_currentIndex];
    }
}

#pragma mark - UIScrollView Delegate && Gesture


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateIndex];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateIndex];
    }
}

- (void)updateIndex
{
    float index = ceilf(_contentView.contentOffset.x / _contentView.frame.size.width);
    
    if (index < 0) {
        index = 0;
    }
    if (index > _tabs - 1) {
        index = _tabs - 1;
    }
    
    self.currentIndex = index;
}

#pragma mark - Timer Action

- (void)autoPlay
{
    NSInteger next = _currentIndex + 1;
    if (next == _tabs) {
        next = 0;
    }
    self.currentIndex = next;
}

@end
