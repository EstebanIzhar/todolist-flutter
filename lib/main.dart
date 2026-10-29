// Torres Hernandez Esteban Izhar 
// 28/10/2026
// 23030399

import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PantallaTareas(),
    );
  }
}

class PantallaTareas extends StatefulWidget {
  const PantallaTareas({super.key});

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  
  // La lista de tareas
  final List<String> listaDeTareas = ['tarea5', 'tarea1', 'tarea4', 'tarea2', 'tarea3'];
  final TextEditingController controladorTexto = TextEditingController();

  // --- AGREGAR TAREA ---
  void agregarTarea() {
    if (controladorTexto.text.isNotEmpty) {
      setState(() {
        listaDeTareas.insert(0, controladorTexto.text);
        controladorTexto.clear();
      });
    }
  }

  // --- ELIMINAR TAREA ---
  void eliminarTarea(int indice) {
    setState(() {
      listaDeTareas.removeAt(indice);
    });
  }

  // --- EDITAR TAREA (Abre una ventanita para escribir de nuevo) ---
  void editarTarea(int indice) {
    // Prellenamos el cuadro de texto con el nombre actual de la tarea
    controladorTexto.text = listaDeTareas[indice];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: controladorTexto,
            autofocus: true, // Abre el teclado automáticamente
          ),
          actions: [
            TextButton(
              onPressed: () {
                controladorTexto.clear();
                Navigator.pop(context); // Cierra la ventanita
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (controladorTexto.text.isNotEmpty) {
                  setState(() {
                    listaDeTareas[indice] = controladorTexto.text; // Guarda el nuevo texto
                  });
                  controladorTexto.clear();
                  Navigator.pop(context); // Cierra la ventanita
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // --- CAMBIAR POSICIÓN (Arrastrar y soltar) ---
  void cambiarPosicion(int indiceViejo, int indiceNuevo) {
    setState(() {
      if (indiceNuevo > indiceViejo) {
        indiceNuevo -= 1;
      }
      final tareaMovida = listaDeTareas.removeAt(indiceViejo);
      listaDeTareas.insert(indiceNuevo, tareaMovida);
    });
  }

  // --- MENÚ QUE APARECE AL DESLIZAR ---
  void mostrarOpciones(int indice) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Para que solo ocupe lo necesario
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Editar tarea'),
                onTap: () {
                  Navigator.pop(context); // Cierra el menú de abajo
                  editarTarea(indice);   // Abre el cuadro de edición
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar tarea'),
                onTap: () {
                  Navigator.pop(context); // Cierra el menú de abajo
                  eliminarTarea(indice);  // Borra la tarea
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
            // --- TÍTULO ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'To Do List',
                style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),

            // --- CUADRO DE TEXTO Y BOTÓN + ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controladorTexto,
                      decoration: const InputDecoration(
                        hintText: 'Ingresa una tarea...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => agregarTarea(),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: agregarTarea,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // --- LISTA CON DESLIZAMIENTO (SLIDING) ---
            Expanded(
              child: ReorderableListView.builder(
                itemCount: listaDeTareas.length,
                onReorder: cambiarPosicion,
                
                itemBuilder: (context, index) {
                  
                  // Envolvemos la tarea con Dismissible para detectar el desliz
                  return Dismissible(
                    key: ValueKey(listaDeTareas[index] + index.toString()),
                    
                    // Dirección del desliz: de derecha a izquierda
                    direction: DismissDirection.endToStart,
                    
                    // Color de fondo que se ve mientras deslizas
                    background: Container(
                      color: Colors.blue[100],
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.tune, color: Colors.blue), // Icono de opciones
                    ),

                    // ¿Qué pasa cuando deslizas? 
                    // Le decimos que NO borre la tarea, sino que muestre el menú.
                    confirmDismiss: (direction) async {
                      mostrarOpciones(index); // Abre el menú de Editar/Borrar
                      return false; // Retorna false para que la tarea NO desaparezca de golpe
                    },

                    // El diseño visual de la tarea
                    child: ListTile(
                      title: Text(listaDeTareas[index]),
                      trailing: const Icon(Icons.menu, color: Colors.grey), // Agarrador para reordenar
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}