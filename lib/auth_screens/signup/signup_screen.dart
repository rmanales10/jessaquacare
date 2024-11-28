import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_controller.dart';

class SignUpScreen extends StatelessWidget {
  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
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
    return Obx(() => Row(
          children: [
            Checkbox(
              value: controller.termsAccepted.value,
              onChanged: (value) => controller.termsAccepted.value = value!,
              activeColor: Colors.red,
            ),
            const Text(
              "I accept the Terms and Conditions",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ));
  }
}
