import 'package:flutter/material.dart';
import 'package:gerenciador_residuos_front/view/fepam_form.dart';
import 'main_view.dart';
import 'veiculo_view.dart';
import 'pessoa_view.dart';
import 'mtr_form.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  const CustomAppBar({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo),
      centerTitle: true,
      backgroundColor: const Color(0xFF22C55E),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String value) {
            switch (value) {
              case 'Resíduos':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainView()),
                );
                break;
              case 'Veículos':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VeiculoView()),
                );
                break;
              case 'Pessoas':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PessoaView()),
                );
                break;
              case 'MTR':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MtrForm()),
                );
                break;
                case 'FEPAM':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FepamForm()),
                );
                break;
              default:
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'Resíduos',
                child: Text('Resíduos'),
              ),
              const PopupMenuItem<String>(
                value: 'Veículos',
                child: Text('Veículos'),
              ),
              const PopupMenuItem<String>(
                value: 'Pessoas',
                child: Text('Pessoas'),
              ),
              const PopupMenuItem<String>(
                value: 'MTR',
                child: Text('MTR'),
              ),
              const PopupMenuItem<String>(
                value: 'FEPAM',
                child: Text('FEPAM'),
              ),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
