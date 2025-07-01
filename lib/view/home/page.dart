import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartshield_document_validator/bloc/verification/form/cubit.dart';
import 'package:smartshield_document_validator/generated/l10n.dart';
import 'package:smartshield_document_validator/generated/assets.gen.dart';
import 'package:smartshield_document_validator/model/verification.dart';

part 'dialog.dart';
part 'widget.dart';

@RoutePage()
class HomePage extends StatefulWidget implements AutoRouteWrapper {
  const HomePage({super.key});

  @override
  Widget wrappedRoute(final BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<VerificationFormCubit>(
            create: (final _) => VerificationFormCubit(),
          ),
        ],
        child: this,
      );
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController scrollController;
  @override
  Widget build(final BuildContext context) => Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              stretch: true,
              stretchTriggerOffset: 500.0,
              expandedHeight: MediaQuery.sizeOf(context).height,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Assets.images.pertamina.path),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: _BKILogo(),
                            ),
                            const SizedBox(height: 100),
                            _VerifyTopButton(_onScrollToBottom),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              shadowColor: Colors.black,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                Assets.images.chainPng.path,
                                height: 210,
                                width: 210,
                              ),
                              Image.asset(
                                Assets.images.bkilogo.path,
                                height: 110,
                                width: 110,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Center(
                                child: FittedBox(
                                  child: Text(
                                    'Silahkan isi Data Anda',
                                    style: TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Row(
                                  children: [
                                    Expanded(child: _NameField()),
                                    SizedBox(width: 50),
                                    Expanded(child: _EmailsField()),
                                    SizedBox(width: 50),
                                    Expanded(child: _RecordIdField()),
                                    SizedBox(width: 50),
                                  ],
                                ),
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 255, 255, 255)
                                            .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.05),
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const _FilePickerWidget(),
                                ),
                              ),
                              const _Button(),
                            ],
                          ),
                        ),
                        const _SmartShieldLogo(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScrollToBottom() {
    // Add your button logic here
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
