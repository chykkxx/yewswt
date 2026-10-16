import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class YiliaoDuihua extends StatefulWidget {
  const YiliaoDuihua({super.key,required this.data});
  final List data;
  @override
  State<YiliaoDuihua> createState() => _YiliaoDuihuaState();
}

class _YiliaoDuihuaState extends State<YiliaoDuihua>{

  @override
  void initState(){

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:const Text('对话记录'),
        ),
        body:ListView.builder(
            padding: const EdgeInsets.all(10),
            //子Widget数量
            itemCount: widget.data.length,
            //子Widget高度
            //itemExtent: 50,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white
                ),
                child: Column(
                  crossAxisAlignment : widget.data[index]['senderType']==1?CrossAxisAlignment.start:CrossAxisAlignment.end,
                  children: [
                    widget.data[index]['senderType']==1?Row(
                      mainAxisAlignment : MainAxisAlignment.start,
                      children: [
                        const Text("同学"),
                        const SizedBox(width: 10,),
                        Text("${widget.data[index]['createTime']}"),
                      ],
                    ):Row(
                      mainAxisAlignment : MainAxisAlignment.end,
                      children: [
                        Text("${widget.data[index]['createTime']}"),
                        const SizedBox(width: 10,),
                        widget.data[index]['fromId'].length>8?
                        Text("${widget.data[index]['fromId'].substring(widget.data[index]['fromId'].length-7)}"):Text("${widget.data[index]['fromId']}"),
                      ],
                    ),
                    Container(
                      //width: 200,
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.data[index]['senderType']==1?const Color(0xffa9efbf):const Color(0xffCCE6FF),
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 400
                      ),
                      child: SelectableText(
                        "${widget.data[index]['message'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}",
                      ),
                    )
                  ],
                )

              );
            }
        )
    );
  }
}