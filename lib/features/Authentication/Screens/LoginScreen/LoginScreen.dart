import 'dart:convert';
import 'dart:typed_data';
import 'package:AIMS_MOBILE/common/theme_model.dart';
import 'package:AIMS_MOBILE/common/theme_provider.dart';
import 'package:AIMS_MOBILE/features/NavigationBottomController/NavigationBottomController.dart';
import 'package:AIMS_MOBILE/features/ViewCourses/Screens/HomeScreen/HomeScreen.dart';
import 'package:AIMS_MOBILE/utils/constants/image_strings.dart';
import 'package:AIMS_MOBILE/utils/device/device_utility.dart';
import 'package:AIMS_MOBILE/utils/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String sessionId = '';
  String loginId = '';
  String password = '';
  String captcha1 = '';
  String captcha2 = '';
  bool hidePassword = true;
  bool isLoading = false;
  bool isCaptchaLoading = true;
  bool isLoginRequested = false;
  String captcha1ImageString = '';
  String captcha2ImageString = '';
  late Uint8List captcha1Bytes;
  late Uint8List captcha2Bytes;
  String baseUrl = "http://192.168.113.121:5001";

  @override
  void initState() {
    getCaptcha();
    super.initState();
  }

  void getCaptcha()async{
    try{
      setState(() {
        isCaptchaLoading = true;
      });
      final jsonResponse = await http.post(
          Uri.parse('$baseUrl/api/v1/getCaptcha'),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode({"sessionId": sessionId})
      );

      if(jsonResponse.statusCode == 200){
        final response = jsonDecode(jsonResponse.body);
        if(response['status'].toLowerCase() != 'error') {
            setState(() {
              captcha1ImageString = response['captchaBase64'];
              captcha1Bytes = base64Decode(captcha1ImageString);
              sessionId = response['sessionId'];
            });
            HelperFunctions.saveLoginState(false, sessionId);
            setState(() {
              isCaptchaLoading = false;
            });
        } else{
          setState(() {
            captcha1ImageString = response['captchaBase64'];
            captcha1Bytes = base64Decode(captcha1ImageString);
            sessionId = response['sessionId'];
          });
            HelperFunctions.showAlert("AIMS MOBILE", response['message']);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        HelperFunctions.showAlert("AIMS MOBILE", 'Error in loading Captcha !\n Please restart the application.');
      }

    } catch(e){
      print(e);
      setState(() {
        isLoading = false;
      });
      bool isConnected = await DeviceUtils.isConnected();
      if(!isConnected) {
        HelperFunctions.showAlert('AIMS MOBILE', 'Please Connect to Internet Connection');
      }
      else {
        HelperFunctions.showAlert('AIMS MOBILE', 'An error occurred while loading captcha ! Please retry again.');
      }
    }
  }

  void requestLogin() async {
    setState(() {
      isLoading = true;
    });

    var reqBody = {
      "sessionId": sessionId,
      "loginId": loginId,
      "password": password,
      "captcha": captcha1
    };

    try{
        var jsonResponse = await http.post(
            Uri.parse('$baseUrl/api/v1/requestLogin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(reqBody)
        );

        if(jsonResponse.statusCode == 200){
          final response = jsonDecode(jsonResponse.body);
            if(response['status'].toLowerCase() != 'error') {
              setState(() {
                captcha2ImageString = response['captchaBase64'];
                captcha2Bytes = base64Decode(captcha2ImageString);
              });

              setState(() {
                isLoading = false;
                isLoginRequested = true;
              });
          } else {
              setState(() {
                isLoading = false;
              });
              getCaptcha();
              HelperFunctions.showAlert("AIMS MOBILE", response['message']);
            }
        } else {
          setState(() {
            isLoading = false;
          });
          HelperFunctions.showAlert("AIMS MOBILE", 'Error in Requesting Login\n Please restart the application.');
        }
    } catch (e){
      print(e);
      setState(() {
        isLoading = false;
      });
      bool isConnected = await DeviceUtils.isConnected();
      if(!isConnected) {
        HelperFunctions.showAlert('AIMS MOBILE', 'Please Connect to Internet Connection');
      }
      else {
        HelperFunctions.showAlert('AIMS MOBILE', 'An error occurred while requesting login ! Please retry again.');
      }
    }
  }

  void login() async{
    setState(() {
      isLoading = true;
    });

    var reqBody = {
      "sessionId": sessionId,
      "captcha": captcha2
    };

    try{
      var jsonResponse = await http.post(
          Uri.parse('$baseUrl/api/v1/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(reqBody)
      );

      if(jsonResponse.statusCode == 200){
        final response = jsonDecode(jsonResponse.body);
        if(response['status'].toLowerCase() != 'error') {

            setState(() {
              isLoading = false;
              isLoginRequested = false;
            });

            print(response['status']);
            HelperFunctions.saveLoginState(true, sessionId);
            print(response['name']);
            HelperFunctions.shiftToScreen(context, BottomNavBarController(sessionId: sessionId, userName: response['name']));

        } else {
          if(response['status'] =='error'){
              setState(() {
                isLoading = false;
              });
              HelperFunctions.showAlert('AIMS MOBILE', response['message']);
          } else {
            setState(() {
              isLoading = false;
              isLoginRequested = false;
            });
            getCaptcha();
            HelperFunctions.showAlert("AIMS MOBILE", response['message']);
          }
        }

      } else {
        setState(() {
          isLoading = false;
        });
        HelperFunctions.showAlert("AIMS MOBILE", 'Error in Login\n Please restart the application.');
      }
    } catch (e){
      print(e);
      setState(() {
        isLoading = false;
      });
      bool isConnected = await DeviceUtils.isConnected();
      if(!isConnected) {
        HelperFunctions.showAlert('AIMS MOBILE', 'Please Connect to Internet Connection');
      }
      else {
        HelperFunctions.showAlert('AIMS MOBILE', 'An error occurred while login ! Please retry again.');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: (){
                          setState(() {
                            Provider.of<ThemeModel>(context, listen: false).toggleTheme();
                          });
                        },
                        child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(Provider.of<ThemeProvider>(context).isDark ? Icons.light_mode_outlined: Icons.dark_mode_outlined)
                        )
                    ),

                    GestureDetector(
                        onTap: (){
                          HelperFunctions.shiftToScreen(context, const BottomNavBarController(sessionId: '', userName: 'Login to see your Name !',));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Text('Skip', style: Theme.of(context).textTheme.bodyMedium,),
                        )
                    ),

                  ],
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(FImages.loginImage,height: 200 ),
                  ],
                ),

                Text('Login', style: Theme.of(context).textTheme.headlineMedium,),
                const SizedBox(height: 5,),
                Text('Enter your login details to access  AIMS Portal', style: Theme.of(context).textTheme.bodyMedium,),

                const SizedBox(height: 20,),

                !isLoginRequested? Column(
                  children: [
                    Container(
                      height: 104,
                      width: DeviceUtils.getScreenSize(context).width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                            0xFF000811)
                            : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login ID', style: Theme.of(context).textTheme.titleMedium,),
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              style: Theme.of(context).textTheme.bodySmall,
                              decoration: const InputDecoration(
                                hintText: 'e.g. CS23B1011',
                                enabledBorder:  UnderlineInputBorder(borderSide: BorderSide.none),
                                focusedBorder:  UnderlineInputBorder(borderSide: BorderSide.none),
                                errorBorder:  UnderlineInputBorder(borderSide: BorderSide.none),
                                focusedErrorBorder:  UnderlineInputBorder(borderSide: BorderSide.none),
                                errorStyle:  TextStyle(fontSize: 0)
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              onSaved: (value) => loginId = value!,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 3,),

                    Container(
                      height: 104,
                      width: DeviceUtils.getScreenSize(context).width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                            0xFF000811):
                        Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password', style: Theme.of(context).textTheme.titleMedium,),
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                  hintText: 'Enter Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                  ),
                                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                                  errorBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                                  focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                                  errorStyle: const TextStyle(fontSize: 0)
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              onSaved: (value) => password = value!,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 3,),

                    Container(
                      height: 109,
                      width: DeviceUtils.getScreenSize(context).width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                              0xFF000811):
                          Colors.white,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Captcha', style: Theme.of(context).textTheme.titleMedium,),
                              const SizedBox(width: 10,),
                              GestureDetector(
                                onTap: (){
                                   getCaptcha();
                                },
                                  child: const Icon(Icons.refresh, size: 20,)
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              isCaptchaLoading? const Padding(
                                padding: EdgeInsets.only(right: 41, left: 41),
                                child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 1)),
                              ):
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                height: 40,
                                width: 100,
                                decoration: isCaptchaLoading? const BoxDecoration(
                                  color: Colors.white,
                                ): BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(captcha1Bytes)
                                  )
                                ),
                              ),

                              const SizedBox(width: 5,),

                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: 'Enter the text from the image',
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                        errorBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                        focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                        errorStyle: TextStyle(fontSize: 0)
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) => captcha1 = value!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: (){},
                            child: const Text('Forgot Password?')
                        )
                      ],
                    ),

                    const SizedBox(height: 5,),

                    SizedBox(
                      width: DeviceUtils.getScreenSize(context).width,
                      child: ElevatedButton(
                        onPressed: !isLoading? () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            requestLogin();
                          }
                          else {
                            _formKey.currentState!.save();
                            if(loginId=='' && password=='' && captcha1==''){
                              HelperFunctions.showSnackBar('Enter Valid Details');
                            }
                            else {
                              if(loginId.isEmpty){
                                HelperFunctions.showSnackBar('Enter Valid Email ID');
                              }
                              else if(password.isEmpty){
                                HelperFunctions.showSnackBar('Enter Valid Password');
                              }
                              else {
                                HelperFunctions.showSnackBar('Enter Valid Captcha');
                              }
                            }
                          }
                        }: (){},
                        child: isLoading? const SizedBox(
                          height: 19,
                          width: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.white,
                          ),
                        ) : const Text('REQUEST LOGIN'),
                      ),
                    ),

                  ],
                ): Column(
                  children: [
                    Container(
                      height: 109,
                      width: DeviceUtils.getScreenSize(context).width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                              0xFF000811):
                          Colors.white,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Captcha', style: Theme.of(context).textTheme.titleMedium,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  height: 40,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: MemoryImage(captcha2Bytes)
                                      )
                                  )
                              ),

                              const SizedBox(width: 20,),

                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: 'Enter the text from the image',
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                        errorBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                        focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                        errorStyle: TextStyle(fontSize: 0)
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) => captcha2 = value!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: (){},
                            child: const Text('Change Account')
                        )
                      ],
                    ),

                    const SizedBox(height: 5,),

                    SizedBox(
                      width: DeviceUtils.getScreenSize(context).width,
                      child: ElevatedButton(
                        onPressed: !isLoading? () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            login();
                          }
                          else {
                            _formKey.currentState!.save();
                            if(captcha2.isEmpty){
                              HelperFunctions.showSnackBar('Enter Valid Captcha !');
                            }
                          }
                        }: (){},
                        child: isLoading? const SizedBox(
                          height: 19,
                          width: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.white,
                          ),
                        ) : const Text('LOGIN'),
                      ),
                    ),
                  ],
                )



                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text("Don't have an account?", style: Theme.of(context).textTheme.bodySmall,),
                //     TextButton(
                //         onPressed: (){
                //           HelperFunctions.navigateToScreen(context, const SignupScreen());
                //         },
                //         child: const Text("Sign Up")
                //     )
                //   ],
                // )

              ],
            ),
          ),
        )
      ),
    );
  }
}