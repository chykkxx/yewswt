import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../data/colors.dart';
import 'package:badges/badges.dart' as badges;

import '../../http/request.dart';

class StudentPushPage extends StatefulWidget {
  const StudentPushPage({super.key,required this.student,required this.upSelect,required this.index});
  final  student;
  final int index;
  final void Function(int,List) upSelect;
  @override
  State<StudentPushPage> createState() => _StudentPushPageState();
}

class _StudentPushPageState extends State<StudentPushPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  final List<String> _selectPush = [];
  late  List _selectYiPush = [];
  late  List<DropdownMenuItem<String>> fenlei;
  late  List datas =[];
  late String xsstatus;
  bool isLoading =false;
  int pageNum=1;
  int total=0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController schoolController = TextEditingController();///学校
  final TextEditingController jigouController = TextEditingController();///机构
  final TextEditingController idController = TextEditingController();///简章ID
  final TextEditingController titleController = TextEditingController();///简章标题
  late Map searchObj={
    'id':'','title':'','school':'','college':'','major':'','jigou':'','current':1,'class':widget.student['leixing']['class']
  };
  late int searchNum=0;
  void setSearch(field,value){
    setState(() {
      //if(field=='id') idController.text=value;
      //if(field=='title') titleController.text=value;
      if(searchObj[field]=='' && value!=''){
        searchNum++;
      }else if(searchObj[field]!='' && value==''){
        searchNum--;
      }
      searchObj[field]=value;
      //tab0 =true;tab1 =true;tab2 =true;tab3 =true;
    });
  }
  @override
  void initState() {
    super.initState();
    //获取已推数据
    if(widget.student['yitui']!=null && widget.student['yitui'].length>0){
      _selectYiPush=widget.student['yitui'];
      for(int ii=0;ii<widget.student['yitui'].length;ii++){
        //jianzhang_id: 10402,jigou_id: 817,  manage_id: 38
        _selectPush.add('${widget.student['yitui'][ii]['jianzhang_id']}-${widget.student['yitui'][ii]['jigou_id']}-${widget.student['yitui'][ii]['manage_id']}');
      }
    }
    _loadJianZhang(1);
    //监听ID输入
    idController.addListener(() {
      setState(() {
        isLoading=true;
        pageNum=1;
        searchObj['id']=idController.text;
        if(searchObj['id']=='' && idController.text!=''){
          searchNum++;
        }else if(searchObj['id']!='' && idController.text==''){
          searchNum--;
        }
        _loadJianZhang(pageNum);
      });
    });
    //监听标题输入
    titleController.addListener(() {
      setState(() {
        isLoading=true;
        pageNum=1;
        searchObj['title']=titleController.text;
        if(searchObj['title']=='' && titleController.text!=''){
          searchNum++;
        }else if(searchObj['title']!='' && titleController.text==''){
          searchNum--;
        }
        _loadJianZhang(pageNum);
      });
    });
    //监听学校输入
    schoolController.addListener(() {
      setState(() {
        isLoading=true;
        pageNum=1;
        searchObj['school']=schoolController.text;
        if(searchObj['school']=='' && schoolController.text!=''){
          searchNum++;
        }else if(searchObj['school']!='' && schoolController.text==''){
          searchNum--;
        }
        _loadJianZhang(pageNum);
      });
    });
    //监听机构输入
    jigouController.addListener(() {
      setState(() {
        isLoading=true;
        pageNum=1;
        searchObj['jigou']=jigouController.text;
        if(searchObj['jigou']=='' && jigouController.text!=''){
          searchNum++;
        }else if(searchObj['jigou']!='' && jigouController.text==''){
          searchNum--;
        }
        _loadJianZhang(pageNum);
      });
    });
    ///监听滚动条
    _scrollController.addListener(() {
      ///滚动到底部了
      if(isLoading ==false && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent){
        setState(() {
          isLoading=true;
          pageNum++;
          _loadJianZhang(pageNum);
        });
      }else if(isLoading ==false && _scrollController.position.pixels==0){ ///滚动到顶部
        setState(() {
          isLoading=true;
          pageNum=1;
          _loadJianZhang(pageNum);
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student['str_school_major']}'),
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
          bottom: PreferredSize(
              preferredSize: const Size(0, 80),
              child:Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5,left: 10),
                          constraints: const BoxConstraints(
                            maxHeight: 30
                          ),
                          child: TextField(
                            controller: schoolController,
                            cursorWidth: 1,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: '学校',
                              labelStyle: const TextStyle(
                                  color: BaseColors.gray8,fontSize: 14
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                //borderSide: const BorderSide(color: Colors.red, width: 3.0, style: BorderStyle.solid)
                              ),
                              enabledBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: BaseColors.gray6, width: 1.0, style: BorderStyle.solid)
                              ),
                              focusedBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: BaseColors.color5, width: 1.0, style: BorderStyle.solid)
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5,left: 5,right: 10),
                          constraints: const BoxConstraints(
                            maxHeight: 30
                          ),
                          child: TextField(
                            controller: jigouController,
                            cursorWidth: 1,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: '机构',
                              labelStyle: const TextStyle(
                                  color: BaseColors.gray8,fontSize: 14
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                //borderSide: const BorderSide(color: Colors.red, width: 3.0, style: BorderStyle.solid)
                              ),
                              enabledBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: BaseColors.gray6, width: 1.0, style: BorderStyle.solid)
                              ),
                              focusedBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: BaseColors.color5, width: 1.0, style: BorderStyle.solid)
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10,left: 10),
                          constraints: const BoxConstraints(
                            maxHeight: 30
                          ),
                          child: TextField(
                            controller: titleController,
                            cursorWidth: 1,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: '简章标题',
                              labelStyle: const TextStyle(
                                  color: BaseColors.gray8,fontSize: 14
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                //borderSide: const BorderSide(color: Colors.red, width: 3.0, style: BorderStyle.solid)
                              ),
                              enabledBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: BaseColors.gray6, width: 1.0, style: BorderStyle.solid)
                              ),
                              focusedBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: BaseColors.color5, width: 1.0, style: BorderStyle.solid)
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10,left: 5,right: 10),
                          constraints: const BoxConstraints(
                            maxHeight: 30
                          ),
                          child: TextField(
                            controller: idController,
                            cursorWidth: 1,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: '简章ID',
                              labelStyle: const TextStyle(
                                  color: BaseColors.gray8,fontSize: 14
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                //borderSide: const BorderSide(color: Colors.red, width: 3.0, style: BorderStyle.solid)
                              ),
                              enabledBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: BaseColors.gray6, width: 1.0, style: BorderStyle.solid)
                              ),
                              focusedBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: BaseColors.color5, width: 1.0, style: BorderStyle.solid)
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  )

                ],
              ),
          )

      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: datas.length,
        itemBuilder: _cellForRow
      ),
      floatingActionButton: badges.Badge(
          showBadge: _selectPush.isNotEmpty,
          position: badges.BadgePosition.topEnd(top: -10, end: 20),
          badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red
          ),
          badgeContent: Text(
            '${_selectPush.isNotEmpty?_selectPush.length:0}',
            style: const TextStyle(
                fontSize: 10,
                color: BaseColors.white50
            ),
          ),
        child:FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: (){
            widget.upSelect(widget.index,_selectYiPush);
            Navigator.of(context).pop();
          },
          tooltip: '添加返回',
          child: const Icon(Icons.shopping_cart,color: Colors.white,),
        )
      ),
      endDrawer: AppDrawer(setSearch:setSearch,searchObj:searchObj),
      onEndDrawerChanged: (ifShou){
        if(ifShou==false){
          _loadJianZhang(1);
        }
      },
    );
  }

  Widget _cellForRow(BuildContext context, int index) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(10,10,10,0),
      padding: const EdgeInsets.all(10),
      child:  Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                '【${datas[index]['id']}】 ${datas[index]['title']}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    //fontStyle: FontStyle.values[1],
                    color: BaseColors.gray11
                ),
              ),
            ),
            const Divider(height: 1.0,color: BaseColors.gray6,),
            Container( height: 10.0, ),
            (datas[index]?['jigouarr']!=null && datas[index]['jigouarr'].length>0)?ListView.builder(
              shrinkWrap: true,//解决无限高度问题
              physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
              itemCount: datas[index]['jigouarr'].length,
              itemBuilder: (context, item) =>Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5,color: BaseColors.color5),
                  borderRadius: BorderRadius.circular(5),

                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.only(bottom: 5),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 0.5,color: BaseColors.gray5)
                        )
                      ),
                      child: Text(
                        '${datas[index]['jigouarr'][item]['name']}',
                        style: const TextStyle(
                            fontSize: 16,
                            //fontWeight: FontWeight.w600,
                            //height: 1.5
                        ),
                        overflow: TextOverflow.ellipsis,maxLines: 1,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,//解决无限高度问题
                        physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 5, //子元素宽高比
                        children: _getData(index,item),
                      ),
                    ),
                  ],
                ),
              ),
            ):const Text('未推')
          ],
        ), //每人一辆跑车
    );
  }

  List<Widget> _getData(index,item) {
    List<Widget> list = [];
    for (var ite = 0; ite < datas[index]['jigouarr'][item]['manage'].length; ite++) {
      list.add(
          InkWell(
            onTap: (){
              if(_selectPush.contains('${datas[index]['id']}-${datas[index]['jigouarr'][item]['id']}-${datas[index]['jigouarr'][item]['manage'][ite]['id']}')){
                setState(() {
                  final selectedIndex =
                  _selectPush.indexWhere((destination) {
                    return destination == '${datas[index]['id']}-${datas[index]['jigouarr'][item]['id']}-${datas[index]['jigouarr'][item]['manage'][ite]['id']}';
                  });
                  if(_selectYiPush[selectedIndex]['id']>0){ //推荐过不可取消
                    showToast('推荐过不可取消',duration: const Duration(seconds: 3),);
                  }else{
                    _selectPush.remove('${datas[index]['id']}-${datas[index]['jigouarr'][item]['id']}-${datas[index]['jigouarr'][item]['manage'][ite]['id']}');
                    _selectYiPush.removeAt(selectedIndex);
                  }
                });
              }else{
                setState(() {
                  _selectPush.add('${datas[index]['id']}-${datas[index]['jigouarr'][item]['id']}-${datas[index]['jigouarr'][item]['manage'][ite]['id']}');
                  _selectYiPush.add(
                      {
                        'id': 0, 'student_id': widget.student['student_id'], 'yixiang_id': widget.student['yixiang_id'], 'leixing_id': widget.student['leixing_id'],
                        'jigou_id': datas[index]['jigouarr'][item]['id'], 'jianzhang_id': datas[index]['id'], 'manage_id': datas[index]['jigouarr'][item]['manage'][ite]['id'],
                        'jigou': datas[index]['jigouarr'][item],
                        'jianzhang': datas[index], 'manage': datas[index]['jigouarr'][item]['manage'][ite]
                      }
                  );
                });
              }
            },
            child: Container(
              //height: 20,
              padding: const EdgeInsets.symmetric(vertical:2,horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
                color: _selectPush.contains('${datas[index]['id']}-${datas[index]['jigouarr'][item]['id']}-${datas[index]['jigouarr'][item]['manage'][ite]['id']}')?BaseColors.color8:BaseColors.gray14,
              ),
              child: Text(datas[index]['jigouarr'][item]['manage'][ite]['name'],
                overflow: TextOverflow.ellipsis,maxLines: 1,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )

      );
    }
    return list;
  }
  Future<void> _loadJianZhang(int page) async {
    //print(widget.student);
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
    var data=searchObj;
    data['current']=page;
    await HttpUtils.post(
        path:'/api/Push/jianzhang',
        data:data
    ).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){

        var datasArr=[];
        if(page>1){
          datasArr=datas+value['data'];
        }else{
          datasArr=value['data'];
        }
        setState(() {
          datas = datasArr;
          pageNum=page;
          isLoading=false;
        });
        if(value['data'].length==0){
          setState(() {
            pageNum=page-1;
            isLoading=false;
          });
          print('已经到底');
        }

      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key,required this.setSearch,required this.searchObj});
  final void Function(String, String) setSearch;
  final Map searchObj;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>{
  final TextEditingController _controllerId = TextEditingController();///ID
  final TextEditingController _controllerTitle = TextEditingController();///标题
  final TextEditingController _controllerSchool = TextEditingController();///学校
  final TextEditingController _controllerCollege = TextEditingController();///学院
  final TextEditingController _controllerMajor = TextEditingController();///专业
  final TextEditingController _controllerJigou = TextEditingController();///机构
  @override
  void initState(){
    _controllerId.text= widget.searchObj['id']??'';///ID
    _controllerTitle.text = widget.searchObj['tel']??'';///标题
    _controllerSchool.text = widget.searchObj['school']??'';///学校
    _controllerCollege.text = widget.searchObj['college']??'';///学院
    _controllerMajor.text = widget.searchObj['major']??'';///专业
    _controllerJigou.text = widget.searchObj['jigou']??'';///机构
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
                  decoration: BoxDecoration(
                    // border: Border(
                    //   bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                    // )
                  ),
                  child: Text(
                    '简章搜索',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                  child: TextField(
                    controller: _controllerId,
                    cursorWidth: 1,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top:13,left:10),
                        filled: true,
                        fillColor: BaseColors.gray18,
                        hintText: 'ID',
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: _controllerId.text.isNotEmpty?GestureDetector(
                            child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                            onTap: (){
                              _controllerId.text='';
                              widget.setSearch('id','');
                            },
                          ):null,
                        )
                    ),
                    onChanged: (text){
                      widget.setSearch('id',text);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                  child: TextField(
                    controller: _controllerTitle,
                    cursorWidth: 1,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top:13,left:10),
                        filled: true,
                        fillColor: BaseColors.gray18,
                        hintText: '标题',
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: _controllerTitle.text.isNotEmpty?GestureDetector(
                            child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                            onTap: (){
                              _controllerTitle.text='';
                              widget.setSearch('title','');
                            },
                          ):null,
                        )
                    ),
                    onChanged: (text){
                      widget.setSearch('title',text);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                  child: TextField(
                    controller: _controllerSchool,
                    cursorWidth: 1,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top:13,left:10),
                        filled: true,
                        fillColor: BaseColors.gray18,
                        hintText: '学校',
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: _controllerSchool.text.isNotEmpty?GestureDetector(
                            child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                            onTap: (){
                              _controllerSchool.text='';
                              widget.setSearch('school','');
                            },
                          ):null,
                        )
                    ),
                    onChanged: (text){
                      widget.setSearch('school',text);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                  child: TextField(
                    controller: _controllerCollege,
                    cursorWidth: 1,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top:13,left:10),
                        filled: true,
                        fillColor: BaseColors.gray18,
                        hintText: '学院',
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: _controllerCollege.text.isNotEmpty?GestureDetector(
                            child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                            onTap: (){
                              _controllerCollege.text='';
                              widget.setSearch('college','');
                            },
                          ):null,
                        )
                    ),
                    onChanged: (text){
                      widget.setSearch('college',text);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                  child: TextField(
                    controller: _controllerMajor,
                    cursorWidth: 1,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top:13,left:10),
                        filled: true,
                        fillColor: BaseColors.gray18,
                        hintText: '专业',
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: _controllerMajor.text.isNotEmpty?GestureDetector(
                            child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                            onTap: (){
                              _controllerMajor.text='';
                              widget.setSearch('major','');
                            },
                          ):null,
                        )
                    ),
                    onChanged: (text){
                      widget.setSearch('major',text);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10,left:15,right:15),
                  child: TextField(
                    controller: _controllerJigou,
                    cursorWidth: 1,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top:13,left:10),
                        filled: true,
                        fillColor: BaseColors.gray18,
                        hintText: '机构',
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: _controllerJigou.text.isNotEmpty?GestureDetector(
                            child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                            onTap: (){
                              _controllerJigou.text='';
                              widget.setSearch('jigou','');
                            },
                          ):null,
                        )
                    ),
                    onChanged: (text){
                      widget.setSearch('jigou',text);
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
                            _controllerId.clear();
                            _controllerTitle.clear();
                            _controllerSchool.clear();
                            _controllerCollege.clear();
                            _controllerMajor.clear();
                            _controllerJigou.clear();
                            widget.setSearch('id','');
                            widget.setSearch('title','');
                            widget.setSearch('school','');
                            widget.setSearch('college','');
                            widget.setSearch('major','');
                            widget.setSearch('jigou','');

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
                
                // Container(
                //   padding: const EdgeInsets.only(bottom: 2,left: 10),
                //   height: 50,
                //   decoration: const BoxDecoration(
                //       border: Border(
                //         bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                //       )
                //   ),
                //   child: Row(
                //     //mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: [
                //       const SizedBox(
                //         width:80,
                //         child: Text(
                //           'ID',
                //           style: TextStyle(
                //               color: BaseColors.gray8,
                //               fontSize:16
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: Container(
                //           margin: const EdgeInsets.only(top: 2),
                //           child: TextField(
                //             controller: _controllerId,
                //             cursorWidth: 1,
                //             decoration: InputDecoration(
                //                 border: InputBorder.none,
                //                 suffixIcon: Padding(
                //                   padding:  const EdgeInsets.only(top: 13,left: 20),
                //                   child: _controllerId.text.isNotEmpty?GestureDetector(
                //                     child:  const Text('x',style: TextStyle(color: Colors.redAccent,fontSize: 14),),
                //                     onTap: (){
                //                       _controllerId.text='';
                //                       widget.setSearch('id','');
                //                     },
                //                   ):null,
                //                 )
                //             ),
                //             onChanged: (text){
                //               widget.setSearch('id',text);
                //             },
                //           ),
                //         ),
          
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.only(bottom: 2,left: 10),
                //   height: 50,
                //   decoration: const BoxDecoration(
                //       border: Border(
                //         bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                //       )
                //   ),
                //   child: Row(
                //     children: [
                //       const SizedBox(
                //         width:80,
                //         child: Text(
                //           '标题',
                //           style: TextStyle(
                //               color: BaseColors.gray8,
                //               fontSize:16
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //           child: Container(
                //             margin: const EdgeInsets.only(top: 2),
                //             child: TextField(
                //               controller: _controllerTitle,
                //               cursorWidth: 1,
                //               decoration:  InputDecoration(
                //                   border: InputBorder.none,
                //                   suffixIcon: Padding(
                //                     padding:  const EdgeInsets.only(top: 13,left: 20),
                //                     child: _controllerTitle.text.isNotEmpty?GestureDetector(
                //                       child:  const Text('x',style: TextStyle(color: Colors.redAccent,fontSize: 14),),
                //                       onTap: (){
                //                         _controllerTitle.text='';
                //                         widget.setSearch('tel','');
                //                       },
                //                     ):null,
                //                   )
                //               ),
                //               onChanged: (text){
                //                 widget.setSearch('title',text);
                //               },
                //             ),
                //           )
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.only(bottom: 2,left: 10),
                //   height: 50,
                //   decoration: const BoxDecoration(
                //       border: Border(
                //         bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                //       )
                //   ),
                //   child: Row(
                //     children: [
                //       const SizedBox(
                //         width:80,
                //         child: Text(
                //           '学校',
                //           style: TextStyle(
                //               color: BaseColors.gray8,
                //               fontSize:16
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: Container(
                //           margin: const EdgeInsets.only(top: 2),
                //           child: TextField(
                //             controller: _controllerSchool,
                //             cursorWidth: 1,
                //             decoration: InputDecoration(
                //                 border: InputBorder.none,
                //                 suffixIcon: Padding(
                //                   padding:  const EdgeInsets.only(top: 13,left: 20),
                //                   child: _controllerSchool.text.isNotEmpty?GestureDetector(
                //                     child:  const Text('x',style: TextStyle(color: Colors.redAccent,fontSize: 14),),
                //                     onTap: (){
                //                       _controllerSchool.text='';
                //                       widget.setSearch('school','');
                //                     },
                //                   ):null,
                //                 )
                //             ),
                //             onChanged: (text){
                //               widget.setSearch('school',text);
                //             },
                //           ),
                //         ),
          
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.only(bottom: 2,left: 10),
                //   height: 50,
                //   decoration: const BoxDecoration(
                //       border: Border(
                //         bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                //       )
                //   ),
                //   child: Row(
                //     children: [
                //       const SizedBox(
                //         width:80,
                //         child: Text(
                //           '学院',
                //           style: TextStyle(
                //               color: BaseColors.gray8,
                //               fontSize:16
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: Container(
                //           margin: const EdgeInsets.only(top: 2),
                //           child: TextField(
                //             controller: _controllerCollege,
                //             cursorWidth: 1,
                //             decoration: InputDecoration(
                //                 border: InputBorder.none,
                //                 suffixIcon: Padding(
                //                   padding:  const EdgeInsets.only(top: 13,left: 20),
                //                   child: _controllerCollege.text.isNotEmpty?GestureDetector(
                //                     child:  const Text('x',style: TextStyle(color: Colors.redAccent,fontSize: 14),),
                //                     onTap: (){
                //                       _controllerCollege.text='';
                //                       widget.setSearch('college','');
                //                     },
                //                   ):null,
                //                 )
                //             ),
                //             onChanged: (text){
                //               widget.setSearch('college',text);
                //             },
                //           ),
                //         ),
          
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.only(bottom: 2,left: 10),
                //   height: 50,
                //   decoration: const BoxDecoration(
                //       border: Border(
                //         bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                //       )
                //   ),
                //   child: Row(
                //     children: [
                //       const SizedBox(
                //         width:80,
                //         child: Text(
                //           '专业',
                //           style: TextStyle(
                //               color: BaseColors.gray8,
                //               fontSize:16
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: Container(
                //           margin: const EdgeInsets.only(top: 2),
                //           child: TextField(
                //             controller: _controllerMajor,
                //             cursorWidth: 1,
                //             decoration: InputDecoration(
                //                 border: InputBorder.none,
                //                 suffixIcon: Padding(
                //                   padding:  const EdgeInsets.only(top: 13,left: 20),
                //                   child: _controllerMajor.text.isNotEmpty?GestureDetector(
                //                     child:  const Text('x',style: TextStyle(color: Colors.redAccent,fontSize: 14),),
                //                     onTap: (){
                //                       _controllerMajor.text='';
                //                       widget.setSearch('major','');
                //                     },
                //                   ):null,
                //                 )
                //             ),
                //             onChanged: (text){
                //               widget.setSearch('major',text);
                //             },
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.only(bottom: 2,left: 10),
                //   height: 50,
                //   decoration: const BoxDecoration(
                //       border: Border(
                //         bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                //       )
                //   ),
                //   child: Row(
                //     children: [
                //       const SizedBox(
                //         width:80,
                //         child: Text(
                //           '机构',
                //           style: TextStyle(
                //               color: BaseColors.gray8,
                //               fontSize:16
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: Container(
                //           margin: const EdgeInsets.only(top: 2),
                //           child: TextField(
                //             controller: _controllerJigou,
                //             cursorWidth: 1,
                //             decoration: InputDecoration(
                //                 border: InputBorder.none,
                //                 suffixIcon: Padding(
                //                   padding:  const EdgeInsets.only(top: 13,left: 20),
                //                   child: _controllerJigou.text.isNotEmpty?GestureDetector(
                //                     child:  const Text('x',style: TextStyle(color: Colors.redAccent,fontSize: 14),),
                //                     onTap: (){
                //                       _controllerJigou.text='';
                //                       widget.setSearch('jigou','');
                //                     },
                //                   ):null,
                //                 )
                //             ),
                //             onChanged: (text){
                //               widget.setSearch('jigou',text);
                //             },
                //           ),
                //         ),
          
                //       ),
                //     ],
                //   ),
                // ),


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
          data: ThemeData(
            primarySwatch: Colors.amber,
          ),
          child: child!,
        );
      },
      helpText: "请选择日期", // 左上角提示文字
      cancelText: "Cancel", // 取消按钮 文案
      confirmText: "OK", // 确认按钮 文案
      initialDatePickerMode: DatePickerMode.day, // 日期选择模式 默认为天
      useRootNavigator: true, // 是否使用根导航器
      textDirection: TextDirection.ltr, // 水平方向 显示方向 默认 ltr
    );
  }

}