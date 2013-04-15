//
//  MPOutlineView.m
//  HomeScreen
//
//  Created by Mahadevaprabhu K S on 07/02/13.
//  Copyright (c) 2013 Mahadevaprabhu K S. All rights reserved.
//

#define LEVEL_PADDING 

#import "MPOutlineView.h"

//*********************************************************************************************************//
@interface MPExpandableCell : UITableViewCell

@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation MPExpandableCell

 -(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _arrowView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow"]];
        [self.contentView addSubview:_arrowView];
    }
    return  self;
}

@end

//*********************************************************************************************************//

@interface Item : NSObject

@property (nonatomic, weak) Item *parent;
@property (nonatomic, weak) NSObject *item;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, getter = isExpandable) BOOL expandable;
@property (nonatomic, getter = isOpen) BOOL open;
@property (nonatomic) NSUInteger level;

- (NSString *)pathFromRoot;
@end
@implementation Item

- (void)setChildren:(NSMutableArray *)children
{
    for (Item *child in children)
    {
        child.parent = self;
    }
    _children = children;
}

- (NSString *)pathFromRoot
{
    NSString *path = @"";
    if (self.parent)
    {
        path = [self.parent.pathFromRoot stringByAppendingFormat:@"/%@ ",self.parent.title];
        path = [path stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@" / "];
    return path;
}
@end

//*********************************************************************************************************//

@interface MPOutlineView ()
{
    NSMutableArray *currentItems;
    NSMutableString *indentString;
    NSUInteger itemLevel;
    NSArray *itemToOpenOrClose;
}

@property (nonatomic, strong) UILabel *headerViewLabel;
@end

@implementation MPOutlineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dataSource = self;
        self.delegate = self;
        indentString = [NSMutableString stringWithString:@"    "];
        itemLevel ++;
        
        _headerViewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), 10)];
        _headerViewLabel.hidden = YES;
        [self addSubview:_headerViewLabel];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinched:)];
        [self addGestureRecognizer:pinch];
    }
    
    return self;
}

- (void)reload
{
     Item *root = [[Item alloc]init];
     root.children = [self fillChildrenForItem:nil];
     currentItems = [root.children mutableCopy];
}

