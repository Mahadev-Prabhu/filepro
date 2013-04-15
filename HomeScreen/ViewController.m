//
//  ViewController.m
//  HomeScreen
//
//  Created by Mahadevaprabhu K S on 05/02/13.
//  Copyright (c) 2013 Mahadevaprabhu K S. All rights reserved.
//

#import "ViewController.h"

@interface Node : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *children;

@end
@implementation Node
@end

@interface ViewController ()

{
    NSUInteger count;
    
}
@property (nonatomic, strong) NSMutableDictionary *info;
@property (nonatomic, strong) NSMutableDictionary *nInfo;
@property (nonatomic, strong) Node *node;
@end

@implementation ViewController



- (void)viewDidLoad
{
    count = 0;
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CountryAndCitiesDatabase" ofType:@"plist"];
    NSDictionary *coun = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    self.info = [coun mutableCopy];
    self.nInfo = [NSMutableDictionary dictionary];
    _node = [[Node alloc]init];
    _node.name = @"ROOT";
    NSMutableArray *array = [self childrensForRootNode];
    _node.children = [NSMutableArray array];
    
    Node *node1 = [[Node alloc]init];
    node1.name = @"ROOT 1";
    node1.children = array;
    [_node.children addObject:node1];
    
    Node *node2 = [[Node alloc]init];
    node2.name = @"ROOT 2";
    node2.children = array;
    [_node.children addObject:node2];

    
    MPOutlineView *outlineView = [[MPOutlineView alloc]initWithFrame:[self.view bounds]];
    outlineView.outlineViewDataSource = self;
    [outlineView reload];
    [self.view addSubview:outlineView];
    
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma MPOutlineViewDataSource


- (NSUInteger)outlineView:(MPOutlineView *)outlineView numberOfChildrenForItem:(NSObject *)item
{
        
    if (!item)
    {
        return _node.children.count - 1;
    }
    else if ([item isKindOfClass:[Node class]])
    {
        return [(Node *)item children].count - 1;
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        return 0;
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        return 0;
    }
    
     return 0;
}

- (NSObject *)outlineView:(MPOutlineView *)outlineView itemForIndex:(NSInteger)index inRoot:(NSObject *)root
{
    if (!root)
    {
        return [_node.children objectAtIndex:index];
    }
    else if ([root isKindOfClass:[Node class]])
    {
        return [[(Node *)root children] objectAtIndex:index];
    }
    else if ([root isKindOfClass:[NSString class]])
    {
        return nil;
    }

    return nil;
}

- (BOOL)outlineView:(MPOutlineView *)outlineView isThisExtendebleItem:(NSObject *)item
{

    if (!item)
    {
        return YES;
    }
    else if ([item isKindOfClass:[Node class]])
    {
        return [[(Node *)item children] count];
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        return NO;
    }
    
    return NO;
}

- (NSString *)outlineView:(MPOutlineView *)outlineView titleForItem:(NSObject *)item
{
    if ([item isKindOfClass:[Node class]])
    {
        return [(Node *)item name];
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        return (NSString *)item;
    }
    
    return Nil;
}


- (NSMutableArray *)childrensForRootNode
{
    
    NSMutableArray *rootChildrens = [NSMutableArray array];
    //int noOfcountries = [[_info allKeys] count];
    
    NSArray *continents = @[@"Asia",@"North America",@"South America",@"Africa",@"Europe",@"Australia"];
    
    int start = 0;
    int end = 3;
    for (NSString *cont in continents)
    {
    
        NSArray *keys = [[_info allKeys] subarrayWithRange:NSMakeRange(start, end)];
        Node *firstNode = [[Node alloc]init];
        firstNode.name = cont;
        firstNode.children = [NSMutableArray array];

                for (NSString *str1 in keys)
                {
                        NSArray *states = [_info objectForKey:str1];
                        states =  [states subarrayWithRange:NSMakeRange(0, states.count > 3 ? 3 : 1)];
                    
                        Node *secNode = [[Node alloc]init];
                        secNode.name = str1;
                        secNode.children = [NSMutableArray array];
                                            
                                for (NSString *str in states)
                                {
                                    Node *thirdNode = [[Node alloc]init];
                                    thirdNode.name = str;
                                    thirdNode.children = [states mutableCopy];
                                    [secNode.children  addObject:thirdNode];
                                }
                    
                        [firstNode.children  addObject:secNode];
                }
        
        [rootChildrens addObject:firstNode];
        start = start + end;
    }
    return rootChildrens;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
