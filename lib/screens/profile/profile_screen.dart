import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';

import '../../main.dart';
import '../../services/apis.dart';
import '../../utils/dialogs.dart';
import '../../models/main_user.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_navigation.dart';
import '../../widgets/particle_animation.dart';
import '../../widgets/custom_text_form_field.dart';

import '../profile/avatar_screen.dart';

class ProfileScreen extends StatelessWidget {
  final MainUser user;
  final _formKey = GlobalKey<FormState>();

  ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          centerTitle: true,
          title: const Text(
            'My Profile',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
        ),
        bottomNavigationBar: const CustomBannerAd(),
        body: Stack(
          children: [
            particles(context),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(width: mq.width, height: mq.height * .03),
                      InkWell(
                        borderRadius: BorderRadius.circular(mq.height * .075),
                        onTap: () {
                          // _showBottomSheet();
                          CustomNavigation()
                              .navigateWithAd(context, const AvatarScreen());
                        },
                        child: FluttermojiCircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: mq.height * .075,
                        ),
                      ),
                      SizedBox(height: mq.height * .02),
                      Text(APIs.user.email!),
                      SizedBox(height: mq.height * .05),
                      CustomTextFormField(
                        initialValue: user.name,
                        icon: CupertinoIcons.person,
                        hintText: 'eg. Aman Sirmaur',
                        labelText: 'Name',
                        onSaved: (val) => APIs.me.name = val ?? '',
                        validator: (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                      ),
                      SizedBox(height: mq.height * .02),
                      CustomTextFormField(
                        initialValue: user.about,
                        icon: CupertinoIcons.pencil_ellipsis_rectangle,
                        hintText: 'eg. Feeling Happy!',
                        labelText: 'About',
                        onSaved: (val) => APIs.me.about = val ?? '',
                        validator: (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                      ),
                      SizedBox(height: mq.height * .02),
                      CustomTextFormField(
                        initialValue: user.branch,
                        icon: Icons.school_outlined,
                        hintText: 'eg. Mechanical Engineering',
                        labelText: 'Branch',
                        onSaved: (val) => APIs.me.branch = val ?? '',
                        validator: (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                      ),
                      SizedBox(height: mq.height * .02),
                      CustomTextFormField(
                        initialValue: user.college,
                        icon: Icons.apartment_rounded,
                        hintText: 'eg. NIT Agartala',
                        labelText: 'College',
                        onSaved: (val) => APIs.me.college = val ?? '',
                        validator: (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                      ),
                      SizedBox(height: mq.height * .02),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.lightBlue,
                          fixedSize: Size(mq.width * .35, mq.height * .05),
                        ),
                        icon: const Icon(Icons.edit_note_outlined),
                        label: const Text('Update'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackBar(
                                  context, 'Profile Updated Successfully!');
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
