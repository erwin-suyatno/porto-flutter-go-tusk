import 'dart:io';

import 'package:d_button/d_button.dart';
import 'package:d_input/d_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/common/app_info.dart';
import 'package:mobile/common/enums.dart';
import 'package:mobile/common/urls.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/source/task_source.dart';
import 'package:mobile/presentation/bloc/detail_task/detail_task_cubit.dart';
import 'package:mobile/presentation/bloc/user/user_cubit.dart';
import 'package:mobile/presentation/widgets/app_button.dart';
import 'package:mobile/presentation/widgets/failed_ui.dart';
import 'package:extended_image/extended_image.dart';
class DetailTaskPage extends StatefulWidget {
  const DetailTaskPage({super.key, required this.id});
  final int id;

  @override
  State<DetailTaskPage> createState() => _DetailTaskPageState();
}

class _DetailTaskPageState extends State<DetailTaskPage> {

  final attachment = XFile('').obs;

  pickImage() async {
    XFile? result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result == null) return;
    attachment.value = result;
  }

  submitTask(){
    TaskSource.submitTask(attachment.value, widget.id).then((success) {
      if (success) {
        AppInfo.success(context, 'Success submit task');
        Navigator.pop(context);
        refresh();
      } else {
        AppInfo.failed(context, 'Failed submit task');
      }
    });
  }
  approvedTask(){
    TaskSource.approvedTask(widget.id).then((success) {
      if (success) {
        AppInfo.success(context, 'Success approved task');
        refresh();
      } else {
        AppInfo.failed(context, 'Failed approved task');
      }
    });
  }
  rejectedTask(edtReason){
    TaskSource.rejectedTask(widget.id, edtReason.text).then((success) {
      if (success) {
        AppInfo.success(context, 'Success rejected task');
        refresh();
      } else {
        AppInfo.failed(context, 'Failed rejected task');
      }
    });
  }
  fixToQueue(){
    int revision =context.read<DetailTaskCubit>().state.task!.revision! + 1;
    TaskSource.fixTask(widget.id, revision).then((success) {
      if (success) {
        AppInfo.success(context, 'Success fix to queue');
        Navigator.pop(context);
        refresh();
      } else {
        AppInfo.failed(context, 'Failed fix to queue');
      }
    });
  }
  deleteTask(){
    TaskSource.deleteTask(widget.id).then((success) {
      if (success) {
        AppInfo.success(context, 'Success delete task');
        Navigator.pop(context);
        refresh();
      } else {
        AppInfo.failed(context, 'Failed delete task');
      }
    });
  }

  refresh(){
    context.read<DetailTaskCubit>().fetchDetailTask(widget.id);
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DetailTaskCubit, DetailTaskState>(
        builder: (context, state) {
          if (state.status == RequestStatus.init) {
            return const SizedBox.shrink();
          }
          if (state.status == RequestStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == RequestStatus.failed) {
            return const FailedUi(
              message: 'Failed to load data',
            );
          }
          
          Task task = state.task!;
          return Column(
            children: [
              AppBar(                
                elevation: 0,
                centerTitle: true,
                title: const Text('Detail Task'),
                actions: [
                  buildMenu(task),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: [
                    buildStatus(task),
                    const Gap(24),
                    buildDescription(task),
                    const Gap(24),
                    buildDetails(task),
                    const Gap(24),
                    buildReason(task),
                    const Gap(24),
                    buildAttachment(task),
                    const Gap(24),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildAttachment(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20 ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attachment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          if (task.attachment != null && task.attachment != '') 
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: InteractiveViewer(
                                maxScale: 3,
                                child: ExtendedImage.network(
                                  URLs.image(task.attachment!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: UnconstrainedBox(
                                child: FloatingActionButton(
                                  heroTag: 'close-image-view',
                                  onPressed: ()=> Navigator.pop(context),
                                  backgroundColor: AppColor.primary.withOpacity(0.8),
                                  child: const Icon(Icons.close,),
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    );
                  },
                  child: ExtendedImage.network(
                    URLs.image(task.attachment!),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget buildDetails(Task task) {
    DateFormat dateFormat = DateFormat('d MMM');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20 ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          itemDetails('Published', dateFormat.format(task.createdAt!)),
          const Gap(4),
          itemDetails('Due Date', task.dueDate == null ? '-' : dateFormat.format(task.dueDate!)),
          const Gap(4),
          itemDetails('Submit Date', task.submitDate == null ? '-' : dateFormat.format(task.submitDate!)),
          const Gap(4),
          itemDetails('Revision', task.revision == null ? '-' : task.revision.toString()),
          const Gap(4),
          itemDetails('Approved Date', task.approvedDate == null ? '-' : dateFormat.format(task.approvedDate!)),
          const Gap(4),
          itemDetails('Rejected Date', task.rejectedDate == null ? '-' : dateFormat.format(task.rejectedDate!)),
        ],
      ),
    );
  }

  Widget itemDetails(String title, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.textBody,
            ),
          ),
        Text(
            data,
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.defaultText,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget buildReason(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20 ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reason Rejection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(10),
          Text(
            task.reason == null || task.reason == '' ? '-' : task.reason!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescription(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20 ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title??'',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(10),
          Text(
            task.description??'',
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatus(Task task) {
    return Stack(
      children: [
        Container(
          color: AppColor.primary,
          height: 60,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      task.status??'',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textBody,
                      ),
                    ),
                  ],
                )
              ),
              Image.asset(
                iconByStatus(task),
                height: 40,
                width: 40,
              )
            ],
          ),
        ),
      ]
    );
  }

  Widget buildMenu(Task task) {
    User user = context.read<UserCubit>().state;
    bool isAdmin = user.role == 'Admin';
    bool isEmployee = user.role == 'Employee';
    bool isSubmit = task.status == 'Review';
    bool isQueue = task.status == 'Queue';
    bool isRejected = task.status == 'Rejected';

    List<Map> menu = [
      if (isEmployee && isQueue) {
        'icon': Icons.send,
        'label': 'Submit',
        'color': AppColor.review,
        'onTap': ()=> buildSubmit(),
      },
      if (isAdmin && isSubmit) {
        'icon': Icons.check,
        'label': 'Approve',
        'color': AppColor.approved,
        'onTap': ()=> approvedTask(),
      },
      if (isAdmin && isSubmit) {
        'icon': Icons.block,
        'label': 'Reject',
        'color': AppColor.rejected,
        'onTap': ()=> buildReject(),
      },
      if (isEmployee && isRejected){
        'icon': Icons.auto_fix_high,
        'label': 'Fix To Queue',
        'color': AppColor.queue,
        'onTap': ()=> fixToQueue(),
      },
      if (isAdmin){
        'icon': Icons.delete_outline,
        'label': 'Delete',
        'color': Colors.red,
        'onTap': ()=> deleteTask(),
      },

    ];

    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => menu.map((e) {
        return PopupMenuItem(
          onTap: e['onTap'],
          child: Row(
            children: [
              Icon(e['icon'], color: e['color']),
              const Gap(12),
              Text(e['label']),
            ],
          ),
        );
      }).toList()
    );
  }

  buildSubmit(){
    showModalBottomSheet(
      context: context, 
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UnconstrainedBox(
                child: DButtonBorder(
                  onClick: () => pickImage(),
                  radius: 8,
                  borderColor: AppColor.textBody, 
                  child: const Text(
                    'Choose Attachment',
                  )
                ),
              ),
              const Gap(12),
              Obx(
                () {
                  String path = attachment.value.path;
                  if (path == '') {
                    return const FailedUi(message: 'Please choose attachment');
                  }
                  return AspectRatio(
                    aspectRatio: 16/9, 
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                    )
                  );
                }
              ),
              const Gap(12),
              Obx(() {
                return AppButton.primary('Submit', attachment.value.path == '' ? null : () {
                  Navigator.pop(context);
                  submitTask();
                });
              })
            ],
          ),
        );
      }
    );
  }
  buildReject(){
    final edtReason = TextEditingController();

    showModalBottomSheet(
      context: context, 
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send Reason Rejection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textTitle
                ),
              ),
              const Gap(12),
              DInput(
                controller: edtReason,
                fillColor: Colors.grey.shade100,
                radius: BorderRadius.circular(8),
                minLine: 8,
                maxLine: 8,
                hint: 'Reason...',
              ),
              const Gap(12),
              AppButton.primary('Submit', () {
                Navigator.pop(context);
                rejectedTask(edtReason);
              } )
            ],
          ),
        );
      }
    );
  }
}