import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_agent_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditProfilePage extends StatelessWidget {
  final UserModel currentUser;

  const EditProfilePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dpLocator<UpdateProfileBloc>(),
      child: EditProfileView(currentUser: currentUser),
    );
  }
}

class EditProfileView extends StatefulWidget {
  final UserModel currentUser;

  const EditProfileView({super.key, required this.currentUser});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.currentUser.firstName);
    _lastNameController =
        TextEditingController(text: widget.currentUser.lastName);
    _emailController = TextEditingController(text: widget.currentUser.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: BlocListener<UpdateProfileBloc, UpdateProfileState>(
        listener: (context, state) {
          if (state is UpdateProfileSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            context.pop();
          } else if (state is UpdateProfileFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Update Failed: ${state.error}')),
              );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _firstNameController,
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                  leadingIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _lastNameController,
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                  leadingIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your email address',
                  leadingIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                BlocBuilder<UpdateProfileBloc, UpdateProfileState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed:
                          state is UpdateProfileLoading ? () {} : _submitUpdate,
                      child: state is UpdateProfileLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Changes',
                              style: TextStyle(
                                  fontSize: 18.sp, color: Colors.white)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      context.read<UpdateProfileBloc>().add(
            UpdateProfileSubmitted(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
            ),
          );
    }
  }
}
