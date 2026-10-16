import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/colors.dart';
import 'student_show.dart';
import 'package:badges/badges.dart' as badges;

import '../../http/request.dart';

import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class IndexStudentPage extends StatefulWidget {
  const IndexStudentPage({super.key,});
  @override
  State<IndexStudentPage> createState() => _IndexStudentPageState();
}

class _IndexStudentPageState extends State<IndexStudentPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late List students=[];
  bool tab0 =true;int pageNum=1;int total=0;
  late List students1=[];
  bool tab1 =true;int pageNum1=1;int total1=0;
  late List students2=[];
  bool tab2 =true;int pageNum2=1;int total2=0;
  late List students3=[];
  bool tab3 =true;int pageNum3=1;int total3=0;
  double pixels=0.00;

  late  List<DropdownMenuItem<String>> fenlei=[];
  bool isLoading =false;
  late final ToastFuture toastFuture;

  late TabController _tabController;

  late Map searchObj={
    'name':'','tel':'','weixin':'','email':'','education':'','graduate':'',
    'address':'','remarks':'','status':'0','startDay':'','endDay':'','keyword':'','text':'',
  };
  late int searchNum=0;
  void setSearch(field,value){
    setState(() {
      if(field != 'text'){
        if(searchObj[field]=='' && value!=''){
          searchNum++;
        }else if(searchObj[field]!='' && value==''){
          searchNum--;
        }
      }
      searchObj[field]=value;
      tab0 =true;tab1 =true;tab2 =true;tab3 =true;
    });
  }
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controllerKeyword = TextEditingController();///关键词搜索
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _tabController.addListener(() {
      switch(_tabController.index){
        case 0:
          if(tab0) _loadStudent(1);
          break;
        case 1:
          if(tab1) _loadStudent(1);
          break;
        case 2:
          if(tab2) _loadStudent(1);
          break;
        case 3:
          if(tab3) _loadStudent(1);
          break;
      }
      //print(_tabController.index);//打印点击的索引
    });
    _loadStudent(pageNum);
    _scrollController.addListener(() {
      ///滚动到底部了
      setState(() {
        pixels=_scrollController.position.pixels;
      });
      if(isLoading ==false && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent){
        setState(() {
          isLoading=true;
          switch(_tabController.index){
            case 0:
              pageNum++;
              _loadStudent(pageNum);
              break;
            case 1:
              pageNum1++;
              _loadStudent(pageNum1);
              break;
            case 2:
              pageNum2++;
              _loadStudent(pageNum2);
              break;
            case 3:
              pageNum3++;
              _loadStudent(pageNum3);
              break;
          }

        });
      }else if(isLoading ==false && _scrollController.position.pixels==0){ ///滚动到顶部
        setState(() {
          isLoading=true;
          switch(_tabController.index){
            case 0:
              pageNum=1;
              _loadStudent(pageNum);
              break;
            case 1:
              pageNum1=1;
              _loadStudent(pageNum1);
              break;
            case 2:
              pageNum2=1;
              _loadStudent(pageNum2);
              break;
            case 3:
              pageNum3=1;
              _loadStudent(pageNum3);
              break;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('推送'),
        actions: [
          Builder(
            builder: (context) => badges.Badge(
              showBadge: searchNum>0,
              position: badges.BadgePosition.topEnd(top: 1, end: 3),
              badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.red
              ),
              badgeContent: Text(
                searchNum<10?searchNum.toString():'9+',
                style: const TextStyle(
                    fontSize: 10,
                    color: BaseColors.white50
                ),
              ),
              child:IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
              onTap: ()=>Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
        bottom: TabBar(
          // isScrollable: true, //可滚动
          indicatorColor: BaseColors.color8, //指示器的颜色
          labelColor: BaseColors.color8, //选中文字颜色
          unselectedLabelColor: BaseColors.gray11, //为选中文字颜色
          // indicatorSize: TabBarIndicatorSize.label, //指示器与文字等宽
          tabs:  <Widget>[
            Tab(
              child: Column(
                children: [
                  const Text('未推'),
                  Text('$total',style: const TextStyle(fontSize: 12,color: BaseColors.gray8),)
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  const Text('已推'),
                  Text('$total1',style: const TextStyle(fontSize: 12,color: BaseColors.gray8),)
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  const Text('无项目'),
                  Text('$total2',style: const TextStyle(fontSize: 12,color: BaseColors.gray8),)
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  const Text('驳回'),
                  Text('$total3',style: const TextStyle(fontSize: 12,color: BaseColors.gray8),)
                ],
              ),
            ),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: students.isEmpty?1:students.length, //告诉ListView总共有多少个cell
            itemBuilder: (context, index) {
              return Column(
                children: [
                  if(index==0)
                    Container(
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                      height: 35,
                      child: Container(
                        //margin: const EdgeInsets.only(left: 10,right: 10,top: 40,bottom: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,  // 搜索框背景色-灰色
                          borderRadius: BorderRadius.circular(4), // 设置搜索框圆角
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10,),
                            const Icon(Icons.search, size: 18, color: Color(0xFF999999)),
                            Container(
                              width: MediaQuery.of(context).size.width-100,
                              //height: 40,
                              alignment: Alignment.centerLeft,
                              //padding: const EdgeInsets.only(bottom: 4),
                              child: TextField(
                                controller: _controllerKeyword,
                                style: TextStyle(fontSize: 14),
                                cursorWidth: 1,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(bottom: 0),
                                    hintText: '电话/姓名',  //搜索提示词
                                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),  //搜索框文字样式
                                    border: InputBorder.none,
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(top: 0,left: 10),
                                      child: GestureDetector(
                                        child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                                        onTap: (){
                                          _controllerKeyword.clear();
                                          setState(() {
                                            searchObj['keyword']='';
                                            tab0=tab1=tab2=tab3=true;
                                          });
                                          _loadStudent(1);
                                        },
                                      ),
                                    )
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  searchObj['keyword']=_controllerKeyword.text;
                                  tab0=tab1=tab2=tab3=true;
                                });
                                _loadStudent(1);
                              },
                              child: Container(
                                width: 50,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: BaseColors.color8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('搜索',style: TextStyle(color: Colors.white),),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  if(students.isNotEmpty)StudentItemPage(student:students[index],index:index,showStudent:showStudent),
                ],
              );
            }
          ),
          ListView.builder(
            controller: _scrollController,
            itemCount: students1.isEmpty?1:students1.length, //告诉ListView总共有多少个cell
            itemBuilder: (context, index) {
              return Column(
                children: [
                  if(index==0)
                    Container(
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                      height: 35,
                      child: Container(
                        //margin: const EdgeInsets.only(left: 10,right: 10,top: 40,bottom: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,  // 搜索框背景色-灰色
                          borderRadius: BorderRadius.circular(4), // 设置搜索框圆角
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10,),
                            const Icon(Icons.search, size: 18, color: Color(0xFF999999)),
                            Container(
                              width: MediaQuery.of(context).size.width-100,
                              //height: 40,
                              alignment: Alignment.centerLeft,
                              //padding: const EdgeInsets.only(bottom: 4),
                              child: TextField(
                                controller: _controllerKeyword,
                                style: TextStyle(fontSize: 14),
                                cursorWidth: 1,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(bottom: 0),
                                    hintText: '电话/姓名',  //搜索提示词
                                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),  //搜索框文字样式
                                    border: InputBorder.none,
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(top: 0,left: 10),
                                      child: GestureDetector(
                                        child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                                        onTap: (){
                                          _controllerKeyword.clear();
                                          setState(() {
                                            searchObj['keyword']='';
                                            tab0=tab1=tab2=tab3=true;
                                          });
                                          _loadStudent(1);
                                        },
                                      ),
                                    )
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  searchObj['keyword']=_controllerKeyword.text;
                                  tab0=tab1=tab2=tab3=true;
                                });
                                _loadStudent(1);
                              },
                              child: Container(
                                width: 50,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: BaseColors.color8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('搜索',style: TextStyle(color: Colors.white),),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  if(students1.isNotEmpty)StudentItemPage(student:students1[index],index:index,showStudent:showStudent),
                ],
              );
            }
          ),
          ListView.builder(
            controller: _scrollController,
            itemCount: students2.isEmpty?1:students2.length, //告诉ListView总共有多少个cell
            itemBuilder: (context, index) {
              return Column(
                children: [
                  if(index==0)
                    Container(
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                      height: 35,
                      child: Container(
                        //margin: const EdgeInsets.only(left: 10,right: 10,top: 40,bottom: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,  // 搜索框背景色-灰色
                          borderRadius: BorderRadius.circular(4), // 设置搜索框圆角
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10,),
                            const Icon(Icons.search, size: 18, color: Color(0xFF999999)),
                            Container(
                              width: MediaQuery.of(context).size.width-100,
                              //height: 40,
                              alignment: Alignment.centerLeft,
                              //padding: const EdgeInsets.only(bottom: 4),
                              child: TextField(
                                controller: _controllerKeyword,
                                style: TextStyle(fontSize: 14),
                                cursorWidth: 1,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(bottom: 0),
                                    hintText: '电话/姓名',  //搜索提示词
                                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),  //搜索框文字样式
                                    border: InputBorder.none,
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(top: 0,left: 10),
                                      child: GestureDetector(
                                        child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                                        onTap: (){
                                          _controllerKeyword.clear();
                                          setState(() {
                                            searchObj['keyword']='';
                                            tab0=tab1=tab2=tab3=true;
                                          });
                                          _loadStudent(1);
                                        },
                                      ),
                                    )
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  searchObj['keyword']=_controllerKeyword.text;
                                  tab0=tab1=tab2=tab3=true;
                                });
                                _loadStudent(1);
                              },
                              child: Container(
                                width: 50,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: BaseColors.color8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('搜索',style: TextStyle(color: Colors.white),),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  if(students2.isNotEmpty)StudentItemPage(student:students2[index],index:index,showStudent:showStudent),
                ],
              );
            }
          ),
          ListView.builder(
            controller: _scrollController,
            itemCount: students3.isEmpty?1:students3.length, //告诉ListView总共有多少个cell
            itemBuilder: (context, index) {
              return Column(
                children: [
                  if(index==0)
                    Container(
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                      height: 35,
                      child: Container(
                        //margin: const EdgeInsets.only(left: 10,right: 10,top: 40,bottom: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,  // 搜索框背景色-灰色
                          borderRadius: BorderRadius.circular(4), // 设置搜索框圆角
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10,),
                            const Icon(Icons.search, size: 18, color: Color(0xFF999999)),
                            Container(
                              width: MediaQuery.of(context).size.width-100,
                              //height: 40,
                              alignment: Alignment.centerLeft,
                              //padding: const EdgeInsets.only(bottom: 4),
                              child: TextField(
                                controller: _controllerKeyword,
                                style: TextStyle(fontSize: 14),
                                cursorWidth: 1,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(bottom: 0),
                                    hintText: '电话/姓名',  //搜索提示词
                                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),  //搜索框文字样式
                                    border: InputBorder.none,
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(top: 0,left: 10),
                                      child: GestureDetector(
                                        child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                                        onTap: (){
                                          _controllerKeyword.clear();
                                          setState(() {
                                            searchObj['keyword']='';
                                            tab0=tab1=tab2=tab3=true;
                                          });
                                          _loadStudent(1);
                                        },
                                      ),
                                    )
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  searchObj['keyword']=_controllerKeyword.text;
                                  tab0=tab1=tab2=tab3=true;
                                });
                                _loadStudent(1);
                              },
                              child: Container(
                                width: 50,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: BaseColors.color8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('搜索',style: TextStyle(color: Colors.white),),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  if(students3.isNotEmpty)StudentItemPage(student:students3[index],index:index,showStudent:showStudent),
                ],
              );
            }
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        
        backgroundColor: Colors.purple[300],
        shape: const CircleBorder(),
        onPressed: (){
          setState(() {
            isLoading=true;
            _scrollController.jumpTo(0.0);
            pageNum=1;
            _loadStudent(pageNum);
          });
        },
        child: Icon(pixels>1?Icons.arrow_upward:Icons.refresh,color: Colors.white,),
      ),

      endDrawer: AppDrawer(setSearch:setSearch,searchObj:searchObj,fenlei:fenlei),
      onEndDrawerChanged: (ifShou){
        if(ifShou==false){
          _loadStudent(1);
        }
      },
    );
  }
  ///打开详情
  void showStudent(group,index){
    _inboxKey = UniqueKey();
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context){
              return StudentShowPage(key: _inboxKey,student:group,);
            }
        )
    ).then((value)  async {
      _loadStudent(1);
    });
  }

  Future<void> _loadStudent(int page) async {
    var data=searchObj;
    data['current']=page;
    data['status']=_tabController.index;
    int tabindex=_tabController.index;
    final ToastFuture toastFuture = showToastWidget(
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            //color: Colors.grey.withOpacity(0.3),
            child: Image.asset('static/images/loading3.gif',fit: BoxFit.cover,
              width: 100,),
          ),
        ),
      ),
      duration: const Duration(seconds: 300),
      onDismiss: () {
        // The method will be called on toast dismiss.
        //debugPrint('Toast has been dismissed.');
      },
    );
    await HttpUtils.post(path:'/api/Push/index',data:data).then((value) {
      toastFuture.dismiss();
      if(fenlei.isEmpty){
        List<DropdownMenuItem<String>> fenleilist=[];
        fenleilist.add(const DropdownMenuItem(value: '0', child: Text('全部')));
        value['fenlei'].forEach((item){
          fenleilist.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['name'])));
        });
        setState(() {
          fenlei=fenleilist.toList();
        });
      }
        var studentArr=[];
        if(page>1){
          studentArr=students+value['data'];
        }else{
          studentArr=value['data'];
        }
        setState(() {
          isLoading=false;
          switch(tabindex){
            case 0:
              students = studentArr;
              tab0 =false;
              total=value['total'];
              pageNum=page;
              break;
            case 1:
              students1 = studentArr;
              tab1 =false;
              total1=value['total'];
              pageNum1=page;
              break;
            case 2:
              students2 = studentArr;
              tab2 =false;
              total2=value['total'];
              pageNum2=page;
              break;
            case 3:
              students3 = studentArr;
              tab3 =false;
              total3=value['total'];
              pageNum3=page;
              break;
          }
        });
      if(value['data'].length==0){
        setState(() {
          isLoading=false;
          switch(tabindex){
            case 0:
              tab0 =false;
              pageNum=page-1;
              break;
            case 1:
              tab1 =false;
              pageNum1=page-1;
              break;
            case 2:
              tab2 =false;
              pageNum2=page-1;
              break;
            case 3:
              tab3 =false;
              pageNum3=page-1;
              break;
          }
        });
        print('已经到底');
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }

}
class StudentItemPage extends StatelessWidget{
  const StudentItemPage({super.key,required this.student,required this.index,required this.showStudent});
  final  student;
  final int index;
  final void Function(Map,int) showStudent;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.2), //边框颜色
            width: 1, //边框宽度
          ), // 边色与边宽度
          color: Colors.white, // 底色
          boxShadow: [
            BoxShadow(
              blurRadius: 10, //阴影范围
              spreadRadius: 0.1, //阴影浓度
              color: Colors.grey.withOpacity(0.2), //阴影颜色
            ),
          ],
          borderRadius: BorderRadius.circular(4),
        ),
        //color: Colors.white,
        margin: const EdgeInsets.only(left: 10,right: 10,top: 4,bottom: 4),
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            //_showStudent(student,index);
            showStudent(student,index);
          },
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 120,
                          ),
                          child: Text('${student['s_name']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ), maxLines: 1,overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Text('(${student['id']})')
                      ],
                    ),

                    Text('${student['belong']}',
                      style: const TextStyle(color: BaseColors.orange500),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 5,left: 5),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width-20)/2,
                      child: InkWell(
                        child: Row(
                          children: [
                            const Text(
                              '电话：',
                              style: TextStyle(color: BaseColors.gray6),
                            ),
                            Text(telHide(student['tel']??'')),
                            //const Icon(Icons.phone_forwarded,size: 14,color: BaseColors.orange500,)
                            const SizedBox(width: 5,),
                            const Image(image: AssetImage('static/images/tel.png'),width: 20,)
                          ],
                        ),
                        onTap: () async {
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path: student['tel'],
                          );
                          await launchUrl(launchUri);
                        },
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          '微信：',
                          style: TextStyle(color: BaseColors.gray6),
                        ),
                        Text('${student['weixin']!=null && student['weixin']!=''?student['weixin'].replaceRange(3, null,'****'):''}'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 5,left: 5),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width-20)/2,
                      child: Row(
                        children: [
                          const Text(
                            '学历：',
                            style: TextStyle(color: BaseColors.gray6),
                          ),
                          Text("${student['educationname']}"),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Row(
                          children: [
                            const Text(
                              '地区：',
                              style: TextStyle(color: BaseColors.gray6),
                            ),
                            Expanded(
                              child: Text("${student['address']??''}",maxLines: 1,overflow: TextOverflow.ellipsis,),
                            )

                          ],
                        ),
                    )

                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      //width: 40,
                      child: const Text('推荐：',
                        style: TextStyle(color: BaseColors.gray6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                          '${student['str_school_major1']}',
                          maxLines: 1,overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      //width: 40,
                      child: const Text('备注：',
                        style: TextStyle(color: BaseColors.gray6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                          '${student['remarks']}',
                          maxLines: 1,overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 5,left: 5),
                alignment: Alignment.centerLeft,
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      //width: 40,
                      child: const Text('时间：',
                        style: TextStyle(color: BaseColors.gray6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                          student['created_at'],
                          maxLines: 1,overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
              ),
              // Column(
              //   children: [
              //     Container(
              //       decoration: const BoxDecoration(
              //           border: Border(
              //               bottom: BorderSide(width: 0.5,color: BaseColors.gray5)
              //           )
              //       ),
              //     ),
              //     const Image(image: AssetImage('images/downjt.png'),width: 10,),
              //   ],
              // )
            ],
          ),
        ) //每人一辆跑车
    );
  }
  ///电话隐藏
  telHide(String tel){
    var telarr=tel.split('|');
    var teltxt='';
    for(var item in telarr){
      if(item!='') {
        teltxt += item.replaceRange(3, 7, '****');
        break; ///只显示一个号码
      }
    }
    return teltxt==''?'-':teltxt;
  }
}
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key,required this.setSearch,required this.searchObj,required this.fenlei});
  final void Function(String, String) setSearch;
  final Map searchObj;
  final  List<DropdownMenuItem<String>> fenlei;
   @override
   State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>{
  final TextEditingController _controllerName = TextEditingController();///姓名
  final TextEditingController _controllerTel = TextEditingController();///电话
  final TextEditingController _controllerWeixin = TextEditingController();///微信
  final TextEditingController _controllerEmail = TextEditingController();///邮箱
  final TextEditingController _controllerEducation = TextEditingController();///学历
  final TextEditingController _controllerGraduate = TextEditingController();///毕业时间
  final TextEditingController _controllerAddress = TextEditingController();///所在城市
  final TextEditingController _controllerRemarks = TextEditingController();///备注
  final TextEditingController _controllerStartDay = TextEditingController();///开始日期
  final TextEditingController _controllerEndDay = TextEditingController();///截止日期
  final TextEditingController _controllerDayText = TextEditingController();///日期文字
  @override
  void initState(){
    _controllerName.text= widget.searchObj['name'];///姓名
    _controllerTel.text = widget.searchObj['tel'];///电话
    _controllerWeixin.text = widget.searchObj['weixin'];///微信
    _controllerEmail.text = widget.searchObj['email'];///邮箱
    _controllerEducation.text = widget.searchObj['education'];///学历
    _controllerGraduate.text = widget.searchObj['graduate'];///毕业时间
    _controllerAddress.text = widget.searchObj['address'];///所在城市
    _controllerRemarks.text = widget.searchObj['remarks'];///备注
    _controllerStartDay.text = widget.searchObj['startDay'];///开始日期
    _controllerEndDay.text = widget.searchObj['endDay'];///截止日期
    _controllerDayText.text = widget.searchObj['text'];///日期文字
  }
  @override
  Widget build(BuildContext context) {

    return Drawer(
        backgroundColor: Colors.white,
      child:SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(15),
                child: Text(
                  '学生搜索',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerName,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '姓名',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerName.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerName.text='';
                            widget.setSearch('name','');
                          },
                        ):null,
                      )
                  ),
                  onChanged: (text){
                    widget.setSearch('name',text);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerTel,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '电话',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerTel.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerTel.text='';
                            widget.setSearch('tel','');
                          },
                        ):null,
                      )
                  ),
                  onChanged: (text){
                    widget.setSearch('tel',text);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerWeixin,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '微信',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerWeixin.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerWeixin.text='';
                            widget.setSearch('weixin','');
                          },
                        ):null,
                      )
                  ),
                  onChanged: (text){
                    widget.setSearch('weixin',text);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerEmail,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '邮箱',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerEmail.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerEmail.text='';
                            widget.setSearch('email','');
                          },
                        ):null,
                      )
                  ),
                  onChanged: (text){
                    widget.setSearch('email',text);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerGraduate,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '毕业时间',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerGraduate.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerGraduate.text='';
                            widget.setSearch('graduate','');
                          },
                        ):null,
                      )
                  ),
                  onChanged: (text){
                    widget.setSearch('graduate',text);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerAddress,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '所在城市',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerAddress.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerAddress.text='';
                            widget.setSearch('address','');
                          },
                        ):null,
                      )
                  ),
                  onChanged: (text){
                    widget.setSearch('address',text);
                  },
                ),
              ),

              // Container(
              //   margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
              //   child: TextField(
              //     controller: _controllerDayText,
              //     cursorWidth: 1,
              //     style: TextStyle(fontSize: 14),
              //     readOnly: true,
              //     decoration: InputDecoration(
              //       contentPadding: EdgeInsets.only(top:13,left:10),
              //       filled: true,
              //       fillColor: BaseColors.gray18,
              //       hintText: '选择日期',
              //       border: InputBorder.none,
              //       suffixIcon: Padding(
              //         padding: const EdgeInsets.only(left: 20),
              //         child: _controllerDayText.text.isNotEmpty?GestureDetector(
              //           child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
              //           onTap: (){
              //             _controllerDayText.text='';
              //             widget.setSearch('startDay','');
              //             widget.setSearch('endDay','');
              //             widget.setSearch('text','');
              //           },
              //         ):null,
              //       )
              //     ),
              //     onTap: () async {
              //       List<DateTime>? dateTimeList =
              //         await showOmniDateTimeRangePicker(
              //         context: context,
              //         startInitialDate: _controllerStartDay.text.toString() !='' ? DateTime.parse(_controllerStartDay.text.toString()) : DateTime.now(),
              //         startFirstDate:
              //           DateTime(1600).subtract(const Duration(days: 3652)),
              //         startLastDate: DateTime.now().add(
              //           const Duration(days: 3652),
              //         ),
              //         endInitialDate:  _controllerEndDay.text.toString() !='' ? DateTime.parse(_controllerEndDay.text.toString()) : DateTime.now(),
              //         endFirstDate:
              //           DateTime(1600).subtract(const Duration(days: 3652)),
              //         endLastDate: DateTime.now().add(
              //           const Duration(days: 3652),
              //         ),
              //         is24HourMode: true,
              //         isShowSeconds: false,
              //         minutesInterval: 1,
              //         secondsInterval: 1,
              //         isForce2Digits: true,
              //         borderRadius: const BorderRadius.all(Radius.circular(16)),
              //         constraints: const BoxConstraints(
              //           maxWidth: 350,
              //           maxHeight: 650,
              //         ),
              //         transitionBuilder: (context, anim1, anim2, child) {
              //           return FadeTransition(
              //             opacity: anim1.drive(
              //               Tween(
              //                 begin: 0,
              //                 end: 1,
              //               ),
              //             ),
              //             child: child,
              //           );
              //         },
              //         transitionDuration: const Duration(milliseconds: 200),
              //         barrierDismissible: true,
              //       );

              //       // print(dateTimeList?[0].toString());
              //       // print("End dateTime: ${dateTimeList?[1]}");

              //       DateTime? startDate = dateTimeList?[0];
              //       DateTime? endDate = dateTimeList?[1];

              //       if (startDate != null) {
              //         DateTime dateStartTime = DateTime.parse(startDate.toString());
              //         String formattedStartDate = DateFormat('yyyy-MM-dd HH:mm').format(dateStartTime);
              //         _controllerStartDay.text = formattedStartDate;
              //         widget.setSearch('startDay', formattedStartDate);
              //       }

              //       if (endDate != null) {
              //         DateTime dateEndTime = DateTime.parse(endDate.toString());
              //         String formattedEndDate = DateFormat('yyyy-MM-dd HH:mm').format(dateEndTime);
              //         _controllerEndDay.text = formattedEndDate;
              //         widget.setSearch('endDay', formattedEndDate);
              //       }

              //       if (startDate != null && endDate != null) {
              //         DateTime dateStartTime = DateTime.parse(startDate.toString());
              //         String formattedStartDate = DateFormat('yyyy-MM-dd HH:mm').format(dateStartTime);
              //         DateTime dateEndTime = DateTime.parse(endDate.toString());
              //         String formattedEndDate = DateFormat('yyyy-MM-dd HH:mm').format(dateEndTime);
              //         _controllerDayText.text = formattedStartDate + '-' + formattedEndDate;
              //         widget.setSearch('text', formattedStartDate + '-' + formattedEndDate);
              //       }

              //     },
              //     // onTap: () {
              //     //   var ss=_showDatePickerForTheme(context,_controllerStartDay.text);
              //     //   ss.then((value) {
              //     //     var day ='';
              //     //     if(value!=null){
              //     //       day =value.toString().substring(0,10);
              //     //     }
              //     //     _controllerStartDay.text=day;
              //     //     widget.setSearch('startDay',day);
              //     //   });
              //     // },
              //     onChanged: (text){
              //       widget.setSearch('startDay',text);
              //     },
              //   ),
              // ),


              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerStartDay,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  readOnly: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '开始日期',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerStartDay.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerStartDay.text='';
                            widget.setSearch('address','');
                          },
                        ):null,
                      )
                  ),
                  onTap: () {
                    var ss=_showDatePickerForTheme(context,_controllerStartDay.text);
                    ss.then((value) {
                      var day ='';
                      if(value!=null){
                        day =value.toString().substring(0,10);
                      }
                      _controllerStartDay.text=day;
                      widget.setSearch('startDay',day);
                    });
                  },
                  onChanged: (text){
                    widget.setSearch('startDay',text);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerEndDay,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  readOnly: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '截止日期',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerEndDay.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerEndDay.text='';
                            widget.setSearch('address','');
                          },
                        ):null,
                      )
                  ),
                  onTap: () {
                    var ss=_showDatePickerForTheme(context,_controllerEndDay.text);
                    ss.then((value) {
                      var day ='';
                      if(value!=null){
                        day =value.toString().substring(0,10);
                      }
                      _controllerEndDay.text=day;
                      widget.setSearch('endDay',day);
                    });
                  },
                  onChanged: (text){
                    widget.setSearch('endDay',text);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                child: TextField(
                  controller: _controllerRemarks,
                  cursorWidth: 1,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top:13,left:10),
                      filled: true,
                      fillColor: BaseColors.gray18,
                      hintText: '备注',
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _controllerRemarks.text.isNotEmpty?GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerRemarks.text='';
                            widget.setSearch('remarks','');
                          },
                        ):null,
                      )
                  ),
                  onChanged: (text){
                    widget.setSearch('remarks',text);
                  },
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left:15,bottom:20),
                      child: ElevatedButton(
                        onPressed: () {
                          _controllerName.clear();
                          _controllerTel.clear();
                          _controllerWeixin.clear();
                          _controllerEmail.clear();
                          _controllerEducation.clear();
                          _controllerGraduate.clear();
                          _controllerAddress.clear();
                          _controllerRemarks.clear();
                          _controllerStartDay.clear();
                          _controllerEndDay.clear();
                          _controllerDayText.clear();
                          widget.setSearch('name','');
                          widget.setSearch('tel','');
                          widget.setSearch('weixin','');
                          widget.setSearch('email','');
                          widget.setSearch('education','');
                          widget.setSearch('graduate','');
                          widget.setSearch('address','');
                          widget.setSearch('remarks','');
                          widget.setSearch('startDay','');
                          widget.setSearch('endDay','');
                          widget.setSearch('text','');

                          widget.setSearch('status','0');
                          widget.setSearch('manage_id','0');

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BaseColors.gray6,
                          minimumSize: Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        child: Text('重置'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left:10,right:15,bottom:20),
                      child: ElevatedButton(
                        onPressed: () {
                          Scaffold.of(context).closeEndDrawer();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44),
                          backgroundColor: BaseColors.color8,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        child: Text('确定'),
                      ),
                    ),
                  ),
                ],
              ),


             
            ],
          ),
        ),
      )

    );
  }

  Future<DateTime?> _showDatePickerForTheme(BuildContext context,String def) {
    late DateTime initialDate=DateTime.now();
    if(def.isNotEmpty && def!=null){ ///2023-01-02
      var year=def.substring(0,4);
      if(def.length>=10 ){
        var mouth=def.substring(5,7);
        var day=def.substring(8,10);
        initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day));
      }else if(def.length>=7){
        var mouth=def.substring(5,7);
        initialDate=DateTime(int.parse(year), int.parse(mouth));
      }else{
        initialDate=DateTime(int.parse(year), 1);
      }
    }
    return showDatePicker(
      context: context, // 上下文
      initialDate: initialDate, // 初始化选中日期
      firstDate: DateTime(1997, 5), // 开始日期
      lastDate: DateTime(2052, 7), // 结束日期
      currentDate: DateTime.now(), // 当前日期
      locale: const Locale('zh'),
      initialEntryMode: DatePickerEntryMode
          .calendarOnly, // 日历弹框样式 calendar: 默认显示日历，可切换成输入模式，input:默认显示输入模式，可切换到日历，calendarOnly:只显示日历，inputOnly:只显示输入模式
      selectableDayPredicate: (dayTime) {
        // 自定义哪些日期可选
        // if (dayTime == DateTime(2022, 5, 6) || dayTime == DateTime(2022, 6, 8)) {
        //   return false;
        // }
        return true;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: BaseColors.color8,//add your + button color here
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: BaseColors.color8, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      helpText: "请选择日期", // 左上角提示文字
      cancelText: "关闭", // 取消按钮 文案
      confirmText: "确定", // 确认按钮 文案
      initialDatePickerMode: DatePickerMode.day, // 日期选择模式 默认为天
      useRootNavigator: true, // 是否使用根导航器
      // textDirection: TextDirection.ltr, // 水平方向 显示方向 默认 ltr
    );
  }

}