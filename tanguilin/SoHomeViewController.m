//
//  SoHomeViewController.m
//  tanguilin
//
//  Created by yangyuji on 14-7-21.
//  Copyright (c) 2014年 com.tanguilin. All rights reserved.
//  有什么问题 请到 加入QQ群 170627662 ，提问，我会尽力回答大家的

#import "SoHomeViewController.h"
#import "HomeViewController.h"


#import <sqlite3.h>
#import "DB.h"


#define CreateSql @"CREATE TABLE 'ksb_recipes_sohome' (\"rid\" integer NOT NULL PRIMARY KEY AUTOINCREMENT,\"title\" text(50,0) NOT NULL)"
#define CreateSql1 @"CREATE UNIQUE INDEX \"ksb_recipes_so\".\"rid\" ON \"ksb_recipes_so\" (\"rid\")"
#define ksb_recipes_so @"ksb_recipes_sohome"



@interface SoHomeViewController ()

@end

@implementation SoHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _data = [[NSMutableArray alloc]init];
    [DB creatTable:@"ksb_recipes_sohome" createSql:CreateSql]; //创建表
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.view.backgroundColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    

    
    UIView *titleViews = [[UIView alloc]init];
    titleViews.frame = CGRectMake(0, 20, ScreenWidth, 44);
    titleViews.backgroundColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:0.5];
    
    [self.view addSubview:titleViews];
    [titleViews release];
    
    //自定义返回按键
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(10, 0, 40, 40);
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(leftClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleViews addSubview:leftButton];
    
    //自定义 搜索键
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(55+200, 0, 40, 40);
    [rightButton setTitle:@"搜索" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleViews addSubview:rightButton];
    
    //自定 title
    
    UIView * titleView = [[UIView alloc]init];
    titleView.frame = CGRectMake(54, 5, 200, 30);
    titleView.backgroundColor = [UIColor clearColor];
    [titleViews addSubview:titleView];
    [titleView release];
    
    
    _soText = [[UITextField alloc]init];
    _soText.frame = CGRectMake(0, 1, 200, 30);
    _soText.backgroundColor = [UIColor whiteColor];
    _soText.layer.masksToBounds = YES;
    _soText.layer.cornerRadius = 6.0;
    _soText.tintColor = [UIColor blueColor];
    _soText.delegate = self;
    [_soText becomeFirstResponder];
    
    [titleView addSubview:_soText];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, titleViews.bottom, ScreenWidth, ScreenHeight -280) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.hidden = YES;
    [self.view addSubview:_tableView];
    

    
    

    
    
}

#pragma mark leftClickAction

- (void)leftClickAction:(UIButton*)but{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightClickAction:(UIButton*)but{
    [_soText resignFirstResponder];
    
    if (_soText.text.length > 0) {
        
        if (_block != Nil) {
            _block(_soText.text);
            Block_release(_block);
            _block = Nil;
        }
        
        FMDatabase *db = [DB creatDatabase];
        
        if ([db open]) {
            [db setShouldCacheStatements:YES];
            
            if ([db tableExists:ksb_recipes_so]) {
                
                 NSString *sql = [NSString stringWithFormat:@"insert into %@ (title) values ('%@')",ksb_recipes_so,_soText.text];
                
                 NSString *sqlCheck = [NSString stringWithFormat:@"select title from %@ where title = '%@'",ksb_recipes_so,_soText.text];
                
                
                 FMResultSet *rw = [db executeQuery:sqlCheck];
                
                if (![rw next]) {
                    
                    if([db executeUpdate:sql]){
                        NSLog(@"成功写入,%@",_soText.text);
                    }
                }else{
                    NSLog(@"以有数据，%@",_soText.text);
                }
                
                
                
            }
        }
        
        
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

#pragma mark  UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}


#pragma mark tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier]autorelease];
    }
    
    cell.textLabel.text = [_data objectAtIndex:indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _soText.text = [_data objectAtIndex:indexPath.row];
    _tableView.hidden = YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *delText = [_data objectAtIndex:indexPath.row];
        
       
        
        FMDatabase *db = [DB creatDatabase];
        
        [db setShouldCacheStatements:YES];
        
        if ([db open]) {
            
            if ([db tableExists:ksb_recipes_so]) {
                
                NSString *delSql = [NSString stringWithFormat:@"Delete from %@ where title = '%@'",ksb_recipes_so,delText];
                FMResultSet *rw = [db executeQuery:delSql];
                if (![rw next]) {
                    NSLog(@"删除成功");
                    [_data removeObjectAtIndex:indexPath.row];
                    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }else{
                    NSLog(@"删除失败");
                }
            }
            
           
        }
        
        
         
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //返回一个BOOL值，指明是否允许在按下回车键时结束编辑
    //如果允许要调用resignFirstResponder 方法，这回导致结束编辑，而键盘会被收起
    [textField resignFirstResponder];//查一下resign这个单词的意思就明白这个方法了
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    //创建 数据包
    FMDatabase *db = [DB creatDatabase];
    
    //打开数据库
    if ([db open]) {
        
        //开起缓存
        [db setShouldCacheStatements:YES];
        
        //查看是否有这个表
        if ([db tableExists:ksb_recipes_so]) {
            
             NSString *sqlCheck = [NSString stringWithFormat:@"select title from %@ order by rid desc",ksb_recipes_so];
            
            FMResultSet *rw = [db executeQuery:sqlCheck];
            
            if (rw) {
                 
                [_data removeAllObjects];
                
                while ([rw next]) {
                    
                    [_data addObject:[rw stringForColumn:@"title"]];
                    if (_data.count > 0) {
                        
                        [_tableView reloadData];
                        _tableView.hidden = NO;
                    }
                    
                }
                
                
            }
            
           
        }
        
    }
    
    
   }




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [super dealloc];
    [_data release],_data = nil;
    [_tableView release];
    
}

@end
