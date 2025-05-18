import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_consumer_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          dpLocator<ProfileBloc>()..add(const LoadUserProfile()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.error}', textAlign: TextAlign.center),
                    SizedBox(height: 2.h),
                    CustomButton(
                      onPressed: () {
                        context
                            .read<ProfileBloc>()
                            .add(const LoadUserProfile());
                      },
                      child: Text('Retry',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp)),
                    )
                  ],
                ),
              ),
            );
          } else if (state is ProfileLoaded) {
            final user = state.userProfile;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      radius: 40.sp,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Icon(Icons.person,
                          size: 40.sp, color: AppColors.primary),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Center(
                    child: Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      user.email,
                      style:
                          TextStyle(fontSize: 15.sp, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Center(
                    child: Text(
                      'Balance: \$${user.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _buildProfileOption(
                    context,
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    onTap: () async {
                      final currentState = context.read<ProfileBloc>().state;
                      if (currentState is ProfileLoaded) {
                        await context.pushNamed(AppRoutes.editProfile,
                            extra: currentState.userProfile);

                        if (context.mounted) {
                          context.read<ProfileBloc>().add(
                                const LoadUserProfile(),
                              );
                        }
                      }
                    },
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      context.pushNamed(AppRoutes.changePassword);
                    },
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    onTap: () async {
                      await dpLocator<AuthLocalDataSource>()
                          .deleteUserAndToken();
                      if (!context.mounted) {
                        return;
                      }

                      context.goNamed(AppRoutes.login);
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Loading profile...'));
        },
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: TextStyle(fontSize: 16.sp)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
