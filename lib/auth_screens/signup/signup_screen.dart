import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_controller.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildFieldLabel("Username"),
              _buildTextField(controller.usernameController, "Username",
                  Icons.person_3_outlined),
              const SizedBox(height: 20),
              _buildFieldLabel("Email"),
              _buildTextField(
                  controller.emailController, "Email", Icons.email_outlined),
              const SizedBox(height: 20),
              _buildFieldLabel("Password"),
              Obx(() => _buildPasswordField(
                    controller.passwordController,
                    "Password",
                    controller.obscurePassword.value,
                    () => controller.obscurePassword.toggle(),
                  )),
              const SizedBox(height: 20),
              _buildFieldLabel("Confirm Password"),
              Obx(() => _buildPasswordField(
                    controller.confirmPasswordController,
                    "Confirm Password",
                    controller.obscureConfirmPassword.value,
                    () => controller.obscureConfirmPassword.toggle(),
                  )),
              const SizedBox(height: 20),
              _buildTermsAndConditions(),
              const SizedBox(height: 70),
              GestureDetector(
                onTap: controller.saveToFirestore,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF0000),
                          Color.fromARGB(255, 73, 1, 1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: Icon(icon, color: Colors.white54),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hintText,
      bool obscureText, VoidCallback toggleVisibility) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.white,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.white54,
          ),
          onPressed: toggleVisibility,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: controller.termsAccepted.value,
                  onChanged: (value) => controller.termsAccepted.value = value!,
                  activeColor: Colors.red,
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      text: "I accept the ",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Terms and Conditions",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap =
                                () => _showTermsAndConditionsDialog(context),
                        ),
                        const TextSpan(text: " and the "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showPrivacyPolicyDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Terms and Conditions",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "By using this application, you agree to the following terms and conditions:",
                ),
                SizedBox(height: 10),
                Text(
                  "1. Acceptance of Terms",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Your access to and use of the app is conditioned upon your acceptance of and compliance with these Terms. These Terms apply to all visitors, users, and others who access or use the app.",
                ),
                SizedBox(height: 10),
                Text(
                  "2. User Responsibilities",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "You agree not to misuse the app or help anyone else to do so. This includes not interfering with the app's operations, accessing data you are not authorised to, or attempting to disrupt the app's services.",
                ),
                SizedBox(height: 10),
                Text(
                  "3. Privacy Policy",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "By using this app, you also agree to the terms outlined in our Privacy Policy regarding how your data is collected, processed, and stored.",
                ),
                SizedBox(height: 10),
                Text(
                  "4. Modifications to Terms",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "We reserve the right to modify these Terms at any time. Your continued use of the app following any changes indicates your acceptance of the updated Terms.",
                ),
                SizedBox(height: 10),
                Text(
                  "5. Limitation of Liability",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "We are not liable for any damages or losses resulting from your use of the app. The app is provided on an 'as-is' and 'as-available' basis.",
                ),
                SizedBox(height: 10),
                Text(
                  "6. Governing Law",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "These Terms shall be governed and construed in accordance with the laws of the Philippines, without regard to its conflict of law provisions.",
                ),
                SizedBox(height: 10),
                Text(
                  "If you have any questions about these Terms, please contact us.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Privacy Policy",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The Data Privacy Act of 2012 in the Philippines regulates how personal data is collected, processed, and stored.",
                ),
                SizedBox(height: 10),
                Text(
                  "This law ensures that individuals have control over their personal information and provides them with specific rights to safeguard their privacy. These rights include:",
                ),
                SizedBox(height: 10),
                Text(
                  "1. The Right to Be Informed",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Data subjects should be informed that their personal data will be collected, processed, and stored. This includes information about the purpose of data collection, the categories of personal data being collected, the recipients or categories of recipients who may have access to the data, and the period for which the data will be stored. Consent should be obtained when necessary.",
                ),
                SizedBox(height: 10),
                Text(
                  "2. The Right to Access",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Data subjects have the right to obtain a copy of the personal information that an organisation may possess about them. They can request organisations to do this, as well as additional details about how the data is being used or processed. Organisations must respond to these requests within a reasonable timeframe, usually within 30 days, and ensure that the information is provided in a clear and understandable format.",
                ),
                SizedBox(height: 10),
                Text(
                  "3. The Right to Object",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Data subjects can object to processing if it is based on consent or legitimate business interest.",
                ),
                SizedBox(height: 10),
                Text(
                  "4. The Right to Erasure or Blocking",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Data subjects have the right to withdraw or order the removal of their personal data when their rights are violated.",
                ),
                SizedBox(height: 10),
                Text(
                  "5. The Right to Damages",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Data subjects can claim compensation for damages due to unlawfully obtained or unauthorised use of personal data.",
                ),
                SizedBox(height: 10),
                Text(
                  "The Data Privacy Act also ensures that the Philippines complies with international data protection standards.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
