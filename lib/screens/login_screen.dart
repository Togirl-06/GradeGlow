import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/app_branding.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/login_remember_store.dart';
import '../theme/study_theme.dart';
import '../widgets/gradeglow_logo.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onSignedIn,
    this.onBackToSite,
  });

  final Future<void> Function() onSignedIn;
  final VoidCallback? onBackToSite;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final saved = await LoginRememberStore.load();
    if (!mounted) return;
    setState(() {
      _rememberMe = saved.remember;
      if (saved.email.isNotEmpty) _emailController.text = saved.email;
      if (saved.password.isNotEmpty) _passwordController.text = saved.password;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final bool wasSignUp = _isSignUp;
    bool signedUp = false;
    try {
      await action();
      signedUp = wasSignUp;
      await LoginRememberStore.save(
        remember: _rememberMe && !_isSignUp,
        email: _emailController.text,
        password: _passwordController.text,
      );
      await widget.onSignedIn();
    } catch (error) {
      setState(() => _error = _formatAuthError(error));
    } finally {
      if (mounted) {
        if (signedUp) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created. Check your inbox for the verification email.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatAuthError(Object error) {
    String message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }
    if (message.startsWith('PlatformException(')) {
      final int close = message.lastIndexOf(')');
      if (close > 18) {
        message = message.substring(18, close);
      }
    }
    final List<String> parts = message.split(', ');
    if (parts.length >= 2 && parts.last == 'null') {
      message = parts.sublist(1, parts.length - 1).join(', ');
    } else if (parts.length >= 2) {
      message = parts.sublist(1).join(', ');
    }
    return message.trim();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final AuthService auth = context.read<AuthService>();
    final bool wideWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 960;

    final Widget authCard = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: <Widget>[
          if (widget.onBackToSite != null && !wideWeb) ...<Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: widget.onBackToSite,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back to site'),
              ),
            ),
          ],
          _LoginHero(isSignUp: _isSignUp),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              decoration: BoxDecoration(
                color: StudyColors.surface(brightness),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: StudyColors.border(brightness)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppBranding.navy.withValues(
                      alpha: brightness == Brightness.dark ? 0.35 : 0.08,
                    ),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!AppConfig.hasFirebase) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: StudyColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Firebase could not start on this device. Sign-in may be unavailable until it connects.',
                        style: TextStyle(height: 1.35, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_error != null) ...<Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: StudyColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: StudyColors.danger.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: StudyColors.danger,
                          height: 1.4,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform ==
                              TargetPlatform.macOS)) ...<Widget>[
                    SignInWithAppleButton(
                      onPressed: () {
                        if (!_isLoading) _run(auth.signInWithApple);
                      },
                      style: SignInWithAppleButtonStyle.black,
                      height: 48,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _run(auth.signInWithGoogle),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.g_mobiledata_rounded, size: 24),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: StudyColors.border(brightness)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Divider(color: StudyColors.border(brightness)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or email',
                          style: TextStyle(color: textSecondary, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: StudyColors.border(brightness)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: StudyColors.background(brightness),
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                                const Icon(Icons.lock_outline_rounded),
                            filled: true,
                            fillColor: StudyColors.background(brightness),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (!_isSignUp) ...<Widget>[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => ResetPasswordScreen(
                                            initialEmail:
                                                _emailController.text.trim(),
                                          ),
                                        ),
                                      );
                                    },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                        ],
                        if (!_isSignUp) ...<Widget>[
                          const SizedBox(height: 4),
                          CheckboxListTile(
                            value: _rememberMe,
                            onChanged: _isLoading
                                ? null
                                : (bool? v) => setState(
                                      () => _rememberMe = v ?? false,
                                    ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: const Text('Remember me'),
                            subtitle: const Text(
                              'Save email and password on this device',
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final String email =
                                        _emailController.text.trim();
                                    final String password =
                                        _passwordController.text;
                                    _run(() async {
                                      if (_isSignUp) {
                                        await auth.signUpWithEmail(
                                          email,
                                          password,
                                        );
                                      } else {
                                        await auth.signInWithEmail(
                                          email,
                                          password,
                                          rememberMe: _rememberMe,
                                        );
                                        await auth.reloadUser();
                                      }
                                    });
                                  },
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              _isSignUp ? 'Create account' : 'Sign in',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign in'
                          : "Don't have an account? Sign up",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (!wideWeb) {
      return Scaffold(
        backgroundColor: StudyColors.background(brightness),
        body: SafeArea(child: Center(child: authCard)),
      );
    }

    return Scaffold(
      backgroundColor: StudyColors.background(brightness),
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF0B1220),
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(48, 40, 40, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.onBackToSite != null)
                      TextButton.icon(
                        onPressed: widget.onBackToSite,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Back to site'),
                      ),
                    const Spacer(),
                    Text(
                      AppBranding.name,
                      style: TextStyle(
                        color: AppBranding.glowOrange,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'World-class university education — for everyone',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppBranding.tagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SafeArea(child: Center(child: authCard)),
          ),
        ],
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.isSignUp});

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 52),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF172554),
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -36,
            right: -24,
            child: _GlowOrb(
              diameter: 140,
              colors: <Color>[
                AppBranding.glowOrange.withValues(alpha: 0.45),
                AppBranding.glowYellow.withValues(alpha: 0.08),
              ],
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: _GlowOrb(
              diameter: 110,
              colors: <Color>[
                StudyColors.primary.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: const GradeGlowLogo(height: 64),
              ),
              const SizedBox(height: 18),
              ShaderMask(
                shaderCallback: (Rect bounds) => const LinearGradient(
                  colors: <Color>[AppBranding.glowYellow, AppBranding.glowOrange, AppBranding.glowDeep],
                ).createShader(bounds),
                child: const Text(
                  AppBranding.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppBranding.tagline,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                isSignUp ? 'Create your account' : 'Welcome back',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSignUp
                    ? 'Create an account with any email.'
                    : 'Pick up where you left off.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.colors});

  final double diameter;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
