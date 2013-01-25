//
//  GraphView.m
//  GraphSample
//
//  Created by Mahadevaprabhu K S on 18/01/13.
//  Copyright (c) 2013 Mahadevaprabhu K S. All rights reserved.
//

#import "GraphView.h"
#import <QuartzCore/CALayer.h>

@interface GraphView ()
{
    NSArray *graphValues;
}
@end

@implementation GraphView

- (id)initWithGraphValues:(NSArray *)values
{
    self = [super initWithFrame:CGRectMake(10.0, 10.0, 300.0, 150.0)];
    if (self)
    {
        if (values)
        {
            graphValues = values;
        }
        else
        {
            graphValues = [NSArray arrayWithObjects:@"23",@"89",@"44",@"16",@"83",@"99",Nil];

        }
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
     CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextBeginPath(context);
    
    CGFloat paddingX = self.frame.size.width / ( graphValues.count + 2 );
    CGFloat paddingY = self.frame.size.height - 10;
    CGFloat nextX = paddingX;
    CGFloat nextY = paddingY;

    for (NSString *pointString in graphValues)
    {
        CGFloat startY = paddingY - [pointString floatValue];
        CGFloat startX = nextX + paddingX;
        
        
        CGContextAddEllipseInRect(context, CGRectMake(startX, startY - 5, 9, 9));
        CGContextSetFillColor(context, CGColorGetComponents([[UIColor blueColor] CGColor]));
        CGContextFillPath(context);
        CGContextStrokePath(context);

        CGContextSetLineWidth(context, 3);
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, nextX, nextY);
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        CGContextStrokePath(context);

        nextX = startX;
        nextY = startY;
        // [...] and so on, for all line segments
        CGContextSetLineWidth(context, 3);

    }
     CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
     CGContextStrokePath(context);

}
@end
