//
//  JONListViewController.m
//  JONListViewController Example
//
//  Created by Jonathan Hull on 11/24/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "JONListViewController.h"

/*
 JONListItem - This represents a single item in the list. It can be used to provide special behavior when the item is selected (vs allowing the section to handle it) or just to provide an icon for the item. If the block is nil, then the sectionBlock will handle selection.
 */
@implementation JONListItem
@synthesize title,image,selectionBlock;

-(id)initWithTitle:(NSString*)aTitle image:(UIImage*)anImage block:(JONListItemBlock)aSelectionBlock
{
    if(self=[super init]){
        title = [aTitle copy];
        image = [anImage retain];
        if(aSelectionBlock){
            selectionBlock = Block_copy(aSelectionBlock);
        }
    }
    return self;
}

-(id)initWithTitle:(NSString *)aTitle image:(UIImage*)anImage
{
    return [self initWithTitle:aTitle image:anImage block:nil];
}

- (void)dealloc {
    [title release];
    [image release];
    if(selectionBlock){
        Block_release(selectionBlock);
        selectionBlock = nil;
    }
    [super dealloc];
}

@end




/*
 JONListSection - This represents a section in the list.
 */
@implementation JONListSection
@synthesize title,items,selectionBlock,cellBlock;

-(id)initWithTitle:(NSString*)aTitle list:(NSArray*)itemList block:(JONListSectionBlock)aBlock
{
    if(self=[super init]){
        title = [aTitle copy];
        items = [itemList retain];
        if(aBlock){
            selectionBlock = Block_copy(aBlock);
        }
    }
    return self;
}

-(id)initWithList:(NSArray*)itemList block:(JONListSectionBlock)aBlock
{
    return [self initWithTitle:nil list:itemList block:aBlock];
}

- (void)dealloc {
    [title release];
    [items release];
    if(selectionBlock){
        Block_release(selectionBlock);
        selectionBlock = nil;
    }
    if(cellBlock){
        Block_release(cellBlock);
        cellBlock = nil;
    }
    [titlePaths release];
    [imagePaths release];
    [super dealloc];
}

#pragma mark -

-(NSUInteger)count
{
    return [items count];
}

-(NSString*)titleForItem:(id)item
{
    if([item isKindOfClass:[NSString class]]){
        return item;
    }else if([item isKindOfClass:[JONListItem class]]){
        return [(JONListItem*)item title];
    }else if([item isKindOfClass:[NSNumber class]]){
        return [(NSNumber*)item stringValue];
    }else{
        NSString *titlePath = [self titlePathForClass:[item class]];
        if(titlePath){
            id value = [item valueForKeyPath:titlePath];
            if([value isKindOfClass:[NSString class]]){
                return (NSString*)value;
            }
        }
    }
    return nil;
}

-(NSString*)titleForItemAtIndex:(NSUInteger)index
{
    if(index < [self.items count]){
        id item = [self.items objectAtIndex:index];
        return [self titleForItem:item];
    }
    return nil;
}

-(UIImage*)imageForItem:(id)item
{
    if([item isKindOfClass:[JONListItem class]]){
        return [(JONListItem*)item image];
    }
    NSString *imagePath = [self imagePathForClass:[item class]];
    if(imagePath){
        id value = [item valueForKeyPath:imagePath];
        if([value isKindOfClass:[UIImage class]]){
            return (UIImage*)value;
        }
    }
    return nil;
}

-(UIImage*)imageForItemAtIndex:(NSUInteger)index
{
    if(index < [self.items count]){
        id item = [self.items objectAtIndex:index];
        return [self imageForItem:item];
    }
    return nil;
}


-(NSInteger)indexForItemWithTitle:(NSString*)aTitle
{
    NSInteger index = 0;
    for(id item in items){
        if([aTitle isEqualToString:[self titleForItem:item]]){
            return index;
        }
        index++;
    }
    return NSNotFound;
}


-(void)setTitlePath:(NSString*)aPath forClass:(Class)aClass//  Name:(NSString*)aClass
{
    
    if(titlePaths == nil){
        titlePaths = [[NSMutableDictionary alloc]init];
    }
    if(aClass != nil && aPath != nil){
        [titlePaths setValue:aPath forKey:NSStringFromClass(aClass)];
    }
}


-(NSString*)titlePathForClass:(Class)aClass//Name:(NSString*)aClass
{
    return [titlePaths valueForKey:NSStringFromClass(aClass)];
}

-(void)setImagePath:(NSString*)aPath forClass:(Class)aClass
{
    if(imagePaths == nil){
        imagePaths = [[NSMutableDictionary alloc]init];
    }
    if(aClass != nil && aPath != nil){
        [imagePaths setValue:aPath forKey:NSStringFromClass(aClass)];
    }
}

