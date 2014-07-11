//
//  BYTabCell.h
//  BYTabView
//
//  Created by booy on 14/7/9.
//  Copyright (c) 2014年 BYOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYTabCell : UIView

@property(nonatomic, readonly, copy)NSString *reuseIdentifier;

- (id) initWithReuseIdentifier:(NSString *)identifier;

- (void) prepareForReuse;


@end
