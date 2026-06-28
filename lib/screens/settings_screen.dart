import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Configurações",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "Gerencie a conexão de dados do seu workspace",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // CARD DE STATUS DE CONEXÃO
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderColor: dbProvider.isFirebaseBackend
                    ? AppTheme.neonCyan.withOpacity(0.3)
                    : Colors.white12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          dbProvider.isFirebaseBackend 
                              ? Icons.cloud_done_rounded 
                              : Icons.cloud_off_rounded,
                          color: dbProvider.isFirebaseBackend 
                              ? AppTheme.neonCyan 
                              : AppTheme.neonGold,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dbProvider.isFirebaseBackend 
                                    ? "Modo Firebase Cloud" 
                                    : "Modo Local Offline",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dbProvider.isFirebaseBackend
                                    ? "Dados sincronizados na nuvem em tempo real"
                                    : "Dados salvos temporariamente em memória local",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),
                    Text(
                      "Status do Banco:",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dbProvider.statusMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dbProvider.isFirebaseBackend 
                                ? AppTheme.neonGreen 
                                : AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CARD DE ALTERNADOR DE MODO
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Conectar ao Firebase",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ative para ler/gravar na nuvem",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: dbProvider.useFirebase,
                      activeColor: AppTheme.neonCyan,
                      activeTrackColor: AppTheme.neonPurple.withOpacity(0.4),
                      inactiveThumbColor: AppTheme.textSecondary,
                      inactiveTrackColor: Colors.white10,
                      onChanged: (value) async {
                        // Tenta inicializar/mudar de modo
                        await dbProvider.toggleMode(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PASSO A PASSO FIREBASE
              Text(
                "Como Conectar seu Próprio Firebase:",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      color: AppTheme.neonPurple,
                    ),
              ),
              const SizedBox(height: 12),
              _buildStepCard(
                context,
                "1",
                "Crie um projeto no console do Firebase (console.firebase.google.com).",
              ),
              _buildStepCard(
                context,
                "2",
                "Ative o Cloud Firestore Database em seu console do Firebase em modo de teste.",
              ),
              _buildStepCard(
                context,
                "3",
                "Adicione um aplicativo web ao seu projeto Firebase e copie o objeto 'firebaseConfig'.",
              ),
              _buildStepCard(
                context,
                "4",
                "Abra o arquivo 'lib/config/firebase_config.dart' no código e cole a 'apiKey', 'appId' e 'projectId'. O app se conectará automaticamente!",
                isCode: true,
              ),
              const SizedBox(height: 80), // Espaço extra para rolar sobre a navbar flutuante
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, String stepNumber, String text, {bool isCode = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppTheme.neonPurple.withOpacity(0.2),
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: AppTheme.neonCyan,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isCode ? AppTheme.neonGold : AppTheme.textSecondary,
                        fontFamily: isCode ? 'monospace' : null,
                        fontSize: isCode ? 13 : 14,
                      ),
                ),
                if (isCode) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: "lib/config/firebase_config.dart"));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Caminho copiado para a área de transferência!"),
                          backgroundColor: AppTheme.neonPurple,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: AppTheme.neonCyan),
                          SizedBox(width: 6),
                          Text(
                            "Copiar caminho do arquivo",
                            style: TextStyle(color: AppTheme.neonCyan, fontSize: 11),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