-(NSString*)imagePathForClass:(Class)aClass
{
    return [imagePaths valueForKey:NSStringFromClass(aClass)];
}

@end






/*
 JONListViewController
 */
@implementation JONListViewController
@synthesize title,startingSelection,cellBlock;

#pragma mark -
#pragma mark Initialization

- (void)dealloc {
    [title release];
    [sections release];
    [startingSelection release];
    if(cellBlock){
        Block_release(cellBlock);
        cellBlock = nil;
    }
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        sections = [[NSMutableArray alloc]init];
    }
    return self;
}

-(id)initWithList:(NSArray*)listItems selection:(NSInteger)selection block:(JONListSectionBlock)aBlock{
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        JONListSection *newSection = [[JONListSection alloc]initWithList:listItems block:aBlock];
        sections = [[NSMutableArray alloc]initWithObjects:newSection,nil];
        if(selection >= 0){
            startingSelection = [[NSIndexPath indexPathForRow:selection inSection:0]retain];
        }
        [newSection release];
    }
    return self;
}

-(id)initWithList:(NSArray*)listItems block:(JONListSectionBlock)aBlock
{
    return [self initWithList:listItems selection:-1 block:aBlock];
}

#pragma mark -

-(NSInteger)addSection:(JONListSection*)aSection
{
    if(aSection == nil){
        return NSNotFound;
    }
    NSInteger sectionId = [sections count];
    [sections addObject:aSection];
    return sectionId;
}

-(NSInteger)addSectionWithTitle:(NSString*)aTitle list:(NSArray*)listItems block:(JONListSectionBlock)aBlock
{
    JONListSection *newSection = [[JONListSection alloc]initWithTitle:aTitle list:listItems block:aBlock];
    NSInteger sectionId = [self addSection:newSection];
    [newSection release];
    return sectionId;
}

-(NSInteger)addSection:(JONListSection*)aSection withSelection:(NSInteger)selection
{
    NSInteger sectionId = [self addSection:aSection];
    if(sectionId != NSNotFound){
        [self setSelection:selection inSectionWithId:sectionId];
    }
    return sectionId;
    
}

-(JONListSection*)sectionForSectionId:(NSInteger)index
{
    if(index<[sections count]){
        return [sections objectAtIndex:index];
    }
    return nil;
}

-(JONListSection*)lastSection
{
    return [sections lastObject];
}

-(NSInteger)idForLastSection
{
    return ([sections count] - 1);
}

-(void)setSelection:(NSInteger)selection inSectionWithId:(NSInteger)sectionId
{
    self.startingSelection = [NSIndexPath indexPathForRow:selection inSection:sectionId];
}

-(void)setSelectionInLastSection:(NSInteger)selection
{
    self.startingSelection = [NSIndexPath indexPathForRow:selection inSection:([sections count]-1)];
}

-(void)setSelectionToItemWithTitle:(NSString*)itemTitle
{
    NSInteger sectionIndex = 0;
    for(JONListSection *section in sections){
        NSInteger index = [section indexForItemWithTitle:itemTitle];
        if(index != NSNotFound){
            self.startingSelection = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
            return;
        }
        sectionIndex++;
    }
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.title;
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.startingSelection){
        [self.tableView scrollToRowAtIndexPath:self.startingSelection atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section < [sections count]){
        return [[sections objectAtIndex:section] count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JONListSection *section = [sections objectAtIndex:indexPath.section];
    
    JONListCellBlock block = block = [section cellBlock];
    if(block == NULL){
        block = [self cellBlock];
    }
    
    if(block){
        BOOL isSelected = [indexPath isEqual:startingSelection];
        return block([section.items objectAtIndex:indexPath.row],isSelected);
    }
    
    static NSString *CellIdentifier = @"JONListViewTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [section titleForItemAtIndex:indexPath.row];
    cell.imageView.image = [section imageForItemAtIndex:indexPath.row];
    
    if([indexPath isEqual:startingSelection]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section < [sections count]){
        return [[sections objectAtIndex:section]title];
    }
    return nil;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JONListSection *section = [sections objectAtIndex:indexPath.section];
    id item = [section.items objectAtIndex:indexPath.row];
    if([item isKindOfClass:[JONListItem class]] && [(JONListItem*)item selectionBlock]){
        JONListItemBlock itemSelBlock = [(JONListItem*)item selectionBlock];
        itemSelBlock((JONListItem*)item);
        
    }else{
        JONListSectionBlock selBlock = section.selectionBlock;
        selBlock(section.items,indexPath.row);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}





@end

