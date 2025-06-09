import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/core/navigation_bar/navigation_bar.dart';
import 'package:pic_board/core/snackbar/custom_snackbar.dart';
import 'package:pic_board/features/auth/data/services/auth_service.dart';
import 'package:pic_board/features/auth/domain/use_cases/validator_auth.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_button.dart';

class EditName extends StatefulWidget {
  const EditName({super.key});

  @override
  State<EditName> createState() => _EditNameState();
}

class _EditNameState extends State<EditName> {
  final _formKey = GlobalKey<FormState>();
  final changedNameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changedNameController.text = AuthService().currentUser!.displayName.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          "Edit name",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurface
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Write your new name.",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                    color: Theme.of(context).colorScheme.onSurface
                ),
              ),
              SizedBox(height: 10.h,),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: changedNameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                  validator: (value) {
                    return ValidatorAuth().validateName(value);
                  },
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: Theme.of(context).colorScheme.onSurface
                  ),
                ),
              ),
              Spacer(),
              isLoading ? Center(child: CircularProgressIndicator())
              : AuthButton(
                title: 'Save',
                onPressed: () async {
                  if(changedNameController.text.trim() == AuthService().currentUser!.displayName) {
                    CustomSnackBar().showSnackBar(context, text: 'You can\'t change your name to old one!', type: 'error');
                  }else {
                    if(_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      await AuthService().changeName(name: changedNameController.text.trim());
                      await AuthService().currentUser!.reload();
                      setState(() {
                        isLoading = false;
                      });
                      CustomSnackBar().showSnackBar(context, text: 'Name has changed successfully!', type: 'success');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => CustomBar(destination: 2)),
                        (Route<dynamic> route) => false,
                      );
                    }else {
                      CustomSnackBar().showSnackBar(context, text: 'Incorrect input!', type: 'error');
                    }
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
