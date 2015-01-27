//
//  BYTabCell.m
//  BYTabView
//
//  Created by booy on 14/7/9.
//  Copyright (c) 2014年 BYOS. All rights reserved.
//

#import "BYTabCell.h"

@implementation BYTabCell

@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _reuseIdentifier = identifier;
    }
    return self;
}

-(void)prepareForReuse
{
    self.tag = 0;
}

@end
