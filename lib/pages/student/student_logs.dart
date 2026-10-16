import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import '../../data/colors.dart';

import '../../http/request.dart';

class StudentLogPage extends StatefulWidget {
  const StudentLogPage({super.key,required this.id});
  final int id;
  @override
  State<StudentLogPage> createState() => _StudentLogPageState();
}

class _StudentLogPageState extends State<StudentLogPage> with SingleTickerProviderStateMixin {
  late List studentLogs = [];
  bool isLoading =true;
  @override
  void initState() {
    super.initState();
    _loadLogs(widget.id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('操作记录'),
      ),


      body: isLoading?Column(
        children: [
          Expanded( // 使用Expanded包裹SingleChildScrollView，使其可以自动调整高度
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.all(10),
                  color: Color(0xffEBEBEB),
                  child: SingleChildScrollView( // 使用SingleChildScrollView包裹ListView，实现滚动
                    child: Container(
                      color: Colors.white,
                      child: Stack(
                        fit: StackFit.loose,
                        children: <Widget>[
                          const Positioned(
                            left: 21,
                            top: 25,
                            bottom: 25,
                            child: VerticalDivider(
                              width: 1,
                              color: BaseColors.gray17,
                            ),
                          ),
                          ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: studentLogs.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: BaseColors.gray16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 0, right: 15),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    studentLogs[index]['admin'],
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: BaseColors.orange400,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  studentLogs[index]['created_at'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: BaseColors.gray7,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 5,),
                                            Text(
                                              studentLogs[index]['remarks']==""?studentLogs[index]['content']:studentLogs[index]['remarks'],
                                              style: TextStyle(
                                                  fontSize: 14
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider(
                                color: BaseColors.gray4,
                                height: 1,
                                indent: 45,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ):Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            //color: Colors.grey.withOpacity(0.3),
            child: Image.asset('static/images/loading.gif',fit: BoxFit.cover,
              width: 100,),
          ),
        ),
      ),
    );
  }

  Future<void> _loadLogs(int id) async {
    await HttpUtils.post(path:'/api/Student/logs',data:{'id':id}).then((value) {
      if(value['code']==200){
        print(value['data'].length);
        setState(() {
          studentLogs = value['data']??[];
          isLoading=true;
        });
      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
}