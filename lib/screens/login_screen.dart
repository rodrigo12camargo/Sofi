import 'package:flutter/material.dart';
import 'register_screen.dart'; // Asegúrate de que esta importación esté correcta

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Credenciales por defecto
  final String _defaultEmail = "sanchezaranza700@gmail.com";
  final String _defaultPassword = "S_17032023";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depura Code'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o nombre de la app (opcional)
            const Icon(Icons.code, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            
            // Campo de usuario/email
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email), // Cambiado a icono de email
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            
            // Campo de contraseña
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón de Login
            ElevatedButton(
              onPressed: () {
                if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa usuario y contraseña')),
                  );
                } else if (_usernameController.text != _defaultEmail || 
                          _passwordController.text != _defaultPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credenciales incorrectas')),
                  );
                } else {
                  // Credenciales correctas
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inicio de sesión exitoso')),
                  );
                  Navigator.pushReplacementNamed(context, '/home'); // Redirige al home
                }
              },
              child: const Text('Ingresar'),
            ),
            
            // Enlace a Registro
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate aquí'),
            ),
          ],
        ),
      ),
    );
  }
}