- (NSMutableArray *)fillChildrenForItem:(NSObject *)item
{
    NSMutableArray *children = [NSMutableArray array];
    
    NSInteger numberOfChildren = [self.outlineViewDataSource outlineView:self numberOfChildrenForItem:item];
    
    for (NSInteger i = 0; i <= numberOfChildren; i++)
    {
        Item *child = [[Item alloc]init];
        child.item = [self.outlineViewDataSource outlineView:self itemForIndex:i inRoot:item];
        child.expandable = [self.outlineViewDataSource outlineView:self isThisExtendebleItem:child.item];
        child.title = [self.outlineViewDataSource outlineView:self titleForItem:child.item];
        
        // For Indentation Temparary
        child.title = [NSString stringWithFormat:@"%@%@",indentString, child.title];
        child.level = itemLevel;
        
        if (child.expandable)
        {
            [indentString appendString:@"    "];
            itemLevel ++;
            child.children = [self fillChildrenForItem:child.item];
        }
        
        [children addObject:child];
    }

    [indentString replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
    itemLevel --;

    return children;
}


#pragma UITableViewDeleagete

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return [currentItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    MPExpandableCell* cell = (MPExpandableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[MPExpandableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Item *item = [currentItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.arrowView.hidden = !item.expandable;
    cell.arrowView.frame = CGRectMake(22.f * (item.level - 1 ), 10.f, 25.f, 25.f);
    cell.arrowView.transform = CGAffineTransformMakeRotation( item.isOpen ? 90 * M_PI/180 : 0) ;
    //NSLog(@"\nITEM : %@ \nOPEN: %@ \n LEVAL: %d",item.title,item.isOpen? @"YES": @"NO",item.level);
    
    float r = (255 - ((item.level % 40) * 10))/255.0;
    cell.contentView.backgroundColor = [UIColor colorWithRed:r green:r blue:r alpha:1];
    self.backgroundColor = [UIColor colorWithRed:r green:r blue:r alpha:1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *ocItem = [currentItems objectAtIndex:indexPath.row];
    
    if (!ocItem.isExpandable)
    {
        if ([(NSObject *)self.outlineViewDelegate respondsToSelector:@selector(outlineView: didSelectAtItem:)])
        {
            [self.outlineViewDelegate outlineView:self didSelectAtItem:ocItem];
        }
    }
    else if (!ocItem.isOpen)
    {
        [self openItem:ocItem inIndexPath:indexPath];
    }
    else
    {
        [self closeItem:ocItem inIndexPath:indexPath];
    }
}

- (void)openItem:(Item *)item inIndexPath:(NSIndexPath *)indexPath
{
    // Add child items to Array
    if (!item.isOpen && item.children.count)
    {
        item.open = !item.isOpen;
        
        [self rotateImageViewForState:item.isOpen inIndexPathOfCell:indexPath];

        NSMutableArray *changingIndexes = [NSMutableArray array];
        
        for (NSUInteger inx = 0; inx < item.children.count; inx++)
        {
            [currentItems insertObject:[item.children objectAtIndex:inx] atIndex:(indexPath.row + inx + 1)];
            [changingIndexes addObject:[NSIndexPath indexPathForRow:(indexPath.row + inx + 1) inSection:0]];
        }
        
        [self beginUpdates];
        [self insertRowsAtIndexPaths:changingIndexes withRowAnimation:UITableViewRowAnimationFade];
        [self endUpdates];
    }

}

- (void)closeItem:(Item *)item inIndexPath:(NSIndexPath *)indexPath
{
    if (item.isOpen)
    {
        item.open = !item.isOpen;
        
        [self rotateImageViewForState:item.isOpen inIndexPathOfCell:indexPath];
        
        NSMutableArray *indexsToRemove = [self indexPathsForOpenedChildrenInItem:item withIndexPath:indexPath];
                
        NSIndexPath *firstIndex = [indexsToRemove objectAtIndex:0];
        
        NSIndexSet *indexSetToRemove = [NSIndexSet indexSetWithIndexesInRange:
                                        NSMakeRange(firstIndex.row,indexsToRemove.count)];
        [currentItems removeObjectsAtIndexes:indexSetToRemove];
        
        [self beginUpdates];
        [self deleteRowsAtIndexPaths:indexsToRemove withRowAnimation:UITableViewRowAnimationAutomatic];
        [self endUpdates];

    }
}


- (NSMutableArray *)indexPathsForOpenedChildrenInItem:(Item *)item withIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *openedIndexes = [NSMutableArray array];
    
    int count = indexPath.row + 1;
    
    for (Item *child  in item.children)
    {
        NSIndexPath *childIndexPath = [NSIndexPath indexPathForRow:count inSection:indexPath.section];
        
        [openedIndexes addObject:childIndexPath];
        
        if (child.isOpen)
        {
            [openedIndexes addObjectsFromArray:[self indexPathsForOpenedChildrenInItem:child withIndexPath:childIndexPath]];
            child.open = NO;
        }
        
        NSIndexPath *currentIndex = [openedIndexes lastObject];
        count = currentIndex.row + 1;
    }

    return openedIndexes;
}

// UTILITY METHODS

float firstY,secondY, currentUpperY, previousY ;

- (void)pinched:(UIPinchGestureRecognizer *)pinch
{
    static BOOL pinchStarted = NO;
    
    if (pinch.numberOfTouches > 1)
    {
        CGPoint firstPoint = [pinch locationOfTouch:0 inView:self];
        CGPoint secPoint = [pinch locationOfTouch:1 inView:self];
        currentUpperY = MIN(firstPoint.y, secPoint.y);
        if (previousY == 0) previousY = currentUpperY;
        Float32 y = (self.contentOffset.y + previousY - currentUpperY);
        [self setContentOffset:CGPointMake(0, y < 0 ? 0 : y) animated:NO];
        
        if (pinch.state == UIGestureRecognizerStateBegan)
        {
            pinchStarted = YES;
            firstY = MIN(firstPoint.y, secPoint.y);
            secondY = MAX(firstPoint.y, secPoint.y);
            NSArray *pinchedIndexs = [self indexPathsForRowsInRect:CGRectMake(0.0, firstY, CGRectGetWidth(self.bounds), secondY)];
            if (pinchedIndexs.count) itemToOpenOrClose = [[currentItems subarrayWithRange:NSMakeRange(((NSIndexPath *)[pinchedIndexs objectAtIndex:0]).row, pinchedIndexs.count - 1)] copy];
        }
    }
    
    if ((pinch.state == UIGestureRecognizerStateChanged && pinchStarted && itemToOpenOrClose.count)
        || pinch.state == UIGestureRecognizerStateEnded)
    {
        if (pinch.scale > 1) // Pinch OUT
        {
            for (Item *item in itemToOpenOrClose)
            {                
                [self openItem:item inIndexPath:[NSIndexPath indexPathForRow:[currentItems indexOfObject:item] inSection:0]];
            }
        }
        else if (pinch.scale < 1) // Pinch IN
        {
            for (Item *item in itemToOpenOrClose)
            {
                [self closeItem:item inIndexPath:[NSIndexPath indexPathForRow:[currentItems indexOfObject:item] inSection:0]];
            }
        }
        
        if (pinch.state == UIGestureRecognizerStateEnded)
        {
            pinchStarted = NO;
            itemToOpenOrClose = nil;
            previousY = 0;
        }
    }
}

- (void)rotateImageViewForState:(BOOL)open inIndexPathOfCell:(NSIndexPath *)indexPath
{
    MPExpandableCell* cell = (MPExpandableCell *)[self cellForRowAtIndexPath:indexPath];

    [UIView animateWithDuration:0.25 animations:^{
        
        cell.arrowView.transform = CGAffineTransformMakeRotation(open? 90 * M_PI/180 : 0);
    }];
}

#pragma Header Path Maintain

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.contentOffset.y > 1)
    {
        _headerViewLabel.hidden = NO;
        _headerViewLabel.frame = CGRectMake(0.f, self.contentOffset.y, CGRectGetWidth(self.bounds), 40);
        Item *item = currentItems.count > 2 ? [currentItems objectAtIndex:((NSIndexPath *)[[self indexPathsForVisibleRows] objectAtIndex:2]).row] : nil;
        _headerViewLabel.text = item ? item.pathFromRoot : @"";
    }
    else
    {
        _headerViewLabel.hidden = YES;
    }

}

@end
