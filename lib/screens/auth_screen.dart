import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _obscureLogin = true;
  bool _obscureReg = true;
  bool _obscureRegConfirm = true;

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // Register controllers
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  final _regFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _loginAsGuest() {
    context.read<AppState>().loginAsGuest();
    _goHome();
  }

  void _doLogin() {
    if (_loginFormKey.currentState!.validate()) {
      context.read<AppState>().login(
            'Pengguna AliShop',
            _loginEmailCtrl.text.trim(),
            '',
          );
      _goHome();
    }
  }

  void _doRegister() {
    if (_regFormKey.currentState!.validate()) {
      context.read<AppState>().login(
            _regNameCtrl.text.trim(),
            _regEmailCtrl.text.trim(),
            _regPhoneCtrl.text.trim(),
          );
      _goHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Header gradient
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF4500), Color(0xFFFF6000), Color(0xFFFF9A3C)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -40, right: -40,
                        child: Container(width: 160, height: 160,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07)))),
                      Positioned(bottom: 20, left: -30,
                        child: Container(width: 100, height: 100,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06)))),
                      SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.15),
                                      blurRadius: 15, offset: const Offset(0, 8))
                                  ],
                                ),
                                child: const Center(
                                  child: Text('ali',
                                    style: TextStyle(fontSize: 26,
                                      fontWeight: FontWeight.w900, color: Color(0xFFFF6000))),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text('AliShop',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                              const Text('Belanja Global, Harga Lokal',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.07),
                    blurRadius: 20, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: const Color(0xFFFF6000),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Masuk'),
                        Tab(text: 'Daftar'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 440,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLoginForm(),
                        _buildRegisterForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('atau', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _loginAsGuest,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFF6000), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person_outline, color: Color(0xFFFF6000), size: 20),
                          SizedBox(width: 8),
                          Text('Masuk Sebagai Tamu',
                            style: TextStyle(color: Color(0xFFFF6000),
                              fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Dengan melanjutkan, Anda menyetujui',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const Text('Syarat & Ketentuan',
                          style: TextStyle(color: Color(0xFFFF6000), fontSize: 11,
                            fontWeight: FontWeight.w600)),
                      ),
                      Text(' dan ', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      GestureDetector(
                        onTap: () {},
                        child: const Text('Kebijakan Privasi',
                          style: TextStyle(color: Color(0xFFFF6000), fontSize: 11,
                            fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _loginEmailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Email tidak boleh kosong' : null,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _loginPassCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscure: _obscureLogin,
              suffixIcon: IconButton(
                icon: Icon(_obscureLogin ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, size: 20),
                onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
              ),
              validator: (v) => v!.length < 6 ? 'Min. 6 karakter' : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Lupa Password?',
                  style: TextStyle(color: Color(0xFFFF6000), fontSize: 13)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _doLogin,
                child: const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 14),
            // Quick demo hint
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF6000).withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFFF6000), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFF6000))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Form(
        key: _regFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _regNameCtrl,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _regEmailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Email tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _regPhoneCtrl,
              label: 'No. Telepon',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _regPassCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscure: _obscureReg,
              suffixIcon: IconButton(
                icon: Icon(_obscureReg ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, size: 20),
                onPressed: () => setState(() => _obscureReg = !_obscureReg),
              ),
              validator: (v) => v!.length < 6 ? 'Min. 6 karakter' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _regConfirmCtrl,
              label: 'Konfirmasi Password',
              icon: Icons.lock_outline,
              obscure: _obscureRegConfirm,
              suffixIcon: IconButton(
                icon: Icon(_obscureRegConfirm ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, size: 20),
                onPressed: () => setState(() => _obscureRegConfirm = !_obscureRegConfirm),
              ),
              validator: (v) => v != _regPassCtrl.text ? 'Password tidak sama' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _doRegister,
                child: const Text('Daftar Sekarang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF6000), size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6000), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}